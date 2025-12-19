/**
 * =============================================================================
 * Permissions Service
 * =============================================================================
 * 
 * Business logic for PA permissions and delegation.
 * Uses Permission and PermissionInvitation entities.
 * =============================================================================
 */

import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';

import { 
  Permission, 
  PermissionInvitation, 
  PermissionLevel, 
  InvitationStatus 
} from './entities/permission.entity';
import { AuditService } from '../audit/audit.service';
import { AuditAction } from '../audit/entities/audit-log.entity';

@Injectable()
export class PermissionsService {
  constructor(
    @InjectRepository(Permission)
    private readonly permissionRepository: Repository<Permission>,
    @InjectRepository(PermissionInvitation)
    private readonly invitationRepository: Repository<PermissionInvitation>,
    private readonly auditService: AuditService,
  ) {}

  // -------------------------------------------------------------------------
  // Invitation Management
  // -------------------------------------------------------------------------

  /**
   * Create an invitation for a PA.
   * Generates an invitation token that can be shared with the assistant.
   */
  async createInvitation(
    ownerId: string,
    data: {
      assistantEmail: string;
      level: PermissionLevel;
      expiresAt?: Date;
    },
  ): Promise<PermissionInvitation> {
    // Check if invitation already exists
    const existing = await this.invitationRepository.findOne({
      where: {
        ownerId,
        email: data.assistantEmail,
        status: InvitationStatus.PENDING,
      },
    });

    if (existing) {
      throw new BadRequestException('An active invitation already exists for this email');
    }

    const invitation = this.invitationRepository.create({
      ownerId,
      email: data.assistantEmail,
      level: data.level,
      status: InvitationStatus.PENDING,
      token: uuidv4(),
      expiresAt: data.expiresAt || new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
    });

    const saved = await this.invitationRepository.save(invitation);

    await this.auditService.log({
      userId: ownerId,
      action: AuditAction.INVITATION_SEND,
      entityType: 'PermissionInvitation',
      entityId: saved.id,
      newState: { email: data.assistantEmail, level: data.level },
    });

    return saved;
  }

  /**
   * Accept an invitation using the invitation token.
   */
  async acceptInvitation(
    assistantId: string,
    invitationToken: string,
  ): Promise<Permission> {
    const invitation = await this.invitationRepository.findOne({
      where: { token: invitationToken },
    });

    if (!invitation) {
      throw new NotFoundException('Invitation not found');
    }

    if (invitation.status !== InvitationStatus.PENDING) {
      throw new BadRequestException('Invitation is no longer valid');
    }

    if (invitation.expiresAt < new Date()) {
      invitation.status = InvitationStatus.EXPIRED;
      await this.invitationRepository.save(invitation);
      throw new BadRequestException('Invitation has expired');
    }

    // Update invitation status
    invitation.status = InvitationStatus.ACCEPTED;
    await this.invitationRepository.save(invitation);

    // Create the permission
    const permission = this.permissionRepository.create({
      ownerId: invitation.ownerId,
      assistantId,
      level: invitation.level,
      isActive: true,
    });

    const saved = await this.permissionRepository.save(permission);

    await this.auditService.log({
      userId: assistantId,
      action: AuditAction.INVITATION_ACCEPT,
      entityType: 'Permission',
      entityId: saved.id,
      targetUserId: invitation.ownerId,
    });

    return saved;
  }

  /**
   * Revoke a permission (by owner or assistant).
   */
  async revokePermission(
    userId: string,
    permissionId: string,
  ): Promise<void> {
    const permission = await this.permissionRepository.findOne({
      where: { id: permissionId },
    });

    if (!permission) {
      throw new NotFoundException('Permission not found');
    }

    // Only owner or assistant can revoke
    if (permission.ownerId !== userId && permission.assistantId !== userId) {
      throw new ForbiddenException('Cannot revoke this permission');
    }

    permission.isActive = false;
    await this.permissionRepository.save(permission);

    await this.auditService.log({
      userId,
      action: AuditAction.PERMISSION_REVOKE,
      entityType: 'Permission',
      entityId: permission.id,
      targetUserId: permission.ownerId === userId ? permission.assistantId : permission.ownerId,
    });
  }

  /**
   * Update permission level (owner only).
   */
  async updatePermission(
    ownerId: string,
    permissionId: string,
    data: {
      level?: PermissionLevel;
    },
  ): Promise<Permission> {
    const permission = await this.permissionRepository.findOne({
      where: { id: permissionId, ownerId },
    });

    if (!permission) {
      throw new NotFoundException('Permission not found');
    }

    const previousState = { level: permission.level };

    if (data.level) {
      permission.level = data.level;
    }

    const saved = await this.permissionRepository.save(permission);

    await this.auditService.log({
      userId: ownerId,
      action: AuditAction.PERMISSION_UPDATE,
      entityType: 'Permission',
      entityId: saved.id,
      previousState,
      newState: { level: saved.level },
    });

    return saved;
  }

  // -------------------------------------------------------------------------
  // Permission Queries
  // -------------------------------------------------------------------------

  /**
   * Get all permissions where user is the owner (people who can access my tasks).
   */
  async findAssistants(ownerId: string): Promise<Permission[]> {
    return this.permissionRepository.find({
      where: { ownerId, isActive: true },
      relations: ['assistant'],
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Get all permissions where user is the assistant (people whose tasks I can access).
   */
  async findDelegators(assistantId: string): Promise<Permission[]> {
    return this.permissionRepository.find({
      where: { assistantId, isActive: true },
      relations: ['owner'],
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Get pending invitations for an email.
   */
  async findPendingInvitations(email: string): Promise<PermissionInvitation[]> {
    return this.invitationRepository.find({
      where: { email, status: InvitationStatus.PENDING },
      relations: ['owner'],
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Check if a user has permission to access another user's data.
   */
  async checkPermission(
    assistantId: string,
    ownerId: string,
    requiredLevel: PermissionLevel = PermissionLevel.VIEW,
  ): Promise<boolean> {
    const permission = await this.permissionRepository.findOne({
      where: {
        assistantId,
        ownerId,
        isActive: true,
      },
    });

    if (!permission) {
      return false;
    }

    // Check level hierarchy: full > edit > view
    const levelHierarchy = { 
      [PermissionLevel.VIEW]: 1, 
      [PermissionLevel.EDIT]: 2, 
      [PermissionLevel.FULL]: 3 
    };
    return levelHierarchy[permission.level] >= levelHierarchy[requiredLevel];
  }

  /**
   * Get the permission level for a user on another user's data.
   */
  async getPermissionLevel(
    assistantId: string,
    ownerId: string,
  ): Promise<PermissionLevel | null> {
    const permission = await this.permissionRepository.findOne({
      where: {
        assistantId,
        ownerId,
        isActive: true,
      },
    });

    if (!permission) {
      return null;
    }

    return permission.level;
  }
}
