/**
 * =============================================================================
 * Project Entity
 * =============================================================================
 * 
 * Represents a project for organizing tasks.
 * Supports hierarchical projects and custom colors.
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
  JoinColumn,
  Index,
} from 'typeorm';

import { User } from '../../users/entities/user.entity';
import { Task } from '../../tasks/entities/task.entity';

@Entity('projects')
@Index(['userId', 'deletedAt'])
export class Project {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  /**
   * Color for visual identification (hex format).
   */
  @Column({ type: 'varchar', length: 7, default: '#6B7280' })
  color: string;

  /**
   * Icon name (Material Icons).
   */
  @Column({ type: 'varchar', length: 50, nullable: true })
  icon: string;

  /**
   * Whether the project is archived.
   */
  @Column({ type: 'boolean', default: false })
  isArchived: boolean;

  /**
   * Sort order for project list.
   */
  @Column({ type: 'int', default: 0 })
  sortOrder: number;

  /**
   * Sync version for conflict detection.
   */
  @Column({ type: 'int', default: 0 })
  syncVersion: number;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt: Date;

  @DeleteDateColumn({ type: 'timestamp with time zone' })
  deletedAt: Date;

  // Relations
  @Column({ type: 'uuid' })
  userId: string;

  @ManyToOne(() => User, (user) => user.projects)
  @JoinColumn({ name: 'userId' })
  user: User;

  @OneToMany(() => Task, (task) => task.project)
  tasks: Task[];
}
