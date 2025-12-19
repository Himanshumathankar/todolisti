/**
 * =============================================================================
 * Calendar Module
 * =============================================================================
 * 
 * Handles Google Calendar integration for two-way sync.
 * =============================================================================
 */

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HttpModule } from '@nestjs/axios';

import { CalendarController } from './calendar.controller';
import { CalendarService } from './calendar.service';
import { Task } from '../tasks/entities/task.entity';
import { User } from '../users/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Task, User]),
    HttpModule,
  ],
  controllers: [CalendarController],
  providers: [CalendarService],
  exports: [CalendarService],
})
export class CalendarModule {}
