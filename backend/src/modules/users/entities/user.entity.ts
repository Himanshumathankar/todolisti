/**
 * =============================================================================
 * User Entity
 * =============================================================================
 * 
 * Represents a user in the system.
 * Supports Google OAuth and stores calendar sync tokens.
 * =============================================================================
 */

import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  Index,
} from 'typeorm';

import { Task } from '../../tasks/entities/task.entity';
import { Project } from '../../projects/entities/project.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  @Index()
  email: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  name: string;

  @Column({ type: 'varchar', length: 500, nullable: true })
  avatarUrl: string;

  /**
   * Google OAuth ID for authentication.
   */
  @Column({ type: 'varchar', length: 255, nullable: true })
  @Index()
  googleId: string;

  /**
   * Encrypted Google Calendar refresh token.
   * Used for background calendar sync.
   */
  @Column({ type: 'text', nullable: true })
  googleRefreshToken: string;

  /**
   * Google Calendar access token (short-lived).
   */
  @Column({ type: 'text', nullable: true })
  googleAccessToken: string;

  /**
   * Whether the user has connected Google Calendar.
   */
  @Column({ type: 'boolean', default: false })
  calendarConnected: boolean;

  /**
   * User's preferred timezone.
   */
  @Column({ type: 'varchar', length: 50, default: 'UTC' })
  timezone: string;

  /**
   * User's notification preferences (JSON).
   */
  @Column({ type: 'jsonb', nullable: true })
  notificationSettings: Record<string, any>;

  /**
   * Whether the user account is active.
   */
  @Column({ type: 'boolean', default: true })
  isActive: boolean;

  /**
   * Last successful login timestamp.
   */
  @Column({ type: 'timestamp with time zone', nullable: true })
  lastLoginAt: Date;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt: Date;

  // Relations
  @OneToMany(() => Task, (task) => task.user)
  tasks: Task[];

  @OneToMany(() => Project, (project) => project.user)
  projects: Project[];
}
