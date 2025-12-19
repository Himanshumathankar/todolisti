/**
 * =============================================================================
 * Root Application Module
 * =============================================================================
 * 
 * Imports and configures all feature modules.
 * Sets up global providers and configurations.
 * =============================================================================
 */

import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule } from '@nestjs/throttler';

// Feature modules
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { TasksModule } from './modules/tasks/tasks.module';
import { ProjectsModule } from './modules/projects/projects.module';
import { CalendarModule } from './modules/calendar/calendar.module';
import { SyncModule } from './modules/sync/sync.module';
import { PermissionsModule } from './modules/permissions/permissions.module';
import { AuditModule } from './modules/audit/audit.module';

// Database configuration
import { getDatabaseConfig } from './database/database.config';

@Module({
  imports: [
    // Environment configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),
    
    // Database connection
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: getDatabaseConfig,
      inject: [ConfigService],
    }),
    
    // Rate limiting
    ThrottlerModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (config: ConfigService) => [
        {
          ttl: config.get<number>('THROTTLE_TTL', 60) * 1000,
          limit: config.get<number>('THROTTLE_LIMIT', 100),
        },
      ],
      inject: [ConfigService],
    }),
    
    // Feature modules
    AuthModule,
    UsersModule,
    TasksModule,
    ProjectsModule,
    CalendarModule,
    SyncModule,
    PermissionsModule,
    AuditModule,
  ],
})
export class AppModule {}
