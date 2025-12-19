/**
 * =============================================================================
 * Update Task DTO
 * =============================================================================
 * 
 * Data transfer object for updating a task.
 * All fields are optional.
 * =============================================================================
 */

import { PartialType } from '@nestjs/swagger';
import { CreateTaskDto } from './create-task.dto';

export class UpdateTaskDto extends PartialType(CreateTaskDto) {}
