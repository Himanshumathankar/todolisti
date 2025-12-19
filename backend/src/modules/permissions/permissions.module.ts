/**
 * =============================================================================
 * Permissions Module
 * =============================================================================
 * 
 * Handles PA (Personal Assistant) permissions and delegation.
 * =============================================================================
 */

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { PermissionsController } from './permissions.controller';
import { PermissionsService } from './permissions.service';
import { Permission, PermissionInvitation } from './entities/permission.entity';
import { AuditModule } from '../audit/audit.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Permission, PermissionInvitation]),
    AuditModule,
  ],
  controllers: [PermissionsController],
  providers: [PermissionsService],
  exports: [PermissionsService],
})
export class PermissionsModule {}
