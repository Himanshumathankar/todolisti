/**
 * =============================================================================
 * Initial Database Migration
 * =============================================================================
 * 
 * Creates all initial database tables for TodoListi.
 * Run with: npm run migration:run
 * =============================================================================
 */

import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitialMigration1700000000000 implements MigrationInterface {
  name = 'InitialMigration1700000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create UUID extension
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`);

    // =========================================================================
    // Users Table
    // =========================================================================
    await queryRunner.query(`
      CREATE TABLE "users" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "email" character varying(255) NOT NULL,
        "name" character varying(255) NOT NULL,
        "avatar_url" character varying(500),
        "google_id" character varying(255),
        "google_access_token" text,
        "google_refresh_token" text,
        "google_calendar_access_token" text,
        "google_calendar_refresh_token" text,
        "timezone" character varying(50) NOT NULL DEFAULT 'UTC',
        "settings" jsonb NOT NULL DEFAULT '{}',
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "UQ_users_email" UNIQUE ("email"),
        CONSTRAINT "UQ_users_google_id" UNIQUE ("google_id"),
        CONSTRAINT "PK_users" PRIMARY KEY ("id")
      )
    `);

    // =========================================================================
    // Projects Table
    // =========================================================================
    await queryRunner.query(`
      CREATE TABLE "projects" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "name" character varying(100) NOT NULL,
        "description" text,
        "color" character varying(7) NOT NULL DEFAULT '#3B82F6',
        "icon" character varying(50) NOT NULL DEFAULT 'folder',
        "sort_order" integer NOT NULL DEFAULT 0,
        "is_archived" boolean NOT NULL DEFAULT false,
        "sync_version" integer NOT NULL DEFAULT 0,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
        "deleted_at" TIMESTAMP,
        CONSTRAINT "PK_projects" PRIMARY KEY ("id"),
        CONSTRAINT "FK_projects_user" FOREIGN KEY ("user_id") 
          REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);

    // =========================================================================
    // Tasks Table
    // =========================================================================
    await queryRunner.query(`
      CREATE TABLE "tasks" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "parent_id" uuid,
        "project_id" uuid,
        "title" character varying(500) NOT NULL,
        "description" text,
        "priority" integer NOT NULL DEFAULT 0,
        "due_date" TIMESTAMP,
        "completed_at" TIMESTAMP,
        "google_calendar_event_id" character varying(255),
        "sort_order" integer NOT NULL DEFAULT 0,
        "recurrence" character varying(20) NOT NULL DEFAULT 'none',
        "recurrence_rule" text,
        "metadata" jsonb NOT NULL DEFAULT '{}',
        "sync_version" integer NOT NULL DEFAULT 0,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
        "deleted_at" TIMESTAMP,
        CONSTRAINT "PK_tasks" PRIMARY KEY ("id"),
        CONSTRAINT "FK_tasks_user" FOREIGN KEY ("user_id") 
          REFERENCES "users"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_tasks_parent" FOREIGN KEY ("parent_id") 
          REFERENCES "tasks"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_tasks_project" FOREIGN KEY ("project_id") 
          REFERENCES "projects"("id") ON DELETE SET NULL
      )
    `);

    // =========================================================================
    // Tags Table
    // =========================================================================
    await queryRunner.query(`
      CREATE TABLE "tags" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "name" character varying(50) NOT NULL,
        "color" character varying(7) NOT NULL DEFAULT '#6B7280',
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_tags" PRIMARY KEY ("id"),
        CONSTRAINT "FK_tags_user" FOREIGN KEY ("user_id") 
          REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);

    // =========================================================================
    // Task Tags (Many-to-Many)
    // =========================================================================
    await queryRunner.query(`
      CREATE TABLE "task_tags" (
        "task_id" uuid NOT NULL,
        "tag_id" uuid NOT NULL,
        CONSTRAINT "PK_task_tags" PRIMARY KEY ("task_id", "tag_id"),
        CONSTRAINT "FK_task_tags_task" FOREIGN KEY ("task_id") 
          REFERENCES "tasks"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_task_tags_tag" FOREIGN KEY ("tag_id") 
          REFERENCES "tags"("id") ON DELETE CASCADE
      )
    `);

    // =========================================================================
    // Reminders Table
    // =========================================================================
    await queryRunner.query(`
      CREATE TABLE "reminders" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "task_id" uuid NOT NULL,
        "remind_at" TIMESTAMP NOT NULL,
        "type" character varying(20) NOT NULL DEFAULT 'notification',
        "sent" boolean NOT NULL DEFAULT false,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_reminders" PRIMARY KEY ("id"),
        CONSTRAINT "FK_reminders_task" FOREIGN KEY ("task_id") 
          REFERENCES "tasks"("id") ON DELETE CASCADE
      )
    `);

    // =========================================================================
    // Permissions Table (PA Delegation)
    // =========================================================================
    await queryRunner.query(`
      CREATE TABLE "permissions" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "owner_id" uuid NOT NULL,
        "assistant_id" uuid,
        "assistant_email" character varying(255) NOT NULL,
        "level" character varying(20) NOT NULL DEFAULT 'view',
        "status" character varying(20) NOT NULL DEFAULT 'pending',
        "invitation_token" character varying(255),
        "expires_at" TIMESTAMP,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_permissions" PRIMARY KEY ("id"),
        CONSTRAINT "FK_permissions_owner" FOREIGN KEY ("owner_id") 
          REFERENCES "users"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_permissions_assistant" FOREIGN KEY ("assistant_id") 
          REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);

    // =========================================================================
    // Audit Log Table
    // =========================================================================
    await queryRunner.query(`
      CREATE TABLE "audit_logs" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "action" character varying(100) NOT NULL,
        "entity_type" character varying(50) NOT NULL,
        "entity_id" character varying(255) NOT NULL,
        "old_value" jsonb,
        "new_value" jsonb,
        "metadata" jsonb,
        "ip_address" character varying(45),
        "user_agent" text,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_audit_logs" PRIMARY KEY ("id"),
        CONSTRAINT "FK_audit_logs_user" FOREIGN KEY ("user_id") 
          REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);

    // =========================================================================
    // Sync Queue Table
    // =========================================================================
    await queryRunner.query(`
      CREATE TABLE "sync_queue" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "entity_type" character varying(50) NOT NULL,
        "entity_id" character varying(255) NOT NULL,
        "operation" character varying(20) NOT NULL,
        "payload" jsonb NOT NULL,
        "status" character varying(20) NOT NULL DEFAULT 'pending',
        "retry_count" integer NOT NULL DEFAULT 0,
        "last_error" text,
        "synced_at" TIMESTAMP,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_sync_queue" PRIMARY KEY ("id"),
        CONSTRAINT "FK_sync_queue_user" FOREIGN KEY ("user_id") 
          REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);

    // =========================================================================
    // Indexes
    // =========================================================================
    
    // Tasks indexes
    await queryRunner.query(`CREATE INDEX "IDX_tasks_user_id" ON "tasks" ("user_id")`);
    await queryRunner.query(`CREATE INDEX "IDX_tasks_project_id" ON "tasks" ("project_id")`);
    await queryRunner.query(`CREATE INDEX "IDX_tasks_parent_id" ON "tasks" ("parent_id")`);
    await queryRunner.query(`CREATE INDEX "IDX_tasks_due_date" ON "tasks" ("due_date")`);
    await queryRunner.query(`CREATE INDEX "IDX_tasks_completed_at" ON "tasks" ("completed_at")`);
    await queryRunner.query(`CREATE INDEX "IDX_tasks_deleted_at" ON "tasks" ("deleted_at")`);
    await queryRunner.query(`CREATE INDEX "IDX_tasks_google_event" ON "tasks" ("google_calendar_event_id")`);
    
    // Projects indexes
    await queryRunner.query(`CREATE INDEX "IDX_projects_user_id" ON "projects" ("user_id")`);
    
    // Tags indexes
    await queryRunner.query(`CREATE INDEX "IDX_tags_user_id" ON "tags" ("user_id")`);
    
    // Permissions indexes
    await queryRunner.query(`CREATE INDEX "IDX_permissions_owner_id" ON "permissions" ("owner_id")`);
    await queryRunner.query(`CREATE INDEX "IDX_permissions_assistant_id" ON "permissions" ("assistant_id")`);
    await queryRunner.query(`CREATE INDEX "IDX_permissions_invitation_token" ON "permissions" ("invitation_token")`);
    
    // Audit log indexes
    await queryRunner.query(`CREATE INDEX "IDX_audit_logs_user_id" ON "audit_logs" ("user_id")`);
    await queryRunner.query(`CREATE INDEX "IDX_audit_logs_entity" ON "audit_logs" ("entity_type", "entity_id")`);
    await queryRunner.query(`CREATE INDEX "IDX_audit_logs_action" ON "audit_logs" ("action")`);
    await queryRunner.query(`CREATE INDEX "IDX_audit_logs_created_at" ON "audit_logs" ("created_at")`);
    
    // Sync queue indexes
    await queryRunner.query(`CREATE INDEX "IDX_sync_queue_user_id" ON "sync_queue" ("user_id")`);
    await queryRunner.query(`CREATE INDEX "IDX_sync_queue_status" ON "sync_queue" ("status")`);
    
    // Reminders indexes
    await queryRunner.query(`CREATE INDEX "IDX_reminders_task_id" ON "reminders" ("task_id")`);
    await queryRunner.query(`CREATE INDEX "IDX_reminders_remind_at" ON "reminders" ("remind_at")`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop all tables in reverse order
    await queryRunner.query(`DROP TABLE IF EXISTS "sync_queue"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "audit_logs"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "permissions"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "reminders"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "task_tags"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "tags"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "tasks"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "projects"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "users"`);
  }
}
