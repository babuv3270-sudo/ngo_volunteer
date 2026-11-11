import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';

class RoundedCard extends StatelessWidget {
  const RoundedCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = AppColors.surface,
    this.gradient,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadius.lg,
    this.elevated = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      scale: 1,
      duration: AppDurations.fast,
      child: Container(
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
          boxShadow: elevated
              ? AppShadows.soft
              : [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Padding(padding: padding, child: child),
                ),
              )
            : Padding(padding: padding, child: child),
      ),
    );
  }
}

class GradientCoverCard extends StatelessWidget {
  const GradientCoverCard({
    super.key,
    required this.child,
    this.gradient = AppGradients.primary,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
  });

  final Widget child;
  final Gradient gradient;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.55),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: Colors.white.withValues(alpha: 0.16),
                child: Padding(padding: padding, child: child),
              ),
            )
          : Padding(padding: padding, child: child),
    );
  }
}