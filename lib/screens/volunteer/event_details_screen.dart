import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/utils/format_utils.dart';
import '../../models/event_registration.dart';
import '../../models/volunteer_event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/rounded_card.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _actionBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final EventProvider provider = context.read<EventProvider>();
      if (!provider.loading && provider.events.isEmpty) provider.load();
      final String? uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) provider.loadMyRegistrations(uid);
    });
  }

  VolunteerEvent? get _event {
    final List<VolunteerEvent> events = context.read<EventProvider>().events;
    for (final VolunteerEvent event in events) {
      if (event.id == widget.eventId) return event;
    }
    return null;
  }

  Future<void> _register(VolunteerEvent event) async {
    final AuthProvider auth = context.read<AuthProvider>();
    setState(() => _actionBusy = true);
    final bool ok = await context.read<EventProvider>().register(
          event,
          volunteerId: auth.user!.uid,
          volunteerName: auth.volunteerProfile?.name ?? auth.user!.displayName ?? 'Volunteer',
        );
    if (!mounted) return;
    setState(() => _actionBusy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Registered! See you at the event.' : 'Could not register right now.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _unregister(EventRegistration registration) async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Leave this event?'),
            content: const Text('Your spot will be freed for another volunteer.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep spot')),
              TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Leave')),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    setState(() => _actionBusy = true);
    final bool ok = await context.read<EventProvider>().unregister(registration);
    if (!mounted) return;
    setState(() => _actionBusy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'You left this event.' : 'Could not update right now.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EventProvider provider = context.watch<EventProvider>();
    final VolunteerEvent? event = _event;

    if (event == null) {
      return Scaffold(
        body: Center(
          child: provider.loading
              ? const CircularProgressIndicator()
              : const Text('Event not found.'),
        ),
      );
    }

    final EventRegistration? registration = provider.registrationFor(event.id);
    final bool registered = provider.isRegistered(event.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.accent,
            leading: const _BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppGradients.success),
                child: Stack(
                  children: [
                    Align(
                      alignment: const Alignment(0.8, -0.2),
                      child: Icon(
                        Icons.event_available_rounded,
                        color: Colors.white.withValues(alpha: 0.25),
                        size: 140,
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.event_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  formatDate(event.date, pattern: 'EEEE, d MMM'),
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.ngoName,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoundedCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        InfoTile(
                          icon: Icons.schedule_rounded,
                          label: 'Time',
                          value: '${event.startTime} – ${event.endTime}',
                        ),
                        const Divider(height: 24),
                        InfoTile(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: event.location,
                        ),
                        const Divider(height: 24),
                        InfoTile(
                          icon: Icons.group_rounded,
                          label: 'Attendees',
                          value: '${event.registeredVolunteers} of ${event.maxVolunteers} registered',
                          iconColor: event.isFull ? AppColors.error : AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('About the event', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (registered) ...[
                    RoundedCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(Icons.event_available_rounded, color: AppColors.success),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('You are registered', style: Theme.of(context).textTheme.titleSmall),
                                const SizedBox(height: 4),
                                Text(
                                  'Mark your calendar and arrive 15 minutes early.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, -4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GradientButton(
                label: _actionBusy
                    ? 'Working…'
                    : registered
                        ? 'Registered'
                        : event.isFull
                            ? 'Event is full'
                            : 'Register for event',
                icon: registered || event.isFull ? null : Icons.event_available_rounded,
                onPressed: _actionBusy || (registered || event.isFull) ? null : () => _register(event),
              ),
              if (registered && registration != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: GhostButton(label: 'Leave event', onPressed: _actionBusy ? null : () => _unregister(registration)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.black.withValues(alpha: 0.18),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
    );
  }
}