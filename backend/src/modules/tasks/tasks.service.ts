/**
 * =============================================================================
 * Tasks Service
 * =============================================================================
 * 
 * Business logic for task management.
 * Supports CRUD, subtasks, and sync operations.
 * =============================================================================
 */

import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In, IsNull, Not } from 'typeorm';

import { Task, TaskPriority } from './entities/task.entity';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { PermissionsService } from '../permissions/permissions.service';
import { PermissionLevel } from '../permissions/entities/permission.entity';
import { AuditService } from '../audit/audit.service';
import { AuditAction } from '../audit/entities/audit-log.entity';

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
    private readonly permissionsService: PermissionsService,
    private readonly auditService: AuditService,
  ) {}

  /**
   * Create a new task.
   */
  async create(
    userId: string,
    dto: CreateTaskDto,
    actingUserId?: string,
  ): Promise<Task> {
    // Check permissions if acting as PA
    if (actingUserId && actingUserId !== userId) {
      const hasPermission = await this.permissionsService.checkPermission(
        actingUserId,
        userId,
        PermissionLevel.EDIT,
      );
      if (!hasPermission) {
        throw new ForbiddenException('Not authorized to create tasks for this user');
      }
    }
    
    const task = this.taskRepository.create({
      ...dto,
      userId,
      priority: dto.priority ?? TaskPriority.NONE,
    });
    
    const savedTask = await this.taskRepository.save(task);
    
    // Audit log
    await this.auditService.log({
      action: AuditAction.TASK_CREATE,
      entityType: 'task',
      entityId: savedTask.id,
      userId: actingUserId || userId,
      targetUserId: actingUserId && actingUserId !== userId ? userId : undefined,
      newState: savedTask as unknown as Record<string, unknown>,
    });
    
    return savedTask;
  }

  /**
   * Find all tasks for a user.
   */
  async findAll(
    userId: string,
    options?: {
      projectId?: string;
      completed?: boolean;
      priority?: TaskPriority;
      dueFrom?: Date;
      dueTo?: Date;
      parentId?: string | null;
    },
  ): Promise<Task[]> {
    const query = this.taskRepository
      .createQueryBuilder('task')
      .where('task.userId = :userId', { userId })
      .andWhere('task.deletedAt IS NULL');
    
    if (options?.projectId) {
      query.andWhere('task.projectId = :projectId', {
        projectId: options.projectId,
      });
    }
    
    if (options?.completed !== undefined) {
      if (options.completed) {
        query.andWhere('task.completedAt IS NOT NULL');
      } else {
        query.andWhere('task.completedAt IS NULL');
      }
    }
    
    if (options?.priority !== undefined) {
      query.andWhere('task.priority = :priority', {
        priority: options.priority,
      });
    }
    
    if (options?.dueFrom) {
      query.andWhere('task.dueDate >= :dueFrom', { dueFrom: options.dueFrom });
    }
    
    if (options?.dueTo) {
      query.andWhere('task.dueDate <= :dueTo', { dueTo: options.dueTo });
    }
    
    if (options?.parentId !== undefined) {
      if (options.parentId === null) {
        query.andWhere('task.parentId IS NULL');
      } else {
        query.andWhere('task.parentId = :parentId', {
          parentId: options.parentId,
        });
      }
    }
    
    query.orderBy('task.sortOrder', 'ASC').addOrderBy('task.createdAt', 'DESC');
    
    return query.getMany();
  }

  /**
   * Find a single task by ID.
   */
  async findOne(id: string, userId: string): Promise<Task> {
    const task = await this.taskRepository.findOne({
      where: { id, userId },
      relations: ['subtasks', 'tags', 'reminders'],
    });
    
    if (!task) {
      throw new NotFoundException('Task not found');
    }
    
    return task;
  }

  /**
   * Update a task.
   */
  async update(
    id: string,
    userId: string,
    dto: UpdateTaskDto,
    actingUserId?: string,
  ): Promise<Task> {
    const task = await this.findOne(id, userId);
    
    // Check permissions if acting as PA
    if (actingUserId && actingUserId !== userId) {
      const hasPermission = await this.permissionsService.checkPermission(
        actingUserId,
        userId,
        PermissionLevel.EDIT,
      );
      if (!hasPermission) {
        throw new ForbiddenException('Not authorized to edit tasks for this user');
      }
    }
    
    const previousState = { ...task };
    
    // Update fields
    Object.assign(task, dto);
    task.syncVersion += 1;
    
    const savedTask = await this.taskRepository.save(task);
    
    // Audit log
    await this.auditService.log({
      action: AuditAction.TASK_UPDATE,
      entityType: 'task',
      entityId: savedTask.id,
      userId: actingUserId || userId,
      targetUserId: actingUserId && actingUserId !== userId ? userId : undefined,
      previousState: previousState as unknown as Record<string, unknown>,
      newState: savedTask as unknown as Record<string, unknown>,
    });
    
    return savedTask;
  }

  /**
   * Complete a task.
   */
  async complete(
    id: string,
    userId: string,
    actingUserId?: string,
  ): Promise<Task> {
    const task = await this.findOne(id, userId);
    
    // Check permissions if acting as PA
    if (actingUserId && actingUserId !== userId) {
      const hasPermission = await this.permissionsService.checkPermission(
        actingUserId,
        userId,
        PermissionLevel.EDIT,
      );
      if (!hasPermission) {
        throw new ForbiddenException('Not authorized to complete tasks for this user');
      }
    }
    
    task.completedAt = new Date();
    task.syncVersion += 1;
    
    const savedTask = await this.taskRepository.save(task);
    
    // Audit log
    await this.auditService.log({
      action: AuditAction.TASK_COMPLETE,
      entityType: 'task',
      entityId: savedTask.id,
      userId: actingUserId || userId,
      targetUserId: actingUserId && actingUserId !== userId ? userId : undefined,
    });
    
    return savedTask;
  }

  /**
   * Uncomplete a task.
   */
  async uncomplete(
    id: string,
    userId: string,
    actingUserId?: string,
  ): Promise<Task> {
    const task = await this.findOne(id, userId);
    
    (task as any).completedAt = null;
    task.syncVersion += 1;
    
    const savedTask = await this.taskRepository.save(task);
    
    // Audit log
    await this.auditService.log({
      action: AuditAction.TASK_UNCOMPLETE,
      entityType: 'task',
      entityId: savedTask.id,
      userId: actingUserId || userId,
      targetUserId: actingUserId && actingUserId !== userId ? userId : undefined,
    });
    
    return savedTask;
  }

  /**
   * Soft delete a task.
   */
  async remove(
    id: string,
    userId: string,
    actingUserId?: string,
  ): Promise<void> {
    const task = await this.findOne(id, userId);
    
    // Check permissions if acting as PA
    if (actingUserId && actingUserId !== userId) {
      const hasPermission = await this.permissionsService.checkPermission(
        actingUserId,
        userId,
        PermissionLevel.FULL,
      );
      if (!hasPermission) {
        throw new ForbiddenException('Not authorized to delete tasks for this user');
      }
    }
    
    await this.taskRepository.softDelete(id);
    
    // Audit log
    await this.auditService.log({
      action: AuditAction.TASK_DELETE,
      entityType: 'task',
      entityId: id,
      userId: actingUserId || userId,
      targetUserId: actingUserId && actingUserId !== userId ? userId : undefined,
      previousState: task as unknown as Record<string, unknown>,
    });
  }

  /**
   * Get tasks modified since a given timestamp (for sync).
   */
  async getModifiedSince(
    userId: string,
    since: Date,
  ): Promise<Task[]> {
    return this.taskRepository.find({
      where: {
        userId,
        updatedAt: Not(IsNull()),
      },
      withDeleted: true, // Include soft-deleted for sync
    });
  }

  /**
   * Bulk upsert tasks (for sync).
   */
  async bulkUpsert(
    userId: string,
    tasks: Partial<Task>[],
  ): Promise<Task[]> {
    const result: Task[] = [];
    
    for (const taskData of tasks) {
      const existing = await this.taskRepository.findOne({
        where: { id: taskData.id, userId },
        withDeleted: true,
      });
      
      if (existing) {
        // Conflict detection
        if (taskData.syncVersion && taskData.syncVersion <= existing.syncVersion) {
          // Client version is older, skip or handle conflict
          continue;
        }
        
        Object.assign(existing, taskData);
        existing.syncVersion += 1;
        result.push(await this.taskRepository.save(existing));
      } else {
        const task = this.taskRepository.create({
          ...taskData,
          userId,
        });
        result.push(await this.taskRepository.save(task));
      }
    }
    
    return result;
  }
}
