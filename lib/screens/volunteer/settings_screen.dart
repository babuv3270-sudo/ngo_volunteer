import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.profileTitle = 'Volunteer profile',
    this.profileSubtitle = 'Skills, interests and details',
    this.editProfileRoute = AppRoutes.editProfile,
  });

  final String profileTitle;
  final String profileSubtitle;
  final String editProfileRoute;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _eventAlerts = true;
  bool _opportunityAlerts = true;
  bool _emailDigest = false;

  Future<void> _confirmSignOut() async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Sign out?'),
            content: const Text('You can sign back in anytime with the same account.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Stay')),
              TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Sign out')),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.splash, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _group(Column(
            children: [
              SwitchListTile(
                value: _eventAlerts,
                onChanged: (value) => setState(() => _eventAlerts = value),
                title: const Text('Event reminders'),
                subtitle: const Text('Get notified before your registered events'),
                activeTrackColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                value: _opportunityAlerts,
                onChanged: (value) => setState(() => _opportunityAlerts = value),
                title: const Text('Opportunity alerts'),
                subtitle: const Text('New causes matched to your profile'),
                activeTrackColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                value: _emailDigest,
                onChanged: (value) => setState(() => _emailDigest = value),
                title: const Text('Weekly digest'),
                subtitle: const Text('A summary of your impact every week'),
                activeTrackColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          )),
          const SizedBox(height: AppSpacing.lg),
          Text('Account', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _group(Column(children: [
            SettingsTile(
              icon: Icons.volunteer_activism_rounded,
              title: widget.profileTitle,
              subtitle: widget.profileSubtitle,
              onTap: () => Navigator.of(context).pushNamed(widget.editProfileRoute),
            ),
            const Divider(height: 1, indent: 52, endIndent: 16),
            SettingsTile(
              icon: Icons.shield_outlined,
              title: 'Privacy',
              subtitle: 'Who can see your profile',
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ),
            const Divider(height: 1, indent: 52, endIndent: 16),
            SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & support',
              subtitle: 'FAQs and contact us',
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ),
          ])),
          const SizedBox(height: AppSpacing.lg),
          _group(Column(children: [
            SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Sign out',
              subtitle: 'End your session on this device',
              iconColor: AppColors.error,
              iconBackground: AppColors.error.withValues(alpha: 0.1),
              onTap: _confirmSignOut,
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ),
          ])),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'NGOVolunteer v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}