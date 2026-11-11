import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';

const List<String> kAllBadges = [
  'First Step',
  '10 Hour Hero',
  '25 Hour Champion',
  'Community Star',
  'Team Player',
  'Event Regular',
];

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.label,
    this.unlocked = false,
    this.icon = Icons.emoji_events_rounded,
    this.size = 64,
  });

  final String label;
  final bool unlocked;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool gray = !unlocked;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: gray ? AppGradients.subtleCard : AppGradients.primary,
            borderRadius: BorderRadius.circular(size / 3),
            border: Border.all(
              color: gray ? AppColors.divider : AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: gray
              ? Icon(icon, color: AppColors.textMuted, size: size * 0.45)
              : const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: size + 16,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: gray ? AppColors.textMuted : AppColors.textPrimary,
              fontSize: 11,
              fontWeight: gray ? FontWeight.w500 : FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}