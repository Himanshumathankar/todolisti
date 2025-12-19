/**
 * =============================================================================
 * Sync Service
 * =============================================================================
 * 
 * Handles offline-first synchronization with conflict resolution.
 * 
 * Sync Strategy:
 * 1. Client sends local changes with syncVersion for each entity
 * 2. Server compares versions and applies Last-Write-Wins for conflicts
 * 3. Server returns merged state and any conflicts detected
 * =============================================================================
 */

import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';

import { SyncQueue, SyncStatus, SyncOperation } from './entities/sync-queue.entity';
import { Task } from '../tasks/entities/task.entity';
import { Project } from '../projects/entities/project.entity';

export interface SyncPayload {
  tasks?: TaskSyncItem[];
  projects?: ProjectSyncItem[];
  lastSyncAt?: Date;
}

export interface TaskSyncItem {
  id: string;
  syncVersion: number;
  data: Partial<Task>;
  operation: 'create' | 'update' | 'delete';
  clientUpdatedAt: Date;
}

export interface ProjectSyncItem {
  id: string;
  syncVersion: number;
  data: Partial<Project>;
  operation: 'create' | 'update' | 'delete';
  clientUpdatedAt: Date;
}

export interface SyncResult {
  tasks: {
    synced: Task[];
    conflicts: Array<{
      clientVersion: TaskSyncItem;
      serverVersion: Task;
    }>;
  };
  projects: {
    synced: Project[];
    conflicts: Array<{
      clientVersion: ProjectSyncItem;
      serverVersion: Project;
    }>;
  };
  serverTimestamp: Date;
}

@Injectable()
export class SyncService {
  constructor(
    @InjectRepository(SyncQueue)
    private readonly syncQueueRepository: Repository<SyncQueue>,
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
    @InjectRepository(Project)
    private readonly projectRepository: Repository<Project>,
  ) {}

  /**
   * Process a sync request from the client.
   * Applies client changes and returns the merged state.
   */
  async sync(userId: string, payload: SyncPayload): Promise<SyncResult> {
    const result: SyncResult = {
      tasks: { synced: [], conflicts: [] },
      projects: { synced: [], conflicts: [] },
      serverTimestamp: new Date(),
    };

    // Process task syncs
    if (payload.tasks && payload.tasks.length > 0) {
      for (const item of payload.tasks) {
        try {
          const taskResult = await this.syncTask(userId, item);
          if (taskResult.conflict) {
            result.tasks.conflicts.push({
              clientVersion: item,
              serverVersion: taskResult.serverVersion!,
            });
          } else if (taskResult.synced) {
            result.tasks.synced.push(taskResult.synced);
          }
        } catch (error) {
          // Log error and continue with other items
          console.error(`Failed to sync task ${item.id}:`, error);
        }
      }
    }

    // Process project syncs
    if (payload.projects && payload.projects.length > 0) {
      for (const item of payload.projects) {
        try {
          const projectResult = await this.syncProject(userId, item);
          if (projectResult.conflict) {
            result.projects.conflicts.push({
              clientVersion: item,
              serverVersion: projectResult.serverVersion!,
            });
          } else if (projectResult.synced) {
            result.projects.synced.push(projectResult.synced);
          }
        } catch (error) {
          console.error(`Failed to sync project ${item.id}:`, error);
        }
      }
    }

    return result;
  }

  /**
   * Sync a single task.
   */
  private async syncTask(
    userId: string,
    item: TaskSyncItem,
  ): Promise<{
    synced?: Task;
    conflict?: boolean;
    serverVersion?: Task;
  }> {
    const existing = await this.taskRepository.findOne({
      where: { id: item.id, userId },
    });

    if (item.operation === 'create') {
      if (existing) {
        // Already exists - check if same version
        if (existing.syncVersion !== item.syncVersion) {
          return { conflict: true, serverVersion: existing };
        }
        return { synced: existing };
      }

      const task = this.taskRepository.create({
        ...item.data,
        id: item.id,
        userId,
        syncVersion: 1,
      });
      const saved = await this.taskRepository.save(task);
      return { synced: saved };
    }

    if (item.operation === 'update') {
      if (!existing) {
        throw new BadRequestException(`Task ${item.id} not found`);
      }

      // Check for conflicts
      if (existing.syncVersion !== item.syncVersion) {
        // Conflict detected - server version is newer
        return { conflict: true, serverVersion: existing };
      }

      // Apply update
      Object.assign(existing, item.data);
      existing.syncVersion += 1;
      const saved = await this.taskRepository.save(existing);
      return { synced: saved };
    }

    if (item.operation === 'delete') {
      if (!existing) {
        // Already deleted
        return { synced: undefined };
      }

      if (existing.syncVersion !== item.syncVersion) {
        return { conflict: true, serverVersion: existing };
      }

      await this.taskRepository.softDelete(item.id);
      return { synced: undefined };
    }

    throw new BadRequestException(`Unknown operation: ${item.operation}`);
  }

