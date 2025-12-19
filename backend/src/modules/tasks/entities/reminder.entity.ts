/**
 * =============================================================================
 * Reminder Entity
 * =============================================================================
 * 
 * Represents a reminder for a task.
 * Supports multiple reminders per task at different times.
 * =============================================================================
 */

import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';

import { Task } from './task.entity';

/**
 * Reminder type.
 */
export enum ReminderType {
  NOTIFICATION = 'notification',
  EMAIL = 'email',
}

@Entity('reminders')
export class Reminder {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * When the reminder should trigger.
   */
  @Column({ type: 'timestamp with time zone' })
  reminderAt: Date;

  /**
   * Type of reminder (notification, email).
   */
  @Column({
    type: 'enum',
    enum: ReminderType,
    default: ReminderType.NOTIFICATION,
  })
  type: ReminderType;

  /**
   * Whether the reminder has been sent.
   */
  @Column({ type: 'boolean', default: false })
  isSent: boolean;

  /**
   * When the reminder was sent.
   */
  @Column({ type: 'timestamp with time zone', nullable: true })
  sentAt: Date;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  // Relations
  @Column({ type: 'uuid' })
  taskId: string;

  @ManyToOne(() => Task, (task) => task.reminders, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'taskId' })
  task: Task;
}
