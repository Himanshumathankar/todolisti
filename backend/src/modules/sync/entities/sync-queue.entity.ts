/**
 * =============================================================================
 * Sync Queue Entity
 * =============================================================================
 * 
 * Stores pending sync operations for offline support.
 * Operations are queued and processed when connectivity is restored.
 * =============================================================================
 */

import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';

import { User } from '../../users/entities/user.entity';

/**
 * Types of sync operations.
 */
export enum SyncOperation {
  CREATE = 'create',
  UPDATE = 'update',
  DELETE = 'delete',
}

/**
 * Sync status.
 */
export enum SyncStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CONFLICT = 'conflict',
}

@Entity('sync_queue')
@Index(['userId', 'status'])
@Index(['createdAt'])
export class SyncQueue {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * Type of operation.
   */
  @Column({
    type: 'enum',
    enum: SyncOperation,
  })
  operation: SyncOperation;

  /**
   * Entity type (task, project, tag).
   */
  @Column({ type: 'varchar', length: 50 })
  entityType: string;

  /**
   * Entity ID being synced.
   */
  @Column({ type: 'uuid' })
  entityId: string;

  /**
   * Payload containing the changes.
   */
  @Column({ type: 'jsonb' })
  payload: Record<string, any>;

  /**
   * Client timestamp when the change was made.
   */
  @Column({ type: 'timestamp with time zone' })
  clientTimestamp: Date;

  /**
   * Current sync status.
   */
  @Column({
    type: 'enum',
    enum: SyncStatus,
    default: SyncStatus.PENDING,
  })
  status: SyncStatus;

  /**
   * Number of retry attempts.
   */
  @Column({ type: 'int', default: 0 })
  retryCount: number;

  /**
   * Error message if sync failed.
   */
  @Column({ type: 'text', nullable: true })
  errorMessage: string;

  /**
   * Conflict resolution data if conflict occurred.
   */
  @Column({ type: 'jsonb', nullable: true })
  conflictData: {
    serverVersion: number;
    clientVersion: number;
    serverState: Record<string, any>;
  };

  /**
   * When the operation was processed.
   */
  @Column({ type: 'timestamp with time zone', nullable: true })
  processedAt: Date;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  // Relations
  @Column({ type: 'uuid' })
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;
}
