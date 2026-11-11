import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format_utils.dart';
import '../../models/event_registration.dart';
import '../../models/volunteer_event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/rounded_card.dart';
import '../../widgets/shimmer_placeholder.dart';
import '../../widgets/status_badge.dart';

class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final EventProvider provider = context.watch<EventProvider>();
    final String ngoId = context.read<AuthProvider>().user?.uid ?? '';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Events', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 2),
                      Text(
                        '${provider.ngoEvents.where((e) => e.isUpcoming).length} upcoming · ${provider.ngoEvents.length} total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                FloatingActionButton.small(
                  heroTag: 'ngo-event-fab',
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.ngoEventForm,
                    arguments: null,
                  ),
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  tooltip: 'New event',
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => provider.loadNgo(ngoId),
              child: provider.ngoLoading && provider.ngoEvents.isEmpty
                  ? const ListShimmer(count: 4)
                  : provider.ngoEvents.isEmpty
                      ? EmptyState(
                          icon: Icons.event_outlined,
                          title: 'No events yet',
                          subtitle: 'Host your first event and invite volunteers to sign up.',
                          actionLabel: 'New event',
                          onAction: () => Navigator.of(context).pushNamed(
                            AppRoutes.ngoEventForm,
                            arguments: null,
                          ),
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
                          itemCount: provider.ngoEvents.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final VolunteerEvent event = provider.ngoEvents[index];
                            final List<EventRegistration> registrations = provider.registrationsForEvent(event.id);
                            return _EventRow(
                              event: event,
                              registeredCount: registrations.length,
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.ngoRegistrations,
                                arguments: event.id,
                              ),
                              onEdit: () => Navigator.of(context).pushNamed(
                                AppRoutes.ngoEventForm,
                                arguments: event,
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.event,
    required this.registeredCount,
    required this.onTap,
    required this.onEdit,
  });

  final VolunteerEvent event;
  final int registeredCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.accent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${event.date.day}',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1),
                      ),
                      Text(
                        _months[event.date.month - 1].toUpperCase(),
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatDate(event.date)} · ${event.startTime} – ${event.endTime}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: event.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '$registeredCount signed up',
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}