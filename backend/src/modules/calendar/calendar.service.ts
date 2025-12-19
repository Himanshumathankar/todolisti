/**
 * =============================================================================
 * Calendar Service
 * =============================================================================
 * 
 * Handles Google Calendar two-way synchronization.
 * 
 * Features:
 * - Import events as tasks
 * - Export tasks with due dates as calendar events
 * - Real-time sync via webhooks (push notifications)
 * - Conflict resolution with calendar events
 * =============================================================================
 */

import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull, Not } from 'typeorm';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { AxiosResponse } from 'axios';

import { Task } from '../tasks/entities/task.entity';
import { User } from '../users/entities/user.entity';

export interface CalendarEvent {
  id: string;
  summary: string;
  description?: string;
  start: { dateTime?: string; date?: string };
  end: { dateTime?: string; date?: string };
  status?: string;
  htmlLink?: string;
}

export interface CalendarList {
  items: Array<{
    id: string;
    summary: string;
    primary?: boolean;
  }>;
}

interface GoogleCalendarResponse<T> {
  data: T;
}

@Injectable()
export class CalendarService {
  private readonly googleCalendarApiUrl = 'https://www.googleapis.com/calendar/v3';

  constructor(
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly httpService: HttpService,
  ) {}

  // -------------------------------------------------------------------------
  // OAuth Token Management
  // -------------------------------------------------------------------------

