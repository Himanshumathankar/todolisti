/// =============================================================================
/// Login Screen
/// =============================================================================
/// 
/// Authentication screen with Google Sign-In.
/// Clean, minimal design following ADHD-friendly UX principles.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/common/app_button.dart';

/// Login screen with Google Sign-In.
/// 
/// Features:
/// - App branding and value proposition
/// - Single sign-in button (minimal cognitive load)
/// - Error handling with user feedback
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.valueOrNull?.isLoading ?? false;
    final error = authState.valueOrNull?.error;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // App logo and branding
              _buildHeader(context),
              
              const SizedBox(height: 48),
              
              // Value proposition
              _buildValueProposition(context),
              
              const Spacer(),
              
              // Error message
              if (error != null) ...[
                _buildErrorMessage(context, error),
                const SizedBox(height: 16),
              ],
              
              // Sign in button
              _buildSignInButton(context, ref, isLoading),
              
              const SizedBox(height: 24),
              
              // Terms and privacy
              _buildLegalLinks(context),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // App icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        
        // App name
        Text(
          'TodoListi',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Tagline
        Text(
          'Your productivity companion',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildValueProposition(BuildContext context) {
    final features = [
      (Icons.calendar_today, 'Calendar & Timeline'),
      (Icons.check_box, 'Smart Task Management'),
      (Icons.people_outline, 'Personal Assistant Mode'),
      (Icons.sync, 'Google Calendar Sync'),
    ];
    
    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  feature.$1,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                feature.$2,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildErrorMessage(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSignInButton(BuildContext context, WidgetRef ref, bool isLoading) {
    return AppButton(
      label: 'Continue with Google',
      icon: Icons.login,
      isLoading: isLoading,
      onPressed: isLoading
          ? null
          : () => ref.read(authStateProvider.notifier).signInWithGoogle(),
      style: AppButtonStyle.primary,
      isFullWidth: true,
    );
  }
  
  Widget _buildLegalLinks(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: Theme.of(context).textTheme.bodySmall,
        children: const [
          TextSpan(
            text: 'Terms',
            style: TextStyle(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
