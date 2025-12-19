/// =============================================================================
/// Project Entity
/// =============================================================================
/// 
/// Core domain entity representing a project that contains tasks.
/// Projects provide organizational structure for related tasks.
/// =============================================================================
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

/// Project entity for organizing related tasks.
/// 
/// Projects can have:
/// - Custom color and icon
/// - Multiple tasks
/// - Archived status
@freezed
class Project with _$Project {
  const Project._();
  
  const factory Project({
    /// Unique identifier (UUID)
    required String id,
    
    /// Owner user ID
    required String userId,
    
    /// Project name
    required String name,
    
    /// Optional description
    String? description,
    
    /// Color in hex format (e.g., '#3B82F6')
    @Default('#3B82F6') String color,
    
    /// Icon name from Material Icons
    @Default('folder') String icon,
    
    /// Position for ordering
    @Default(0) int position,
    
    /// Whether the project is archived
    @Default(false) bool isArchived,
    
    /// Creation timestamp
    required DateTime createdAt,
    
    /// Last update timestamp
    required DateTime updatedAt,
    
    /// Sync version for conflict detection
    @Default(0) int syncVersion,
  }) = _Project;
  
  factory Project.fromJson(Map<String, dynamic> json) =>
    _$ProjectFromJson(json);
}

/// Tag entity for labeling tasks.
/// 
/// Tags provide cross-cutting categorization independent of projects.
@freezed
class Tag with _$Tag {
  const factory Tag({
    /// Unique identifier (UUID)
    required String id,
    
    /// Owner user ID
    required String userId,
    
    /// Tag name
    required String name,
    
    /// Color in hex format
    @Default('#6B7280') String color,
    
    /// Creation timestamp
    required DateTime createdAt,
  }) = _Tag;
  
  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}