  /**
   * Refresh the access token using the refresh token.
   */
  async refreshAccessToken(userId: string): Promise<string> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user?.googleRefreshToken) {
      throw new BadRequestException('Calendar not connected');
    }

    const response: AxiosResponse<{ access_token: string }> = await firstValueFrom(
      this.httpService.post('https://oauth2.googleapis.com/token', {
        client_id: process.env.GOOGLE_CLIENT_ID,
        client_secret: process.env.GOOGLE_CLIENT_SECRET,
        refresh_token: user.googleRefreshToken,
        grant_type: 'refresh_token',
      }),
    );

    const newAccessToken = response.data.access_token;
    
    // Update stored access token
    user.googleAccessToken = newAccessToken;
    await this.userRepository.save(user);

    return newAccessToken;
  }

  /**
   * Get valid access token (refresh if needed).
   */
  private async getAccessToken(userId: string): Promise<string> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user?.googleAccessToken) {
      throw new BadRequestException('Calendar not connected');
    }

    // For simplicity, always try to refresh if we have a refresh token
    // In production, check token expiry
    if (user.googleRefreshToken) {
      try {
        return await this.refreshAccessToken(userId);
      } catch {
        // If refresh fails, try with existing token
        return user.googleAccessToken;
      }
    }

    return user.googleAccessToken;
  }

  // -------------------------------------------------------------------------
  // Calendar Operations
  // -------------------------------------------------------------------------

  /**
   * Get user's calendar list.
   */
  async getCalendarList(userId: string): Promise<CalendarList> {
    const accessToken = await this.getAccessToken(userId);

    const response: AxiosResponse<CalendarList> = await firstValueFrom(
      this.httpService.get(`${this.googleCalendarApiUrl}/users/me/calendarList`, {
        headers: { Authorization: `Bearer ${accessToken}` },
      }),
    );

    return response.data;
  }

  /**
   * Get events from a calendar.
   */
  async getEvents(
    userId: string,
    options?: {
      calendarId?: string;
      timeMin?: Date;
      timeMax?: Date;
      maxResults?: number;
    },
  ): Promise<CalendarEvent[]> {
    const accessToken = await this.getAccessToken(userId);
    const calendarId = options?.calendarId || 'primary';

    const params: Record<string, string> = {
      orderBy: 'startTime',
      singleEvents: 'true',
    };

    if (options?.timeMin) {
      params.timeMin = options.timeMin.toISOString();
    }
    if (options?.timeMax) {
      params.timeMax = options.timeMax.toISOString();
    }
    if (options?.maxResults) {
      params.maxResults = options.maxResults.toString();
    }

    const response: AxiosResponse<{ items?: CalendarEvent[] }> = await firstValueFrom(
      this.httpService.get(
        `${this.googleCalendarApiUrl}/calendars/${encodeURIComponent(calendarId)}/events`,
        {
          headers: { Authorization: `Bearer ${accessToken}` },
          params,
        },
      ),
    );

    return response.data.items || [];
  }

  /**
   * Create an event in the calendar.
   */
  async createEvent(
    userId: string,
    event: {
      summary: string;
      description?: string;
      start: Date;
      end?: Date;
      allDay?: boolean;
    },
    calendarId = 'primary',
  ): Promise<CalendarEvent> {
    const accessToken = await this.getAccessToken(userId);

    const eventData: Record<string, unknown> = {
      summary: event.summary,
      description: event.description,
    };

    if (event.allDay) {
      // All-day event uses date format
      eventData.start = { date: event.start.toISOString().split('T')[0] };
      eventData.end = { 
        date: (event.end || event.start).toISOString().split('T')[0],
      };
    } else {
      eventData.start = { dateTime: event.start.toISOString() };
      eventData.end = { 
        dateTime: (event.end || new Date(event.start.getTime() + 3600000)).toISOString(),
      };
    }

    const response: AxiosResponse<CalendarEvent> = await firstValueFrom(
      this.httpService.post(
        `${this.googleCalendarApiUrl}/calendars/${encodeURIComponent(calendarId)}/events`,
        eventData,
        { headers: { Authorization: `Bearer ${accessToken}` } },
      ),
    );

    return response.data;
  }

  /**
   * Update a calendar event.
   */
  async updateEvent(
    userId: string,
    eventId: string,
    event: Partial<{
      summary: string;
      description: string;
      start: Date;
      end: Date;
    }>,
    calendarId = 'primary',
  ): Promise<CalendarEvent> {
    const accessToken = await this.getAccessToken(userId);

    const eventData: Record<string, unknown> = {};
    if (event.summary) eventData.summary = event.summary;
    if (event.description) eventData.description = event.description;
    if (event.start) eventData.start = { dateTime: event.start.toISOString() };
    if (event.end) eventData.end = { dateTime: event.end.toISOString() };

    const response: AxiosResponse<CalendarEvent> = await firstValueFrom(
      this.httpService.patch(
        `${this.googleCalendarApiUrl}/calendars/${encodeURIComponent(calendarId)}/events/${eventId}`,
        eventData,
        { headers: { Authorization: `Bearer ${accessToken}` } },
      ),
    );

    return response.data;
  }

  /**
   * Delete a calendar event.
   */
  async deleteEvent(
    userId: string,
    eventId: string,
    calendarId = 'primary',
  ): Promise<void> {
    const accessToken = await this.getAccessToken(userId);

    await firstValueFrom(
      this.httpService.delete(
        `${this.googleCalendarApiUrl}/calendars/${encodeURIComponent(calendarId)}/events/${eventId}`,
        { headers: { Authorization: `Bearer ${accessToken}` } },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Task <-> Calendar Sync
  // -------------------------------------------------------------------------

  /**
   * Import calendar events as tasks.
   */
  async importEventsAsTasks(
    userId: string,
    options?: {
      calendarId?: string;
      timeMin?: Date;
      timeMax?: Date;
    },
  ): Promise<Task[]> {
    const events = await this.getEvents(userId, {
      calendarId: options?.calendarId,
      timeMin: options?.timeMin || new Date(),
      timeMax: options?.timeMax || new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
    });

    const tasks: Task[] = [];

    for (const event of events) {
      // Skip all-day events or events without a specific time
      const startDate = event.start.dateTime 
        ? new Date(event.start.dateTime) 
        : event.start.date 
          ? new Date(event.start.date)
          : null;

      if (!startDate) continue;

      // Check if task already exists for this event
      const existing = await this.taskRepository.findOne({
        where: {
          userId,
          googleEventId: event.id,
        },
      });

      if (existing) {
        // Update existing task
        existing.title = event.summary;
        existing.description = event.description || existing.description;
        existing.dueDate = startDate;
        const saved = await this.taskRepository.save(existing);
        tasks.push(saved);
      } else {
        // Create new task
        const task = this.taskRepository.create({
          userId,
          title: event.summary,
          description: event.description,
          dueDate: startDate,
          googleEventId: event.id,
        });
        const saved = await this.taskRepository.save(task);
        tasks.push(saved);
      }
    }

    return tasks;
  }

  /**
   * Export a task to Google Calendar.
   */
  async exportTaskToCalendar(
    userId: string,
    taskId: string,
    calendarId = 'primary',
  ): Promise<CalendarEvent> {
    const task = await this.taskRepository.findOne({
      where: { id: taskId, userId },
    });

    if (!task) {
      throw new BadRequestException('Task not found');
    }

    if (!task.dueDate) {
      throw new BadRequestException('Task must have a due date to export');
    }

    if (task.googleEventId) {
      // Update existing event
      return this.updateEvent(userId, task.googleEventId, {
        summary: task.title,
        description: task.description || undefined,
        start: task.dueDate,
      }, calendarId);
    }

    // Create new event
    const event = await this.createEvent(userId, {
      summary: task.title,
      description: task.description || undefined,
      start: task.dueDate,
      allDay: !task.dueDate.getHours() && !task.dueDate.getMinutes(),
    }, calendarId);

    // Store event ID on task
    task.googleEventId = event.id;
    await this.taskRepository.save(task);

    return event;
  }

  /**
   * Full sync: Import events and export tasks with due dates.
   */
  async fullSync(
    userId: string,
    options?: {
      calendarId?: string;
      importEvents?: boolean;
      exportTasks?: boolean;
    },
  ): Promise<{
    importedTasks: Task[];
    exportedEvents: CalendarEvent[];
  }> {
    const result = {
      importedTasks: [] as Task[],
      exportedEvents: [] as CalendarEvent[],
    };

    // Import events as tasks
    if (options?.importEvents !== false) {
      result.importedTasks = await this.importEventsAsTasks(userId, {
        calendarId: options?.calendarId,
      });
    }

    // Export tasks to calendar
    if (options?.exportTasks !== false) {
      const tasksWithDueDate = await this.taskRepository.find({
        where: {
          userId,
          dueDate: Not(IsNull()),
          googleEventId: IsNull(),
        },
      });

      for (const task of tasksWithDueDate) {
        try {
          const event = await this.exportTaskToCalendar(
            userId,
            task.id,
            options?.calendarId,
          );
          result.exportedEvents.push(event);
        } catch (error) {
          console.error(`Failed to export task ${task.id}:`, error);
        }
      }
    }

    return result;
  }
}
