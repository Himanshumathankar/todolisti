/**
 * =============================================================================
 * Tag Entity
 * =============================================================================
 * 
 * Represents a tag for categorizing tasks.
 * Tags can be applied across projects.
 * =============================================================================
 */

import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToMany,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';

import { User } from '../../users/entities/user.entity';
import { Task } from '../../tasks/entities/task.entity';

@Entity('tags')
@Index(['userId', 'name'])
export class Tag {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 100 })
  name: string;

  /**
   * Color for visual identification (hex format).
   */
  @Column({ type: 'varchar', length: 7, default: '#6B7280' })
  color: string;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  // Relations
  @Column({ type: 'uuid' })
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @ManyToMany(() => Task, (task) => task.tags)
  tasks: Task[];
}
