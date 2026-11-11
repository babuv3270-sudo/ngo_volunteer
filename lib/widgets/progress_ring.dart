import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.valueLabel,
    this.radius = 34,
    this.stroke = 7,
    this.valueLabelSize = 14,
    this.subLabel,
  });

  final double progress;
  final String valueLabel;
  final double radius;
  final double stroke;
  final double valueLabelSize;
  final String? subLabel;

  @override
  Widget build(BuildContext context) {
    final double clamped = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: CustomPaint(
        painter: _RingPainter(
          progress: clamped,
          strokeWidth: stroke,
          background: AppColors.surfaceMuted,
          gradient: AppGradients.primaryCompact,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  valueLabel,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: valueLabelSize,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
              if (subLabel != null)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subLabel!,
                    style: GoogleFonts.poppins(
                      color: AppColors.textMuted,
                      fontSize: valueLabelSize * 0.7,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.background,
    required this.gradient,
  });

  final double progress;
  final double strokeWidth;
  final Color background;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final Offset center = rect.center;
    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = background;
    canvas.drawCircle(center, radius, trackPaint);

    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.gradient != gradient ||
      oldDelegate.background != background;
}