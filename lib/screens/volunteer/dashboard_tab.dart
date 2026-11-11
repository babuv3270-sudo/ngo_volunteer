import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format_utils.dart';
import '../../models/opportunity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/avatar_pill.dart';
import '../../widgets/event_card.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/rounded_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key, this.onNavigateToTab});

  final ValueChanged<int>? onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final OpportunityProvider opportunities = context.watch<OpportunityProvider>();
    final EventProvider events = context.watch<EventProvider>();
    final NotificationProvider notifications = context.watch<NotificationProvider>();

    final String name = auth.volunteerProfile?.name ?? auth.user?.displayName ?? 'Volunteer';
    final int hours = auth.volunteerProfile?.totalHours ?? events.totalHours.round();
    final int badges = auth.volunteerProfile?.badges.length ?? 0;
    final int hoursToNextMilestone = 100 - (hours % 100);
    final int nextMilestone = ((hours ~/ 100) + 1) * 100;
    final List<Opportunity> recommendations = opportunities.recommendations(limit: 5);

    return GradientScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final String? uid = auth.user?.uid;
            await opportunities.load();
            if (!auth.isSignedIn || uid == null || !context.mounted) return;
            await opportunities.loadMyApplications(uid);
            await events.load();
            await events.loadMyRegistrations(uid);
            await notifications.load(uid);
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientHeader(
                  title: '${greetingFor(DateTime.now())}!',
                  subtitle: name,
                  trailing: AvatarPill(
                    imageUrl: auth.volunteerProfile?.profileImage,
                    name: name,
                    size: 44,
                  ),
                  bottom: Row(
                    children: [
                      _heroPill(icon: Icons.schedule_rounded, text: '$hours hrs given'),
                      const SizedBox(width: 8),
                      _heroPill(icon: Icons.emoji_events_rounded, text: '$badges badges'),
                      const SizedBox(width: 8),
                      _heroPill(icon: Icons.notifications_active_outlined, text: '${notifications.unreadCount} new'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatCard(
                            value: '${events.upcomingEvents.length}',
                            label: 'Upcoming events',
                            icon: Icons.event_rounded,
                            onTap: () => onNavigateToTab?.call(2),
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            value: '${opportunities.myApplications.where((a) => a.isPending).length}',
                            label: 'Pending replies',
                            icon: Icons.hourglass_top_rounded,
                            onTap: () => onNavigateToTab?.call(2),
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            value: '${opportunities.all.length}',
                            label: 'Open causes',
                            icon: Icons.volunteer_activism_rounded,
                            onTap: () => onNavigateToTab?.call(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SectionHeader(
                        title: 'Volunteer hours',
                        subtitle: 'Your impact so far',
                      ),
                      const SizedBox(height: 12),
                      RoundedCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            ProgressRing(
                              progress: (hours / 100).clamp(0.0, 1.0),
                              valueLabel: '$hours',
                              subLabel: 'hours',
                              radius: 40,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Keep it going!', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text(
                                    'You are $hoursToNextMilestone hours away from the $nextMilestone-hour milestone.',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Recommended causes',
                        subtitle: 'Hand-picked for your skills',
                        actionLabel: 'See all',
                        onAction: () => onNavigateToTab?.call(1),
                      ),
                      const SizedBox(height: 14),
                      if (opportunities.loading)
                        const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (recommendations.isEmpty)
                        const _EmptyBlock(text: 'No opportunities yet. Check back soon.')
                      else
                        SizedBox(
                          height: 296,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: recommendations.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final Opportunity opportunity = recommendations[index];
                              return SizedBox(
                                width: 280,
                                child: OpportunityCard(
                                  opportunity: opportunity,
                                  compact: true,
                                  applied: opportunities.hasApplied(opportunity.id),
                                  onTap: () => Navigator.of(context).pushNamed(
                                    AppRoutes.opportunityDetails,
                                    arguments: opportunity.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Upcoming events',
                        actionLabel: 'Browse',
                        onAction: () => onNavigateToTab?.call(2),
                      ),
                      const SizedBox(height: 14),
                      if (events.loading)
                        const SizedBox(
                          height: 160,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (events.upcomingEvents.isEmpty)
                        const _EmptyBlock(text: 'No upcoming events right now.')
                      else
                        Column(
                          children: events.upcomingEvents.take(3).map((event) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: EventCard(
                                event: event,
                                registered: events.isRegistered(event.id),
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.eventDetails,
                                  arguments: event.id,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
      ),
    );
  }
}