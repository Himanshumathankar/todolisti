/**
 * =============================================================================
 * Sync Controller
 * =============================================================================
 * 
 * HTTP endpoints for offline-first synchronization.
 * =============================================================================
 */

import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';

import { SyncService, SyncPayload } from './sync.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';

@ApiTags('sync')
@Controller('sync')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('access-token')
export class SyncController {
  constructor(private readonly syncService: SyncService) {}

  @Post()
  @ApiOperation({ summary: 'Sync local changes with server' })
  @ApiResponse({ status: 200, description: 'Sync result with merged state' })
  async sync(
    @CurrentUser() user: User,
    @Body() payload: SyncPayload,
  ) {
    return this.syncService.sync(user.id, payload);
  }

  @Get('changes')
  @ApiOperation({ summary: 'Get all changes since a timestamp' })
  @ApiResponse({ status: 200, description: 'Changes since timestamp' })
  async getChangesSince(
    @CurrentUser() user: User,
    @Query('since') since: string,
  ) {
    const sinceDate = since ? new Date(since) : new Date(0);
    return this.syncService.getChangesSince(user.id, sinceDate);
  }

  @Get('pending')
  @ApiOperation({ summary: 'Get pending sync operations' })
  @ApiResponse({ status: 200, description: 'Pending operations' })
  async getPendingOperations(@CurrentUser() user: User) {
    return this.syncService.getPendingOperations(user.id);
  }
}
