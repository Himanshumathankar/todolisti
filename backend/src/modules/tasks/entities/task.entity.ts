/**
 * =============================================================================
 * Task Entity
 * =============================================================================
 * 
 * Represents a task in the system.
 * Supports subtasks, recurrence, priorities, and sync tracking.
 * =============================================================================
 */

import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  ManyToOne,
  OneToMany,
  ManyToMany,
  JoinTable,
  JoinColumn,
  Index,
} from 'typeorm';

import { User } from '../../users/entities/user.entity';
import { Project } from '../../projects/entities/project.entity';
import { Tag } from '../../projects/entities/tag.entity';
import { Reminder } from './reminder.entity';

/**
 * Task priority levels (0-4).
 * Higher values indicate higher priority.
 */
export enum TaskPriority {
  NONE = 0,
  LOW = 1,
  MEDIUM = 2,
  HIGH = 3,
  URGENT = 4,
}

@Entity('tasks')
@Index(['userId', 'deletedAt'])
@Index(['userId', 'completedAt'])
@Index(['userId', 'dueDate'])
export class Task {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 500 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  /**
   * Task priority level.
   */
  @Column({
    type: 'enum',
    enum: TaskPriority,
    default: TaskPriority.NONE,
  })
  priority: TaskPriority;

  /**
   * Due date with timezone.
   */
  @Column({ type: 'timestamp with time zone', nullable: true })
  dueDate: Date;

  /**
   * Completion timestamp (null if not completed).
   */
  @Column({ type: 'timestamp with time zone', nullable: true })
  completedAt: Date;

  /**
   * Recurrence rule (RRULE format or simple string).
   * Examples: 'daily', 'weekly', 'RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR'
   */
  @Column({ type: 'varchar', length: 255, nullable: true })
  recurrence: string;

  /**
   * Parent task ID for subtasks.
   */
  @Column({ type: 'uuid', nullable: true })
  parentId: string;

  /**
   * Sort order within the same parent/project.
   */
  @Column({ type: 'int', default: 0 })
  sortOrder: number;

  /**
   * Google Calendar event ID for synced tasks.
   */
  @Column({ type: 'varchar', length: 255, nullable: true })
  googleEventId: string;

  /**
   * Sync version for conflict detection.
   * Incremented on each update.
   */
  @Column({ type: 'int', default: 0 })
  syncVersion: number;

  /**
   * Last sync timestamp.
   */
  @Column({ type: 'timestamp with time zone', nullable: true })
  lastSyncedAt: Date;

  /**
   * Custom metadata (JSON).
   */
  @Column({ type: 'jsonb', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt: Date;

  /**
   * Soft delete timestamp.
   * Tasks are not permanently deleted immediately.
   */
  @DeleteDateColumn({ type: 'timestamp with time zone' })
  deletedAt: Date;

  // Relations
  @Column({ type: 'uuid' })
  userId: string;

  @ManyToOne(() => User, (user) => user.tasks)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ type: 'uuid', nullable: true })
  projectId: string;

  @ManyToOne(() => Project, (project) => project.tasks, { nullable: true })
  @JoinColumn({ name: 'projectId' })
  project: Project;

  @ManyToOne(() => Task, (task) => task.subtasks, { nullable: true })
  @JoinColumn({ name: 'parentId' })
  parent: Task;

  @OneToMany(() => Task, (task) => task.parent)
  subtasks: Task[];

  @ManyToMany(() => Tag, (tag) => tag.tasks)
  @JoinTable({
    name: 'task_tags',
    joinColumn: { name: 'taskId' },
    inverseJoinColumn: { name: 'tagId' },
  })
  tags: Tag[];

  @OneToMany(() => Reminder, (reminder) => reminder.task)
  reminders: Reminder[];

  // Computed properties (not stored in DB)
  get isCompleted(): boolean {
    return this.completedAt !== null;
  }

  get isOverdue(): boolean {
    if (!this.dueDate || this.completedAt) return false;
    return new Date() > this.dueDate;
  }
}
