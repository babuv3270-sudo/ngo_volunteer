import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    this.onPressed,
    required this.label,
    this.icon,
    this.loading = false,
    this.disabled = false,
    this.gradient = AppGradients.primaryCompact,
    this.height = 52,
    this.radius = AppRadius.lg,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool loading;
  final bool disabled;
  final Gradient gradient;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !loading && !disabled;
    const Color fg = Colors.white;

    return Opacity(
      opacity: isEnabled ? 1 : 0.55,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0x402563EB),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(radius),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: fg, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            color: fg,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    this.onPressed,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
    this.borderColor = AppColors.divider,
    this.height = 52,
    this.radius = AppRadius.lg,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final Color color;
  final Color borderColor;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}