import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.outlined = false});

  final String status;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final StatusMeta meta = _metaFor(status);
    final Color background = outlined ? Colors.white : meta.background;
    final Color foreground = outlined ? meta.color : meta.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: outlined ? Border.all(color: meta.color.withValues(alpha: 0.5)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            meta.label,
            style: GoogleFonts.poppins(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  StatusMeta _metaFor(String status) {
    final String normalized = status.trim().toLowerCase();
    switch (normalized) {
      case 'approved':
      case 'active':
      case 'open':
      case 'ongoing':
      case 'completed':
      case 'success':
        return const StatusMeta('Completed', AppColors.success, Color(0x1A22C55E));
      case 'pending':
      case 'upcoming':
        return const StatusMeta('Pending', AppColors.warning, Color(0x1AF59E0B));
      case 'rejected':
      case 'cancelled':
      case 'closed':
      case 'ended':
      case 'filled':
      case 'error':
      case 'failed':
        return const StatusMeta('Cancelled', AppColors.error, Color(0x1AEF4444));
      case 'started':
      case 'inprogress':
        return const StatusMeta('In progress', AppColors.info, Color(0x1A3B82F6));
      default:
        return StatusMeta(normalized, AppColors.textSecondary, Color(0x1A94A3B8));
    }
  }
}

class StatusMeta {
  const StatusMeta(this.label, this.color, this.background);

  final String label;
  final Color color;
  final Color background;
}