import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary, AppColors.accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient primaryCompact = LinearGradient(
    colors: [AppColors.primary, AppColors.accent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient sunrise = LinearGradient(
    colors: [AppColors.secondary, AppColors.accent, AppColors.tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient success = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warning = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient danger = LinearGradient(
    colors: [Color(0xFFF87171), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient info = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleCard = LinearGradient(
    colors: [Color(0x1A10B981), Color(0x0D2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration primaryBoxDecoration({double radius = 20}) =>
      BoxDecoration(gradient: primary, borderRadius: BorderRadius.circular(radius));

  static BoxDecoration subtleBoxDecoration({double radius = 20}) => BoxDecoration(
        gradient: subtleCard,
        borderRadius: BorderRadius.circular(radius),
      );
}