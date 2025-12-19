/**
 * =============================================================================
 * Permission Entity
 * =============================================================================
 * 
 * Represents PA (Personal Assistant) permissions.
 * Enables delegation of task management to assistants.
 * =============================================================================
 */

import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';

import { User } from '../../users/entities/user.entity';

/**
 * Permission levels for assistants.
 */
export enum PermissionLevel {
  VIEW = 'view',       // Can view tasks
  EDIT = 'edit',       // Can view and edit tasks
  FULL = 'full',       // Full control including delete
}

/**
 * Invitation status.
 */
export enum InvitationStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted',
  DECLINED = 'declined',
  EXPIRED = 'expired',
}

@Entity('permissions')
@Index(['ownerId', 'assistantId'])
export class Permission {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * Permission level granted to the assistant.
   */
  @Column({
    type: 'enum',
    enum: PermissionLevel,
    default: PermissionLevel.VIEW,
  })
  level: PermissionLevel;

  /**
   * Specific project IDs the assistant can access.
   * Null means access to all projects.
   */
  @Column({ type: 'jsonb', nullable: true })
  projectIds: string[];

  /**
   * Specific permissions (granular control).
   */
  @Column({ type: 'jsonb', nullable: true })
  permissions: {
    canCreateTasks?: boolean;
    canCompleteTasks?: boolean;
    canDeleteTasks?: boolean;
    canViewCalendar?: boolean;
    canManageProjects?: boolean;
  };

  /**
   * Whether the permission is currently active.
   */
  @Column({ type: 'boolean', default: true })
  isActive: boolean;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt: Date;

  // Relations
  /**
   * The user who owns the tasks/projects.
   */
  @Column({ type: 'uuid' })
  ownerId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'ownerId' })
  owner: User;

  /**
   * The assistant who is granted access.
   */
  @Column({ type: 'uuid' })
  assistantId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'assistantId' })
  assistant: User;
}

@Entity('permission_invitations')
export class PermissionInvitation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * Email of the invited assistant.
   */
  @Column({ type: 'varchar', length: 255 })
  email: string;

  /**
   * Proposed permission level.
   */
  @Column({
    type: 'enum',
    enum: PermissionLevel,
    default: PermissionLevel.VIEW,
  })
  level: PermissionLevel;

  /**
   * Invitation status.
   */
  @Column({
    type: 'enum',
    enum: InvitationStatus,
    default: InvitationStatus.PENDING,
  })
  status: InvitationStatus;

  /**
   * Unique invitation token.
   */
  @Column({ type: 'varchar', length: 255 })
  @Index()
  token: string;

  /**
   * When the invitation expires.
   */
  @Column({ type: 'timestamp with time zone' })
  expiresAt: Date;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt: Date;

  // Relations
  @Column({ type: 'uuid' })
  ownerId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'ownerId' })
  owner: User;
}
