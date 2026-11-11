import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/volunteer_event.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.registered = false, this.onTap});

  final VolunteerEvent event;
  final bool registered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final bool past = event.date.isBefore(DateTime(now.year, now.month, now.day));

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 18),
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          _registeredPill(registered),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(event.ngoName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 15, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('${event.startTime} – ${event.endTime}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.5)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 15, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(event.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 36,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: past ? const LinearGradient(colors: [AppColors.textMuted, AppColors.divider]) : _eventGradient(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${event.date.day}',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  _months[event.date.month - 1].toUpperCase(),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LinearGradient _eventGradient() {
    return const LinearGradient(
      colors: [AppColors.secondary, AppColors.accent],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  Widget _registeredPill(bool registered) {
    if (!registered) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Registered',
        style: GoogleFonts.poppins(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}