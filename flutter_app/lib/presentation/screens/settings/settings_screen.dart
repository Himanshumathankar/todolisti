/// =============================================================================
/// Settings Screen
/// =============================================================================
/// 
/// Application settings with sections for account, appearance,
/// notifications, sync, and more.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/colors.dart';

/// Settings screen with grouped options.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account section
          _buildAccountSection(context, ref, user),
          
          const Divider(),
          
          // Appearance section
          _buildAppearanceSection(context, ref, themeMode),
          
          const Divider(),
          
          // Sync section
          _buildSyncSection(context, ref),
          
          const Divider(),
          
          // Assistants section
          _buildAssistantsSection(context, ref),
          
          const Divider(),
          
          // Notifications section
          _buildNotificationsSection(context, ref),
          
          const Divider(),
          
          // About section
          _buildAboutSection(context),
          
          const SizedBox(height: 24),
          
          // Sign out button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _signOut(context, ref),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
          
          const SizedBox(height: 48),
        ],
      ),
    );
  }
  
  Widget _buildAccountSection(BuildContext context, WidgetRef ref, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Account'),
        ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: user?.avatarUrl != null
                ? NetworkImage(user.avatarUrl)
                : null,
            child: user?.avatarUrl == null
                ? Text(
                    user?.initials ?? '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(user?.name ?? 'User'),
          subtitle: Text(user?.email ?? ''),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to profile edit
          },
        ),
      ],
    );
  }
  
  Widget _buildAppearanceSection(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Appearance'),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Theme'),
          subtitle: Text(_getThemeModeLabel(themeMode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeDialog(context, ref, themeMode),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.text_fields),
          title: const Text('Large Text'),
          subtitle: const Text('Increase text size for readability'),
          value: false, // TODO: Implement
          onChanged: (value) {
            // TODO: Toggle large text
          },
        ),
      ],
    );
  }
  
  Widget _buildSyncSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Sync & Calendar'),
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text('Sync Now'),
          subtitle: const Text('Last synced: Just now'),
          onTap: () {
            // TODO: Trigger sync
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Syncing...')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Google Calendar'),
          subtitle: const Text('Connected'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to calendar settings
          },
        ),
      ],
    );
  }
  
  Widget _buildAssistantsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Personal Assistants'),
        ListTile(
          leading: const Icon(Icons.people_outline),
          title: const Text('Manage Assistants'),
          subtitle: const Text('Add or remove PAs'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/settings/assistants'),
        ),
        ListTile(
          leading: const Icon(Icons.admin_panel_settings_outlined),
          title: const Text('Permission Requests'),
          subtitle: const Text('Review access requests'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '2',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          onTap: () {
            // TODO: Navigate to permission requests
          },
        ),
      ],
    );
  }
  
  Widget _buildNotificationsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Notifications'),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive reminders and updates'),
          value: true, // TODO: Get from settings
          onChanged: (value) {
            // TODO: Toggle notifications
          },
        ),
        ListTile(
          leading: const Icon(Icons.access_time),
          title: const Text('Default Reminder Time'),
          subtitle: const Text('30 minutes before'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Show reminder time picker
          },
        ),
      ],
    );
  }
  
  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'About'),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Version'),
          subtitle: Text('1.0.0 (Build 1)'),
        ),
        ListTile(
          leading: const Icon(Icons.article_outlined),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            // TODO: Open terms
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            // TODO: Open privacy policy
          },
        ),
      ],
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeModeLabel(mode)),
              value: mode,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _signOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
