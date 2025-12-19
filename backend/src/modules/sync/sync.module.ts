/**
 * =============================================================================
 * Sync Module
 * =============================================================================
 * 
 * Handles offline-first synchronization between client and server.
 * =============================================================================
 */

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { SyncController } from './sync.controller';
import { SyncService } from './sync.service';
import { SyncQueue } from './entities/sync-queue.entity';
import { Task } from '../tasks/entities/task.entity';
import { Project } from '../projects/entities/project.entity';

@Module({
  imports: [TypeOrmModule.forFeature([SyncQueue, Task, Project])],
  controllers: [SyncController],
  providers: [SyncService],
  exports: [SyncService],
})
export class SyncModule {}