  /**
   * Sync a single project.
   */
  private async syncProject(
    userId: string,
    item: ProjectSyncItem,
  ): Promise<{
    synced?: Project;
    conflict?: boolean;
    serverVersion?: Project;
  }> {
    const existing = await this.projectRepository.findOne({
      where: { id: item.id, userId },
    });

    if (item.operation === 'create') {
      if (existing) {
        if (existing.syncVersion !== item.syncVersion) {
          return { conflict: true, serverVersion: existing };
        }
        return { synced: existing };
      }

      const project = this.projectRepository.create({
        ...item.data,
        id: item.id,
        userId,
        syncVersion: 1,
      });
      const saved = await this.projectRepository.save(project);
      return { synced: saved };
    }

    if (item.operation === 'update') {
      if (!existing) {
        throw new BadRequestException(`Project ${item.id} not found`);
      }

      if (existing.syncVersion !== item.syncVersion) {
        return { conflict: true, serverVersion: existing };
      }

      Object.assign(existing, item.data);
      existing.syncVersion += 1;
      const saved = await this.projectRepository.save(existing);
      return { synced: saved };
    }

    if (item.operation === 'delete') {
      if (!existing) {
        return { synced: undefined };
      }

      if (existing.syncVersion !== item.syncVersion) {
        return { conflict: true, serverVersion: existing };
      }

      await this.projectRepository.softDelete(item.id);
      return { synced: undefined };
    }

    throw new BadRequestException(`Unknown operation: ${item.operation}`);
  }

  /**
   * Get all changes since a given timestamp.
   * Used for initial sync or catching up after being offline.
   */
  async getChangesSince(
    userId: string,
    since: Date,
  ): Promise<{
    tasks: Task[];
    projects: Project[];
    serverTimestamp: Date;
  }> {
    const tasks = await this.taskRepository.find({
      where: {
        userId,
        updatedAt: MoreThan(since),
      },
      withDeleted: true, // Include soft-deleted items
    });

    const projects = await this.projectRepository.find({
      where: {
        userId,
        updatedAt: MoreThan(since),
      },
      withDeleted: true,
    });

    return {
      tasks,
      projects,
      serverTimestamp: new Date(),
    };
  }

  /**
   * Queue a sync operation for retry.
   */
  async queueOperation(
    userId: string,
    entityType: string,
    entityId: string,
    operation: SyncOperation,
    payload: Record<string, unknown>,
  ): Promise<SyncQueue> {
    const item = this.syncQueueRepository.create({
      userId,
      entityType,
      entityId,
      operation,
      payload: payload as Record<string, any>,
      clientTimestamp: new Date(),
      status: SyncStatus.PENDING,
    });
    return this.syncQueueRepository.save(item);
  }

  /**
   * Get pending sync operations for a user.
   */
  async getPendingOperations(userId: string): Promise<SyncQueue[]> {
    return this.syncQueueRepository.find({
      where: { userId, status: SyncStatus.PENDING },
      order: { createdAt: 'ASC' },
    });
  }

  /**
   * Mark a sync operation as completed.
   */
  async markCompleted(id: string): Promise<void> {
    await this.syncQueueRepository.update(id, {
      status: SyncStatus.COMPLETED,
      processedAt: new Date(),
    });
  }

  /**
   * Mark a sync operation as failed.
   */
  async markFailed(id: string, error: string): Promise<void> {
    const item = await this.syncQueueRepository.findOne({ where: { id } });
    if (item) {
      item.status = SyncStatus.FAILED;
      item.retryCount += 1;
      item.errorMessage = error;
      await this.syncQueueRepository.save(item);
    }
  }
}
