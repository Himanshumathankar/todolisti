/**
 * =============================================================================
 * TypeORM Data Source
 * =============================================================================
 * 
 * Configuration for TypeORM CLI (migrations, schema sync).
 * This file is used by npm run migration:* commands.
 * =============================================================================
 */

import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';

// Load environment variables
dotenv.config();

export const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  username: process.env.DB_USERNAME || 'todolisti',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'todolisti',
  
  // Entity patterns
  entities: ['src/**/*.entity.ts'],
  
  // Migration patterns
  migrations: ['src/database/migrations/*.ts'],
  
  // Logging
  logging: true,
});
