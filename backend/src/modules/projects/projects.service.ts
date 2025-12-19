/**
 * =============================================================================
 * Projects Service
 * =============================================================================
 * 
 * Business logic for project and tag management.
 * =============================================================================
 */

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Project } from './entities/project.entity';
import { Tag } from './entities/tag.entity';

@Injectable()
export class ProjectsService {
  constructor(
    @InjectRepository(Project)
    private readonly projectRepository: Repository<Project>,
    @InjectRepository(Tag)
    private readonly tagRepository: Repository<Tag>,
  ) {}

  // -------------------------------------------------------------------------
  // Projects
  // -------------------------------------------------------------------------

  async createProject(
    userId: string,
    data: Partial<Project>,
  ): Promise<Project> {
    const project = this.projectRepository.create({
      ...data,
      userId,
    });
    return this.projectRepository.save(project);
  }

  async findAllProjects(userId: string): Promise<Project[]> {
    return this.projectRepository.find({
      where: { userId },
      order: { sortOrder: 'ASC', createdAt: 'DESC' },
    });
  }

  async findProjectById(id: string, userId: string): Promise<Project> {
    const project = await this.projectRepository.findOne({
      where: { id, userId },
      relations: ['tasks'],
    });
    
    if (!project) {
      throw new NotFoundException('Project not found');
    }
    
    return project;
  }

  async updateProject(
    id: string,
    userId: string,
    data: Partial<Project>,
  ): Promise<Project> {
    const project = await this.findProjectById(id, userId);
    
    Object.assign(project, data);
    project.syncVersion += 1;
    
    return this.projectRepository.save(project);
  }

  async archiveProject(id: string, userId: string): Promise<Project> {
    return this.updateProject(id, userId, { isArchived: true });
  }

  async deleteProject(id: string, userId: string): Promise<void> {
    await this.findProjectById(id, userId);
    await this.projectRepository.softDelete(id);
  }

  // -------------------------------------------------------------------------
  // Tags
  // -------------------------------------------------------------------------

  async createTag(userId: string, data: Partial<Tag>): Promise<Tag> {
    const tag = this.tagRepository.create({
      ...data,
      userId,
    });
    return this.tagRepository.save(tag);
  }

  async findAllTags(userId: string): Promise<Tag[]> {
    return this.tagRepository.find({
      where: { userId },
      order: { name: 'ASC' },
    });
  }

  async findTagById(id: string, userId: string): Promise<Tag> {
    const tag = await this.tagRepository.findOne({
      where: { id, userId },
    });
    
    if (!tag) {
      throw new NotFoundException('Tag not found');
    }
    
    return tag;
  }

  async updateTag(
    id: string,
    userId: string,
    data: Partial<Tag>,
  ): Promise<Tag> {
    const tag = await this.findTagById(id, userId);
    Object.assign(tag, data);
    return this.tagRepository.save(tag);
  }

  async deleteTag(id: string, userId: string): Promise<void> {
    await this.findTagById(id, userId);
    await this.tagRepository.delete(id);
  }
}
