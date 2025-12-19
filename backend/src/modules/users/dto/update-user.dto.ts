/**
 * =============================================================================
 * Update User DTO
 * =============================================================================
 * 
 * Data transfer object for updating user profile.
 * =============================================================================
 */

import { IsOptional, IsString, IsObject } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateUserDto {
  @ApiPropertyOptional({
    description: 'User display name',
    example: 'John Doe',
  })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({
    description: 'User timezone',
    example: 'America/New_York',
  })
  @IsOptional()
  @IsString()
  timezone?: string;

  @ApiPropertyOptional({
    description: 'Notification settings',
    example: { email: true, push: true, reminderMinutes: 30 },
  })
  @IsOptional()
  @IsObject()
  notificationSettings?: Record<string, any>;
}
