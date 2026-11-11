import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/utils/format_utils.dart';
import '../../models/application.dart';
import '../../models/app_user.dart';
import '../../models/event_registration.dart';
import '../../models/volunteer_event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/achievement_badge.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/event_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/rounded_card.dart';
import '../../widgets/segmented_control.dart';
import '../../widgets/status_badge.dart';

class ActivitiesTab extends StatefulWidget {
  const ActivitiesTab({super.key});

  @override
  State<ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<ActivitiesTab> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final OpportunityProvider opportunities = context.watch<OpportunityProvider>();
    final EventProvider events = context.watch<EventProvider>();
    final AuthProvider auth = context.watch<AuthProvider>();
    final AppUser? profile = auth.volunteerProfile;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Activities', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  'Your journey of impact, all in one place',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.md),
                SegmentedControl(
                  options: const ['Applications', 'Events', 'Hours', 'Badges'],
                  selected: _segment,
                  onChanged: (index) => setState(() => _segment = index),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildContent(
                context,
                opportunities: opportunities,
                events: events,
                profile: profile,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required OpportunityProvider opportunities,
    required EventProvider events,
    required AppUser? profile,
  }) {
    switch (_segment) {
      case 0:
        return _ApplicationsList(applications: opportunities.myApplications);
      case 1:
        return _EventsList(eventsProvider: events);
      case 2:
        return _HoursList(eventsProvider: events, profile: profile);
      default:
        return _BadgesList(profile: profile);
    }
  }
}

class _ApplicationsList extends StatelessWidget {
  const _ApplicationsList({required this.applications});

  final List<Application> applications;

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return const EmptyState(
        icon: Icons.send_outlined,
        title: 'No applications yet',
        subtitle: 'Head to Explore and apply for a cause that speaks to you.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      itemCount: applications.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final Application application = applications[index];
        return RoundedCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.volunteer_activism_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.opportunityTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Applied ${timeAgo(application.appliedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StatusBadge(status: application.status),
            ],
          ),
        );
      },
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({required this.eventsProvider});

  final EventProvider eventsProvider;

  @override
  Widget build(BuildContext context) {
    final List<EventRegistration> registrations = eventsProvider.myRegistrations;
    if (registrations.isEmpty) {
      return const EmptyState(
        icon: Icons.event_available_outlined,
        title: 'No events yet',
        subtitle: 'Register for an event from your dashboard to track it here.',
      );
    }

    final Map<String, VolunteerEvent> byId = {
      for (final event in eventsProvider.events) event.id: event,
    };

    final List<EventRegistration> upcoming =
        registrations.where((r) => !r.attended && byId[r.eventId]?.isUpcoming != false).toList();
    final List<EventRegistration> completed = registrations.where((r) => r.attended).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      children: [
        if (upcoming.isNotEmpty) ...[
          Text('Upcoming', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...upcoming.map((registration) {
            final VolunteerEvent? event = byId[registration.eventId];
            if (event == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EventCard(
                event: event,
                registered: true,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.eventDetails, arguments: event.id),
              ),
            );
          }),
        ],
        if (completed.isNotEmpty) ...[
          if (upcoming.isNotEmpty) const SizedBox(height: 8),
          Text('Completed', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...completed.map((registration) {
            final VolunteerEvent? event = byId[registration.eventId];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RoundedCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event?.title ?? registration.eventTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            event == null ? '${registration.volunteerHours} hrs' : '${formatDate(event.date)} · ${registration.volunteerHours} hrs',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${registration.volunteerHours}h',
                      style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _HoursList extends StatelessWidget {
  const _HoursList({required this.eventsProvider, required this.profile});

  final EventProvider eventsProvider;
  final AppUser? profile;

  @override
  Widget build(BuildContext context) {
    final List<EventRegistration> attended = eventsProvider.attendedRegistrations;
    final double hours = eventsProvider.totalHours;
    final int profileHours = profile?.totalHours ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      children: [
        RoundedCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gradient: AppGradients.primary,
          child: Row(
            children: [
              ProgressRing(
                progress: (hours / 100).clamp(0.0, 1.0),
                valueLabel: '${hours.round()}',
                subLabel: 'hours',
                radius: 42,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total hours served',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profileHours > 0 ? 'Verified by your NGO partners.' : 'Hours are added after you check in.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Breakdown', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (attended.isEmpty)
          const EmptyState(
            icon: Icons.hourglass_empty_rounded,
            title: 'No hours yet',
            subtitle: 'Attend an event and your service hours will show up here.',
          )
        else
          ...attended.map((registration) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RoundedCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.timer_rounded, color: AppColors.info),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            registration.eventTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            timeAgo(registration.registeredAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${registration.volunteerHours}h',
                      style: GoogleFonts.poppins(color: AppColors.success, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _BadgesList extends StatelessWidget {
  const _BadgesList({required this.profile});

  final AppUser? profile;

  @override
  Widget build(BuildContext context) {
    final Set<String> earned = (profile?.badges ?? const []).toSet();

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: kAllBadges.length,
      itemBuilder: (context, index) {
        final String badge = kAllBadges[index];
        return AchievementBadge(
          label: badge,
          unlocked: earned.contains(badge),
          icon: Icons.military_tech_rounded,
        );
      },
    );
  }
}