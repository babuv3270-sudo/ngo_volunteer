import 'package:flutter/material.dart';

import '../core/theme/app_gradients.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.gradient = AppGradients.primary,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final Gradient gradient;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      extendBody: bottomNavigationBar != null,
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: gradient),
        child: body,
      ),
    );
  }
}

class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    this.gradient = AppGradients.primary,
    this.foregroundColor = Colors.white,
    this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.height,
    this.bottomRadius = const BorderRadius.vertical(bottom: Radius.circular(28)),
  });

  final Gradient gradient;
  final Color foregroundColor;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final double? height;
  final BorderRadius bottomRadius;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: gradient, borderRadius: bottomRadius),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: textTheme.headlineSmall?.copyWith(
                              color: foregroundColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: foregroundColor.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}