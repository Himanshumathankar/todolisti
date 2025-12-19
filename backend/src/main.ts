/**
 * =============================================================================
 * Application Entry Point
 * =============================================================================
 * 
 * Bootstraps the NestJS application with all required configurations.
 * Sets up Swagger documentation, CORS, validation, and security.
 * =============================================================================
 */

import { NestFactory } from '@nestjs/core';
import { ValidationPipe, VersioningType } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';

import { AppModule } from './app.module';

async function bootstrap() {
  // Create NestJS application
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log', 'debug', 'verbose'],
  });
  
  // Get configuration service
  const configService = app.get(ConfigService);
  
  // API prefix and versioning
  const apiPrefix = configService.get<string>('API_PREFIX', 'api/v1');
  app.setGlobalPrefix(apiPrefix);
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });
  
  // Security middleware
  app.use(helmet());
  
  // CORS configuration
  const corsOrigin = configService.get<string>('CORS_ORIGIN', '*');
  app.enableCors({
    origin: corsOrigin.split(','),
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    credentials: true,
  });
  
  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,           // Strip non-whitelisted properties
      forbidNonWhitelisted: true, // Throw error for non-whitelisted
      transform: true,           // Transform payloads to DTO instances
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );
  
  // Swagger API documentation
  if (configService.get<string>('NODE_ENV') !== 'production') {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('TodoListi API')
      .setDescription('API documentation for the TodoListi productivity platform')
      .setVersion('1.0')
      .addBearerAuth(
        {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
        'access-token',
      )
      .addTag('auth', 'Authentication endpoints')
      .addTag('users', 'User management')
      .addTag('tasks', 'Task management')
      .addTag('projects', 'Project management')
      .addTag('calendar', 'Calendar synchronization')
      .addTag('sync', 'Offline sync')
      .build();
    
    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup('docs', app, document, {
      swaggerOptions: {
        persistAuthorization: true,
      },
    });
  }
  
  // Start server
  const port = configService.get<number>('PORT', 3000);
  // Listen on 0.0.0.0 to accept connections from external devices (e.g., phone)
  await app.listen(port, '0.0.0.0');
  
  console.log(`
╔══════════════════════════════════════════════════════════════╗
║                    TodoListi Backend API                      ║
╠══════════════════════════════════════════════════════════════╣
║  🚀 Server running on: http://localhost:${port}                 ║
║  📚 API Docs: http://localhost:${port}/docs                     ║
║  🔧 Environment: ${configService.get<string>('NODE_ENV', 'development').padEnd(15)}                    ║
╚══════════════════════════════════════════════════════════════╝
  `);
}

bootstrap();
