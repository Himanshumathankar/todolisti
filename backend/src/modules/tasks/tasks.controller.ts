/**
 * =============================================================================
 * Tasks Controller
 * =============================================================================
 * 
 * HTTP endpoints for task management.
 * =============================================================================
 */

import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';

import { TasksService } from './tasks.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { TaskPriority } from './entities/task.entity';

@ApiTags('tasks')
@Controller('tasks')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('access-token')
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  /**
   * Create a new task.
   */
  @Post()
  @ApiOperation({ summary: 'Create a new task' })
  @ApiResponse({ status: 201, description: 'Task created successfully' })
  async create(
    @CurrentUser() user: User,
    @Body() dto: CreateTaskDto,
    @Query('forUserId') forUserId?: string,
  ) {
    const userId = forUserId || user.id;
    const actingUserId = forUserId ? user.id : undefined;
    
    return this.tasksService.create(userId, dto, actingUserId);
  }

  /**
   * Get all tasks.
   */
  @Get()
  @ApiOperation({ summary: 'Get all tasks' })
  @ApiResponse({ status: 200, description: 'List of tasks' })
  @ApiQuery({ name: 'projectId', required: false })
  @ApiQuery({ name: 'completed', required: false, type: Boolean })
  @ApiQuery({ name: 'priority', required: false, enum: TaskPriority })
  @ApiQuery({ name: 'parentId', required: false })
  async findAll(
    @CurrentUser() user: User,
    @Query('forUserId') forUserId?: string,
    @Query('projectId') projectId?: string,
    @Query('completed') completed?: boolean,
    @Query('priority') priority?: TaskPriority,
    @Query('parentId') parentId?: string,
  ) {
    const userId = forUserId || user.id;
    
    return this.tasksService.findAll(userId, {
      projectId,
      completed,
      priority,
      parentId: parentId === 'null' ? null : parentId,
    });
  }

  /**
   * Get a single task.
   */
  @Get(':id')
  @ApiOperation({ summary: 'Get a task by ID' })
  @ApiResponse({ status: 200, description: 'Task details' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async findOne(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Query('forUserId') forUserId?: string,
  ) {
    const userId = forUserId || user.id;
    return this.tasksService.findOne(id, userId);
  }

  /**
   * Update a task.
   */
  @Patch(':id')
  @ApiOperation({ summary: 'Update a task' })
  @ApiResponse({ status: 200, description: 'Task updated successfully' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async update(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: UpdateTaskDto,
    @Query('forUserId') forUserId?: string,
  ) {
    const userId = forUserId || user.id;
    const actingUserId = forUserId ? user.id : undefined;
    
    return this.tasksService.update(id, userId, dto, actingUserId);
  }

  /**
   * Complete a task.
   */
  @Post(':id/complete')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark task as complete' })
  @ApiResponse({ status: 200, description: 'Task completed' })
  async complete(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Query('forUserId') forUserId?: string,
  ) {
    const userId = forUserId || user.id;
    const actingUserId = forUserId ? user.id : undefined;
    
    return this.tasksService.complete(id, userId, actingUserId);
  }

  /**
   * Uncomplete a task.
   */
  @Post(':id/uncomplete')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark task as incomplete' })
  @ApiResponse({ status: 200, description: 'Task uncompleted' })
  async uncomplete(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Query('forUserId') forUserId?: string,
  ) {
    const userId = forUserId || user.id;
    const actingUserId = forUserId ? user.id : undefined;
    
    return this.tasksService.uncomplete(id, userId, actingUserId);
  }

  /**
   * Delete a task.
   */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a task' })
  @ApiResponse({ status: 204, description: 'Task deleted' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async remove(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Query('forUserId') forUserId?: string,
  ) {
    const userId = forUserId || user.id;
    const actingUserId = forUserId ? user.id : undefined;
    
    return this.tasksService.remove(id, userId, actingUserId);
  }
}
