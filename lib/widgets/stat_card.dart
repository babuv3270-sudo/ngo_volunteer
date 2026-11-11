import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import 'rounded_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.gradient,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isGradient = gradient != null;
    final Color fg = isGradient ? Colors.white : AppColors.textPrimary;
    final Color sub = isGradient
        ? Colors.white.withValues(alpha: 0.9)
        : AppColors.textSecondary;

    return RoundedCard(
      onTap: onTap,
      gradient: gradient,
      padding: const EdgeInsets.all(AppSpacing.md),
      radius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isGradient
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isGradient ? Colors.white : AppColors.primary, size: 20),
            ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: fg,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sub),
          ),
        ],
      ),
    );
  }
}