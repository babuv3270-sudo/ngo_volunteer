import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format_utils.dart';
import '../../models/ngo_profile.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/avatar_pill.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/settings_tile.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
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
    if (!confirmed || !context.mounted) return;
    await context.read<AuthProvider>().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.splash, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final NgoProfile? profile = auth.ngoProfile;
    final String name = profile?.name ?? auth.user?.displayName ?? 'Organization';
    final String description = profile?.description ?? '';
    final String city = profile?.city ?? '';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvatarPill(imageUrl: profile?.logo, name: name, size: 76),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    if (description.isNotEmpty)
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      city.isNotEmpty ? city : 'Your city',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (profile != null &&
              (profile.email != null || profile.phone != null || profile.website != null || profile.address != null)) ...[
            _SectionCard(
              child: Column(
                children: [
                  if (profile.email != null && profile.email!.isNotEmpty)
                    InfoTile(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: profile.email!,
                    ),
                  if (profile.phone != null && profile.phone!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: profile.phone!,
                      ),
                    ),
                  if (profile.website != null && profile.website!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: InfoTile(
                        icon: Icons.public_rounded,
                        label: 'Website',
                        value: profile.website!,
                      ),
                    ),
                  if (profile.address != null && profile.address!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: InfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: profile.address!,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          _SectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit organization profile',
                  subtitle: 'About, contact and location',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.editNgoProfile),
                ),
                const Divider(height: 1, indent: 52, endIndent: 16),
                SettingsTile(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  subtitle: 'Notifications and preferences',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.ngoSettings),
                ),
                const Divider(height: 1, indent: 52, endIndent: 16),
                SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Sign out',
                  iconColor: AppColors.error,
                  iconBackground: AppColors.error.withValues(alpha: 0.1),
                  onTap: () => _confirmSignOut(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Member since ${profile?.createdAt != null ? formatDate(profile!.createdAt!, pattern: 'MMM yyyy') : 'recently'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.padding = const EdgeInsets.all(AppSpacing.lg)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
      ),
      child: child,
    );
  }
}