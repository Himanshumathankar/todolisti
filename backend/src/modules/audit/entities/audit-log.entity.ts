/**
 * =============================================================================
 * Audit Log Entity
 * =============================================================================
 * 
 * Records all significant actions for accountability.
 * Required for PA/Assistant feature compliance.
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
 * Types of actions that can be audited.
 */
export enum AuditAction {
  // Task actions
  TASK_CREATE = 'task.create',
  TASK_UPDATE = 'task.update',
  TASK_DELETE = 'task.delete',
  TASK_COMPLETE = 'task.complete',
  TASK_UNCOMPLETE = 'task.uncomplete',
  
  // Project actions
  PROJECT_CREATE = 'project.create',
  PROJECT_UPDATE = 'project.update',
  PROJECT_DELETE = 'project.delete',
  PROJECT_ARCHIVE = 'project.archive',
  
  // Permission actions
  PERMISSION_GRANT = 'permission.grant',
  PERMISSION_REVOKE = 'permission.revoke',
  PERMISSION_UPDATE = 'permission.update',
  INVITATION_SEND = 'invitation.send',
  INVITATION_ACCEPT = 'invitation.accept',
  INVITATION_DECLINE = 'invitation.decline',
  
  // Calendar actions
  CALENDAR_SYNC = 'calendar.sync',
  CALENDAR_EVENT_CREATE = 'calendar.event.create',
  CALENDAR_EVENT_UPDATE = 'calendar.event.update',
  
  // Auth actions
  USER_LOGIN = 'user.login',
  USER_LOGOUT = 'user.logout',
}

@Entity('audit_logs')
@Index(['userId', 'createdAt'])
@Index(['targetUserId', 'createdAt'])
@Index(['action', 'createdAt'])
export class AuditLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * The action that was performed.
   */
  @Column({
    type: 'enum',
    enum: AuditAction,
  })
  action: AuditAction;

  /**
   * Entity type affected (task, project, etc.).
   */
  @Column({ type: 'varchar', length: 50 })
  entityType: string;

  /**
   * ID of the affected entity.
   */
  @Column({ type: 'uuid', nullable: true })
  entityId: string;

  /**
   * Previous state (JSON snapshot).
   */
  @Column({ type: 'jsonb', nullable: true })
  previousState: Record<string, any>;

  /**
   * New state (JSON snapshot).
   */
  @Column({ type: 'jsonb', nullable: true })
  newState: Record<string, any>;

  /**
   * Additional metadata about the action.
   */
  @Column({ type: 'jsonb', nullable: true })
  metadata: {
    ipAddress?: string;
    userAgent?: string;
    reason?: string;
  };

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  // Relations
  /**
   * User who performed the action.
   */
  @Column({ type: 'uuid' })
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  /**
   * Target user (for PA actions on behalf of owner).
   */
  @Column({ type: 'uuid', nullable: true })
  targetUserId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'targetUserId' })
  targetUser: User;
}
