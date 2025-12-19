/**
 * =============================================================================
 * Projects Controller
 * =============================================================================
 * 
 * HTTP endpoints for project and tag management.
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
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';

import { ProjectsService } from './projects.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';

@ApiTags('projects')
@Controller('projects')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('access-token')
export class ProjectsController {
  constructor(private readonly projectsService: ProjectsService) {}

  // -------------------------------------------------------------------------
  // Projects
  // -------------------------------------------------------------------------

  @Post()
  @ApiOperation({ summary: 'Create a new project' })
  @ApiResponse({ status: 201, description: 'Project created' })
  async createProject(
    @CurrentUser() user: User,
    @Body() dto: { name: string; description?: string; color?: string; icon?: string },
  ) {
    return this.projectsService.createProject(user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all projects' })
  @ApiResponse({ status: 200, description: 'List of projects' })
  async findAllProjects(@CurrentUser() user: User) {
    return this.projectsService.findAllProjects(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a project by ID' })
  @ApiResponse({ status: 200, description: 'Project details' })
  async findProjectById(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ) {
    return this.projectsService.findProjectById(id, user.id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a project' })
  @ApiResponse({ status: 200, description: 'Project updated' })
  async updateProject(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: { name?: string; description?: string; color?: string; icon?: string },
  ) {
    return this.projectsService.updateProject(id, user.id, dto);
  }

  @Post(':id/archive')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Archive a project' })
  @ApiResponse({ status: 200, description: 'Project archived' })
  async archiveProject(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ) {
    return this.projectsService.archiveProject(id, user.id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a project' })
  @ApiResponse({ status: 204, description: 'Project deleted' })
  async deleteProject(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ) {
    return this.projectsService.deleteProject(id, user.id);
  }

  // -------------------------------------------------------------------------
  // Tags
  // -------------------------------------------------------------------------

  @Post('tags')
  @ApiOperation({ summary: 'Create a new tag' })
  @ApiResponse({ status: 201, description: 'Tag created' })
  async createTag(
    @CurrentUser() user: User,
    @Body() dto: { name: string; color?: string },
  ) {
    return this.projectsService.createTag(user.id, dto);
  }

  @Get('tags')
  @ApiOperation({ summary: 'Get all tags' })
  @ApiResponse({ status: 200, description: 'List of tags' })
  async findAllTags(@CurrentUser() user: User) {
    return this.projectsService.findAllTags(user.id);
  }

  @Patch('tags/:id')
  @ApiOperation({ summary: 'Update a tag' })
  @ApiResponse({ status: 200, description: 'Tag updated' })
  async updateTag(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: { name?: string; color?: string },
  ) {
    return this.projectsService.updateTag(id, user.id, dto);
  }

  @Delete('tags/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a tag' })
  @ApiResponse({ status: 204, description: 'Tag deleted' })
  async deleteTag(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ) {
    return this.projectsService.deleteTag(id, user.id);
  }
}
