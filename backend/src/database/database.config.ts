/**
 * =============================================================================
 * Database Configuration
 * =============================================================================
 * 
 * TypeORM configuration for PostgreSQL connection.
 * Supports migrations, logging, and connection pooling.
 * =============================================================================
 */

import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

/**
 * Get TypeORM configuration from environment variables.
 * 
 * @param configService - NestJS configuration service
 * @returns TypeORM module options
 */
export const getDatabaseConfig = (
  configService: ConfigService,
): TypeOrmModuleOptions => ({
  type: 'postgres',
  host: configService.get<string>('DB_HOST', 'localhost'),
  port: configService.get<number>('DB_PORT', 5432),
  username: configService.get<string>('DB_USERNAME', 'todolisti'),
  password: configService.get<string>('DB_PASSWORD', ''),
  database: configService.get<string>('DB_DATABASE', 'todolisti'),
  
  // Entity auto-loading
  autoLoadEntities: true,
  
  // Schema synchronization (disable in production)
  synchronize: configService.get<boolean>('DB_SYNCHRONIZE', false),
  
  // Logging configuration
  logging: configService.get<boolean>('DB_LOGGING', false),
  
  // Connection pool settings
  extra: {
    max: 20,           // Maximum pool size
    min: 5,            // Minimum pool size
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  },
  
  // Migrations
  migrations: ['dist/database/migrations/*.js'],
  migrationsRun: false,
  
  // SSL for production
  ssl: configService.get<string>('NODE_ENV') === 'production'
    ? { rejectUnauthorized: false }
    : false,
});
