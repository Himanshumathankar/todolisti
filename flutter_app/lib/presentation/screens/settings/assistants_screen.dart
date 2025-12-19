/// =============================================================================
/// Assistants Screen
/// =============================================================================
/// 
/// Manage Personal Assistants (PAs) who can help manage your tasks.
/// Configure permissions and review activity.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../../domain/entities/permission.dart';

/// Sample assistants data.
/// TODO: Replace with actual data from provider
final _sampleAssistants = [
  (
    name: 'Sarah Johnson',
    email: 'sarah.j@example.com',
    avatar: null,
    level: PermissionLevel.edit,
    since: DateTime.now().subtract(const Duration(days: 30)),
  ),
  (
    name: 'Mike Chen',
    email: 'mike.chen@example.com',
    avatar: null,
    level: PermissionLevel.view,
    since: DateTime.now().subtract(const Duration(days: 7)),
  ),
];

/// Assistants management screen.
class AssistantsScreen extends ConsumerWidget {
  const AssistantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Assistants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showInviteDialog(context),
            tooltip: 'Invite Assistant',
          ),
        ],
      ),
      body: _sampleAssistants.isEmpty
          ? _buildEmptyState(context)
          : _buildAssistantsList(context, ref),
      floatingActionButton: _sampleAssistants.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showInviteDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Invite Assistant'),
            )
          : null,
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Assistants Yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Invite a Personal Assistant to help manage your tasks and calendar.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAssistantsList(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _sampleAssistants.length,
      itemBuilder: (context, index) {
        final assistant = _sampleAssistants[index];
        return _buildAssistantCard(context, assistant);
      },
    );
  }
  
  Widget _buildAssistantCard(BuildContext context, dynamic assistant) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            _getInitials(assistant.name),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(assistant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assistant.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildPermissionBadge(assistant.level),
                const SizedBox(width: 8),
                Text(
                  'Since ${_formatDate(assistant.since)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value, assistant),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'permissions',
              child: ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text('Permissions'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'activity',
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('Activity'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'remove',
              child: ListTile(
                leading: Icon(Icons.person_remove, color: AppColors.error),
                title: Text('Remove', style: TextStyle(color: AppColors.error)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPermissionBadge(PermissionLevel level) {
    Color color;
    String label;
    
    switch (level) {
      case PermissionLevel.view:
        color = AppColors.info;
        label = 'View Only';
        break;
      case PermissionLevel.edit:
        color = AppColors.success;
        label = 'Can Edit';
        break;
      case PermissionLevel.full:
        color = AppColors.warning;
        label = 'Full Control';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  void _showInviteDialog(BuildContext context) {
    final emailController = TextEditingController();
    var selectedLevel = PermissionLevel.view;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Invite Assistant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'assistant@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              Text(
                'Permission Level',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...PermissionLevel.values.map((level) {
                return RadioListTile<PermissionLevel>(
                  title: Text(_getPermissionLabel(level)),
                  subtitle: Text(_getPermissionDescription(level)),
                  value: level,
                  groupValue: selectedLevel,
                  onChanged: (value) {
                    setState(() => selectedLevel = value!);
                  },
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Send invitation
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invitation sent to ${emailController.text}'),
                  ),
                );
              },
              child: const Text('Send Invitation'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _handleMenuAction(BuildContext context, String action, dynamic assistant) {
    switch (action) {
      case 'permissions':
        _showPermissionsDialog(context, assistant);
        break;
      case 'activity':
        // TODO: Navigate to activity screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Activity for ${assistant.name}')),
        );
        break;
      case 'remove':
        _showRemoveDialog(context, assistant);
        break;
    }
  }
  
  void _showPermissionsDialog(BuildContext context, dynamic assistant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permissions for ${assistant.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PermissionLevel.values.map((level) {
            return RadioListTile<PermissionLevel>(
              title: Text(_getPermissionLabel(level)),
              value: level,
              groupValue: assistant.level,
              onChanged: (value) {
                // TODO: Update permission
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showRemoveDialog(BuildContext context, dynamic assistant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Assistant'),
        content: Text(
          'Are you sure you want to remove ${assistant.name} as your assistant? '
          'They will lose all access to your tasks and calendar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Remove assistant
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${assistant.name} removed')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
  
  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays < 1) {
      return 'today';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${diff.inDays ~/ 7} weeks ago';
    } else {
      return '${diff.inDays ~/ 30} months ago';
    }
  }
  
  String _getPermissionLabel(PermissionLevel level) {
    switch (level) {
      case PermissionLevel.view:
        return 'View Only';
      case PermissionLevel.edit:
        return 'Can Edit';
      case PermissionLevel.full:
        return 'Full Control';
    }
  }
  
  String _getPermissionDescription(PermissionLevel level) {
    switch (level) {
      case PermissionLevel.view:
        return 'Can view tasks but not make changes';
      case PermissionLevel.edit:
        return 'Can view and edit tasks';
      case PermissionLevel.full:
        return 'Full access including delete and settings';
    }
  }
}
