/**
 * =============================================================================
 * Create Task DTO
 * =============================================================================
 * 
 * Data transfer object for creating a new task.
 * =============================================================================
 */

import {
  IsString,
  IsOptional,
  IsEnum,
  IsUUID,
  IsDateString,
  IsInt,
  IsObject,
  MaxLength,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

import { TaskPriority } from '../entities/task.entity';

export class CreateTaskDto {
  @ApiProperty({
    description: 'Task title',
    example: 'Review quarterly report',
    maxLength: 500,
  })
  @IsString()
  @MaxLength(500)
  title: string;

  @ApiPropertyOptional({
    description: 'Task description',
    example: 'Check all figures and prepare summary',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    description: 'Task priority (0-4)',
    enum: TaskPriority,
    example: TaskPriority.MEDIUM,
  })
  @IsOptional()
  @IsEnum(TaskPriority)
  priority?: TaskPriority;

  @ApiPropertyOptional({
    description: 'Due date (ISO 8601)',
    example: '2024-01-15T10:00:00.000Z',
  })
  @IsOptional()
  @IsDateString()
  dueDate?: string;

  @ApiPropertyOptional({
    description: 'Recurrence rule',
    example: 'weekly',
  })
  @IsOptional()
  @IsString()
  recurrence?: string;

  @ApiPropertyOptional({
    description: 'Parent task ID for subtasks',
  })
  @IsOptional()
  @IsUUID()
  parentId?: string;

  @ApiPropertyOptional({
    description: 'Project ID',
  })
  @IsOptional()
  @IsUUID()
  projectId?: string;

  @ApiPropertyOptional({
    description: 'Sort order',
    example: 0,
  })
  @IsOptional()
  @IsInt()
  sortOrder?: number;

  @ApiPropertyOptional({
    description: 'Custom metadata',
  })
  @IsOptional()
  @IsObject()
  metadata?: Record<string, any>;
}
