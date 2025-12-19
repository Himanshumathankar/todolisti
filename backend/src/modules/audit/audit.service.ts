/**
 * =============================================================================
 * Audit Service
 * =============================================================================
 * 
 * Logs all sensitive operations for security and compliance.
 * Captures who did what, when, and the before/after state.
 * =============================================================================
 */

import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, LessThan, MoreThan } from 'typeorm';

import { AuditLog, AuditAction } from './entities/audit-log.entity';

export interface AuditLogEntry {
  userId: string;
  action: AuditAction;
  entityType: string;
  entityId: string;
  previousState?: Record<string, unknown>;
  newState?: Record<string, unknown>;
  targetUserId?: string;
  metadata?: {
    ipAddress?: string;
    userAgent?: string;
    reason?: string;
  };
}

@Injectable()
export class AuditService {
  constructor(
    @InjectRepository(AuditLog)
    private readonly auditLogRepository: Repository<AuditLog>,
  ) {}

  /**
   * Log an audit entry.
   */
  async log(entry: AuditLogEntry): Promise<AuditLog> {
    const auditLog = this.auditLogRepository.create({
      userId: entry.userId,
      action: entry.action,
      entityType: entry.entityType,
      entityId: entry.entityId,
      previousState: entry.previousState as Record<string, any>,
      newState: entry.newState as Record<string, any>,
      targetUserId: entry.targetUserId,
      metadata: entry.metadata,
    });

    return this.auditLogRepository.save(auditLog);
  }

  /**
   * Find audit logs by entity.
   */
  async findByEntity(
    entityType: string,
    entityId: string,
    options?: {
      limit?: number;
      offset?: number;
    },
  ): Promise<AuditLog[]> {
    return this.auditLogRepository.find({
      where: { entityType, entityId },
      order: { createdAt: 'DESC' },
      take: options?.limit ?? 50,
      skip: options?.offset ?? 0,
    });
  }

  /**
   * Find audit logs by user.
   */
  async findByUser(
    userId: string,
    options?: {
      limit?: number;
      offset?: number;
      action?: string;
      startDate?: Date;
      endDate?: Date;
    },
  ): Promise<AuditLog[]> {
    const where: Record<string, unknown> = { userId };

    if (options?.action) {
      where.action = options.action;
    }

    if (options?.startDate && options?.endDate) {
      where.createdAt = Between(options.startDate, options.endDate);
    } else if (options?.startDate) {
      where.createdAt = MoreThan(options.startDate);
    } else if (options?.endDate) {
      where.createdAt = LessThan(options.endDate);
    }

    return this.auditLogRepository.find({
      where,
      order: { createdAt: 'DESC' },
      take: options?.limit ?? 50,
      skip: options?.offset ?? 0,
    });
  }

  /**
   * Find audit logs by action type.
   */
  async findByAction(
    action: string,
    options?: {
      limit?: number;
      offset?: number;
      startDate?: Date;
      endDate?: Date;
    },
  ): Promise<AuditLog[]> {
    const where: Record<string, unknown> = { action };

    if (options?.startDate && options?.endDate) {
      where.createdAt = Between(options.startDate, options.endDate);
    } else if (options?.startDate) {
      where.createdAt = MoreThan(options.startDate);
    } else if (options?.endDate) {
      where.createdAt = LessThan(options.endDate);
    }

    return this.auditLogRepository.find({
      where,
      order: { createdAt: 'DESC' },
      take: options?.limit ?? 50,
      skip: options?.offset ?? 0,
    });
  }

  /**
   * Get audit statistics for a user.
   */
  async getStats(
    userId: string,
    startDate?: Date,
    endDate?: Date,
  ): Promise<{ action: string; count: number }[]> {
    const queryBuilder = this.auditLogRepository
      .createQueryBuilder('audit')
      .select('audit.action', 'action')
      .addSelect('COUNT(*)', 'count')
      .where('audit.userId = :userId', { userId });

    if (startDate) {
      queryBuilder.andWhere('audit.createdAt >= :startDate', { startDate });
    }
    if (endDate) {
      queryBuilder.andWhere('audit.createdAt <= :endDate', { endDate });
    }

    const result = await queryBuilder
      .groupBy('audit.action')
      .orderBy('count', 'DESC')
      .getRawMany();

    return result.map((r) => ({
      action: r.action,
      count: parseInt(r.count, 10),
    }));
  }

  /**
   * Cleanup old audit logs (for data retention).
   */
  async cleanup(olderThan: Date): Promise<number> {
    const result = await this.auditLogRepository.delete({
      createdAt: LessThan(olderThan),
    });
    return result.affected ?? 0;
  }
}
