/// =============================================================================
/// Permission Entity
/// =============================================================================
/// 
/// Core domain entity representing permissions in the PA/Assistant system.
/// Defines who can access what data and with what level of control.
/// =============================================================================
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission.freezed.dart';
part 'permission.g.dart';

/// Permission levels for PA/Assistant access.
/// 
/// Each level includes all permissions from lower levels.
enum PermissionLevel {
  /// Can only view tasks and calendar
  view,
  
  /// Can view and edit tasks
  edit,
  
  /// Full control including delete and settings
  full,
}

/// Permission entity representing a PA/Assistant access grant.
/// 
/// Defines what an assistant can do with the owner's data.
@freezed
class Permission with _$Permission {
  const Permission._();
  
  const factory Permission({
    /// Unique identifier (UUID)
    required String id,
    
    /// User who owns the data (granting access)
    required String ownerId,
    
    /// User who has assistant access
    required String assistantId,
    
    /// Permission level granted
    required PermissionLevel level,
    
    /// When the permission was created
    required DateTime createdAt,
    
    /// When the permission expires (optional)
    DateTime? expiresAt,
    
    /// When the permission was revoked (if revoked)
    DateTime? revokedAt,
  }) = _Permission;
  
  factory Permission.fromJson(Map<String, dynamic> json) =>
    _$PermissionFromJson(json);
  
  // ============= COMPUTED PROPERTIES =============
  
  /// Whether this permission is currently active.
  bool get isActive {
    if (revokedAt != null) return false;
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) return false;
    return true;
  }
  
  /// Whether this permission has view access.
  bool get canView => isActive;
  
  /// Whether this permission has edit access.
  bool get canEdit => isActive && 
    (level == PermissionLevel.edit || level == PermissionLevel.full);
  
  /// Whether this permission has full control.
  bool get hasFullControl => isActive && level == PermissionLevel.full;
}

/// Permission invitation for pending access requests.
@freezed
class PermissionInvitation with _$PermissionInvitation {
  const factory PermissionInvitation({
    /// Unique identifier (UUID)
    required String id,
    
    /// User who is inviting
    required String ownerId,
    
    /// Email of the invited assistant
    required String assistantEmail,
    
    /// Permission level being offered
    required PermissionLevel level,
    
    /// When the invitation was sent
    required DateTime sentAt,
    
    /// When the invitation expires
    required DateTime expiresAt,
    
    /// Invitation status
    @Default(InvitationStatus.pending) InvitationStatus status,
  }) = _PermissionInvitation;
  
  factory PermissionInvitation.fromJson(Map<String, dynamic> json) =>
    _$PermissionInvitationFromJson(json);
}

/// Status of a permission invitation.
enum InvitationStatus {
  /// Waiting for assistant to accept
  pending,
  
  /// Assistant accepted the invitation
  accepted,
  
  /// Assistant declined the invitation
  declined,
  
  /// Invitation expired
  expired,
  
  /// Owner cancelled the invitation
  cancelled,
}

/// Audit log entry for tracking changes.
/// 
/// Every action by a PA is logged for accountability.
@freezed
class AuditLog with _$AuditLog {
  const factory AuditLog({
    /// Unique identifier (UUID)
    required String id,
    
    /// User who performed the action
    required String actorId,
    
    /// User whose data was affected
    required String ownerId,
    
    /// Type of action performed
    required String action,
    
    /// Type of resource affected
    required String resourceType,
    
    /// ID of the affected resource
    required String resourceId,
    
    /// State before the change
    Map<String, dynamic>? before,
    
    /// State after the change
    Map<String, dynamic>? after,
    
    /// When the action occurred
    required DateTime createdAt,
    
    /// IP address of the actor
    String? ipAddress,
    
    /// User agent of the actor
    String? userAgent,
  }) = _AuditLog;
  
  factory AuditLog.fromJson(Map<String, dynamic> json) =>
    _$AuditLogFromJson(json);
}
