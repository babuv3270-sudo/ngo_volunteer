import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/utils/format_utils.dart';
import '../../models/application.dart';
import '../../models/volunteer_event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/avatar_pill.dart';
import '../../widgets/event_card.dart';
import '../../widgets/gradient_scaffold.dart';
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

    final String name = auth.ngoProfile?.name ?? auth.user?.displayName ?? 'Organization';
    final int openCauses = opportunities.ngoOpportunities.where((o) => o.isOpen).length;
    final int pendingRequests = opportunities.ngoApplications.where((a) => a.isPending).length;
    final int registrations = events.ngoRegistrations.length;
    final int upcomingEvents = events.ngoEvents.where((e) => e.isUpcoming).length;
    final double hoursLogged = events.ngoRegistrations.where((r) => r.attended).fold(
          0.0,
          (sum, r) => sum + r.volunteerHours,
        );
    final List<Application> recent =
        opportunities.ngoApplications.where((a) => a.status == 'pending').toList();
    final List<VolunteerEvent> upcoming =
        events.ngoEvents.where((e) => e.isUpcoming).take(3).toList();

    return GradientScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final String? uid = auth.user?.uid;
            if (!auth.isSignedIn || uid == null || !context.mounted) return;
            await opportunities.loadNgo(uid);
            await events.loadNgo(uid);
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
                    imageUrl: auth.ngoProfile?.logo,
                    name: name,
                    size: 44,
                  ),
                  bottom: Row(
                    children: [
                      _heroPill(
                        icon: Icons.volunteer_activism_outlined,
                        text: '$openCauses causes',
                      ),
                      const SizedBox(width: 8),
                      _heroPill(
                        icon: Icons.hourglass_top_rounded,
                        text: '$pendingRequests requests',
                      ),
                      const SizedBox(width: 8),
                      _heroPill(
                        icon: Icons.notifications_active_outlined,
                        text: '${notifications.unreadCount} new',
                      ),
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
                            value: '$openCauses',
                            label: 'Open causes',
                            icon: Icons.volunteer_activism_rounded,
                            onTap: () => onNavigateToTab?.call(1),
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            value: '$pendingRequests',
                            label: 'Pending requests',
                            icon: Icons.hourglass_top_rounded,
                            onTap: () => onNavigateToTab?.call(1),
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            value: '$registrations',
                            label: 'Sign ups',
                            icon: Icons.groups_rounded,
                            onTap: () => onNavigateToTab?.call(2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Impact at a glance',
                        subtitle: 'Hours logged by volunteers',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              value: hoursLogged == hoursLogged.roundToDouble()
                                  ? '${hoursLogged.toInt()}'
                                  : hoursLogged.toStringAsFixed(1),
                              label: 'Hours logged',
                              icon: Icons.timer_rounded,
                              gradient: AppGradients.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              value: '$upcomingEvents',
                              label: 'Upcoming events',
                              icon: Icons.event_rounded,
                              gradient: AppGradients.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Pending applications',
                        subtitle: 'Volunteers waiting for a decision',
                        actionLabel: 'Review all',
                        onAction: () => onNavigateToTab?.call(1),
                      ),
                      const SizedBox(height: 14),
                      if (opportunities.ngoLoading)
                        const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (recent.isEmpty)
                        const _EmptyBlock(text: 'No pending applications. New requests will appear here.')
                      else
                        Column(
                          children: recent.take(3).map((application) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ApplicationRow(application: application),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Upcoming events',
                        actionLabel: 'Manage',
                        onAction: () => onNavigateToTab?.call(2),
                      ),
                      const SizedBox(height: 14),
                      if (events.ngoLoading)
                        const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (upcoming.isEmpty)
                        const _EmptyBlock(text: 'No upcoming events. Create one from the Events tab.')
                      else
                        Column(
                          children: upcoming.map((event) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: EventCard(
                                event: event,
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.ngoRegistrations,
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

class _ApplicationRow extends StatelessWidget {
  const _ApplicationRow({required this.application});

  final Application application;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          AvatarPill(name: application.volunteerName, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(application.volunteerName, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  application.opportunityTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeAgo(application.appliedAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted, fontSize: 11.5),
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