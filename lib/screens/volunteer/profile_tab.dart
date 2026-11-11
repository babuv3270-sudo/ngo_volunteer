import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format_utils.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/avatar_pill.dart';
import '../../widgets/settings_tile.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  String _milestoneName(int hours) {
    if (hours >= 25) return '25 Hour Champion';
    if (hours >= 10) return '10 Hour Hero';
    if (hours >= 1) return 'First Step';
    return 'Join an event to begin';
  }

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
    final EventProvider events = context.watch<EventProvider>();
    final AppUser profile = auth.volunteerProfile ?? const AppUser(uid: '', name: '', email: '', role: UserRole.volunteer);
    final String name = profile.name.isNotEmpty ? profile.name : (auth.user?.displayName ?? 'Volunteer');
    final int hours = profile.totalHours;
    final List<String> nameParts = name.trim().split(RegExp(r'\s+'));
    final String lastName = nameParts.isEmpty ? name : nameParts.last;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvatarPill(imageUrl: profile.profileImage, name: name, size: 76),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi, $name', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            profile.location ?? 'Your city',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Joined ${profile.createdAt != null ? formatDate(profile.createdAt!) : 'recently'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ImpactStat(
                  value: '$hours',
                  label: 'Hours',
                  icon: Icons.timer_rounded,
                  color: AppColors.primary,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ImpactStat(
                  value: '${profile.badges.length}',
                  label: 'Badges',
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.warning,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ImpactStat(
                  value: '${events.attendedRegistrations.length}',
                  label: 'Events',
                  icon: Icons.event_available_rounded,
                  color: AppColors.accent,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next milestone', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  _milestoneName(hours),
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (hours % 25) / 25,
                    minHeight: 7,
                    backgroundColor: AppColors.surfaceMuted,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${25 - (hours % 25)} hr${25 - (hours % 25) == 1 ? '' : 's'} to your next badge',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (profile.skills.isNotEmpty) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Skills', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          skill,
                          style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
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
                  title: 'Edit profile',
                  subtitle: lastName.isEmpty ? 'Update your details' : '$lastName · ${profile.email}',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
                ),
                const Divider(height: 1, indent: 52, endIndent: 16),
                SettingsTile(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  subtitle: 'Notifications and preferences',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
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
        ],
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  const _ImpactStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
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