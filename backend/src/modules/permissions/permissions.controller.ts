/**
 * =============================================================================
 * Permissions Controller
 * =============================================================================
 * 
 * HTTP endpoints for PA permission management.
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

import { PermissionsService } from './permissions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';
import { PermissionLevel } from './entities/permission.entity';

@ApiTags('permissions')
@Controller('permissions')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('access-token')
export class PermissionsController {
  constructor(private readonly permissionsService: PermissionsService) {}

  // -------------------------------------------------------------------------
  // Invitation Management
  // -------------------------------------------------------------------------

  @Post('invite')
  @ApiOperation({ summary: 'Create a PA invitation' })
  @ApiResponse({ status: 201, description: 'Invitation created' })
  async createInvitation(
    @CurrentUser() user: User,
    @Body() dto: {
      assistantEmail: string;
      level: PermissionLevel;
      expiresAt?: Date;
    },
  ) {
    return this.permissionsService.createInvitation(user.id, dto);
  }

  @Post('accept/:token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Accept a PA invitation' })
  @ApiResponse({ status: 200, description: 'Invitation accepted' })
  async acceptInvitation(
    @CurrentUser() user: User,
    @Param('token') token: string,
  ) {
    return this.permissionsService.acceptInvitation(user.id, token);
  }

  @Get('pending')
  @ApiOperation({ summary: 'Get pending invitations for current user' })
  @ApiResponse({ status: 200, description: 'List of pending invitations' })
  async findPendingInvitations(@CurrentUser() user: User) {
    return this.permissionsService.findPendingInvitations(user.email);
  }

  // -------------------------------------------------------------------------
  // Permission Queries
  // -------------------------------------------------------------------------

  @Get('assistants')
  @ApiOperation({ summary: 'Get users who can access my tasks' })
  @ApiResponse({ status: 200, description: 'List of assistants' })
  async findAssistants(@CurrentUser() user: User) {
    return this.permissionsService.findAssistants(user.id);
  }

  @Get('delegators')
  @ApiOperation({ summary: 'Get users whose tasks I can access' })
  @ApiResponse({ status: 200, description: 'List of delegators' })
  async findDelegators(@CurrentUser() user: User) {
    return this.permissionsService.findDelegators(user.id);
  }

  // -------------------------------------------------------------------------
  // Permission Management
  // -------------------------------------------------------------------------

  @Patch(':id')
  @ApiOperation({ summary: 'Update permission level' })
  @ApiResponse({ status: 200, description: 'Permission updated' })
  async updatePermission(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: {
      level?: PermissionLevel;
    },
  ) {
    return this.permissionsService.updatePermission(user.id, id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Revoke a permission' })
  @ApiResponse({ status: 204, description: 'Permission revoked' })
  async revokePermission(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ) {
    return this.permissionsService.revokePermission(user.id, id);
  }
}
