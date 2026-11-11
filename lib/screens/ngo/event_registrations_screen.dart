import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/event_registration.dart';
import '../../providers/event_provider.dart';
import '../../widgets/avatar_pill.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/rounded_card.dart';
import '../../widgets/status_badge.dart';

class EventRegistrationsScreen extends StatefulWidget {
  const EventRegistrationsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventRegistrationsScreen> createState() => _EventRegistrationsScreenState();
}

class _EventRegistrationsScreenState extends State<EventRegistrationsScreen> {
  String _busyId = '';

  Future<void> _checkIn(EventRegistration registration) async {
    final TextEditingController hoursController = TextEditingController(text: '3');
    final double? hours = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Check-in volunteer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Log hours for ${registration.volunteerName}',
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hoursController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Hours').applyDefaults(
                Theme.of(dialogContext).inputDecorationTheme,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final double? value = double.tryParse(hoursController.text.trim());
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Check in'),
          ),
        ],
      ),
    );
    if (hours == null || hours <= 0 || !mounted) return;

    setState(() => _busyId = registration.id);
    final bool ok = await context.read<EventProvider>().checkInVolunteer(registration, hours: hours);
    if (!mounted) return;
    setState(() => _busyId = '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Check-in saved. Hours logged.' : 'Could not check in. Try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EventProvider provider = context.watch<EventProvider>();
    final List<EventRegistration> registrations = provider.registrationsForEvent(widget.eventId);
    final int attended = registrations.where((r) => r.attended).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer registrations'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$attended attended so far',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ),
                Text(
                  '${registrations.length} signed up',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.ngoLoading
                ? const Center(child: CircularProgressIndicator())
                : registrations.isEmpty
                    ? const EmptyState(
                        icon: Icons.person_add_alt_1_outlined,
                        title: 'No registrations yet',
                        subtitle: 'Volunteers who sign up for this event will appear here.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: registrations.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final EventRegistration registration = registrations[index];
                          final bool busy = _busyId == registration.id;
                          return RoundedCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    AvatarPill(name: registration.volunteerName, size: 44),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            registration.volunteerName,
                                            style: Theme.of(context).textTheme.titleSmall,
                                          ),
                                          if (registration.attended) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              '${registration.volunteerHours} hours logged',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.success,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (registration.attended)
                                      const StatusBadge(status: 'Completed'),
                                  ],
                                ),
                                if (!registration.attended) ...[
                                  const SizedBox(height: 14),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      height: 40,
                                      width: 160,
                                      child: OutlinedButton.icon(
                                        onPressed: busy ? null : () => _checkIn(registration),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          side: const BorderSide(color: AppColors.primary),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(AppRadius.md),
                                          ),
                                        ),
                                        icon: busy
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )
                                            : const Icon(Icons.check_circle_outline_rounded, size: 18),
                                        label: const Text('Check in'),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}