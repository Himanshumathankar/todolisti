/**
 * =============================================================================
 * Calendar Controller
 * =============================================================================
 * 
 * HTTP endpoints for Google Calendar integration.
 * =============================================================================
 */

import {
  Controller,
  Get,
  Post,
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
} from '@nestjs/swagger';

import { CalendarService } from './calendar.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';

@ApiTags('calendar')
@Controller('calendar')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('access-token')
export class CalendarController {
  constructor(private readonly calendarService: CalendarService) {}

  // -------------------------------------------------------------------------
  // Calendar List
  // -------------------------------------------------------------------------

  @Get('list')
  @ApiOperation({ summary: 'Get user calendar list' })
  @ApiResponse({ status: 200, description: 'List of calendars' })
  async getCalendarList(@CurrentUser() user: User) {
    return this.calendarService.getCalendarList(user.id);
  }

  // -------------------------------------------------------------------------
  // Events
  // -------------------------------------------------------------------------

  @Get('events')
  @ApiOperation({ summary: 'Get calendar events' })
  @ApiResponse({ status: 200, description: 'List of events' })
  async getEvents(
    @CurrentUser() user: User,
    @Query('calendarId') calendarId?: string,
    @Query('timeMin') timeMin?: string,
    @Query('timeMax') timeMax?: string,
    @Query('maxResults') maxResults?: string,
  ) {
    return this.calendarService.getEvents(user.id, {
      calendarId,
      timeMin: timeMin ? new Date(timeMin) : undefined,
      timeMax: timeMax ? new Date(timeMax) : undefined,
      maxResults: maxResults ? parseInt(maxResults, 10) : undefined,
    });
  }

  @Post('events')
  @ApiOperation({ summary: 'Create a calendar event' })
  @ApiResponse({ status: 201, description: 'Event created' })
  async createEvent(
    @CurrentUser() user: User,
    @Body() dto: {
      summary: string;
      description?: string;
      start: string;
      end?: string;
      allDay?: boolean;
      calendarId?: string;
    },
  ) {
    return this.calendarService.createEvent(
      user.id,
      {
        summary: dto.summary,
        description: dto.description,
        start: new Date(dto.start),
        end: dto.end ? new Date(dto.end) : undefined,
        allDay: dto.allDay,
      },
      dto.calendarId,
    );
  }

  @Delete('events/:eventId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a calendar event' })
  @ApiResponse({ status: 204, description: 'Event deleted' })
  async deleteEvent(
    @CurrentUser() user: User,
    @Param('eventId') eventId: string,
    @Query('calendarId') calendarId?: string,
  ) {
    await this.calendarService.deleteEvent(user.id, eventId, calendarId);
  }

  // -------------------------------------------------------------------------
  // Task <-> Calendar Sync
  // -------------------------------------------------------------------------

  @Post('import')
  @ApiOperation({ summary: 'Import calendar events as tasks' })
  @ApiResponse({ status: 200, description: 'Imported tasks' })
  async importEvents(
    @CurrentUser() user: User,
    @Body() dto?: {
      calendarId?: string;
      timeMin?: string;
      timeMax?: string;
    },
  ) {
    return this.calendarService.importEventsAsTasks(user.id, {
      calendarId: dto?.calendarId,
      timeMin: dto?.timeMin ? new Date(dto.timeMin) : undefined,
      timeMax: dto?.timeMax ? new Date(dto.timeMax) : undefined,
    });
  }

  @Post('export/:taskId')
  @ApiOperation({ summary: 'Export a task to calendar' })
  @ApiResponse({ status: 200, description: 'Created/updated calendar event' })
  async exportTask(
    @CurrentUser() user: User,
    @Param('taskId') taskId: string,
    @Query('calendarId') calendarId?: string,
  ) {
    return this.calendarService.exportTaskToCalendar(user.id, taskId, calendarId);
  }

  @Post('sync')
  @ApiOperation({ summary: 'Full two-way sync with calendar' })
  @ApiResponse({ status: 200, description: 'Sync result' })
  async fullSync(
    @CurrentUser() user: User,
    @Body() dto?: {
      calendarId?: string;
      importEvents?: boolean;
      exportTasks?: boolean;
    },
  ) {
    return this.calendarService.fullSync(user.id, dto);
  }
}
