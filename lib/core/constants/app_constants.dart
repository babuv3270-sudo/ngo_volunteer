import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

abstract final class AppSizes {
  static const double cardWidth = 300;
  static const double avatarS = 32;
  static const double avatarM = 44;
  static const double avatarL = 72;
  static const double iconButton = 44;
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 560);
}

abstract final class AppDurationsTime {
  static const int defaultDebounceMillis = 400;
}

abstract final class AppStrings {
  static const String appName = 'NGOVolunteer';
  static const String tagline = 'Volunteer for impact';
}

abstract final class AppCategories {
  static const List<String> all = [
    'Teaching',
    'Health',
    'Environment',
    'Community',
    'Animal Welfare',
    'Disaster Relief',
  ];
}

abstract final class AppSkills {
  static const List<String> all = [
    'Teaching',
    'First Aid',
    'Event Support',
    'Fundraising',
    'Content Writing',
    'Design',
    'Data Entry',
    'Public Speaking',
    'Cooking',
    'Driving',
    'Photography',
    'Translation',
  ];
}

abstract final class AppSortOptions {
  static const String recent = 'Most recent';
  static const String popular = 'Most popular';
  static const String upcoming = 'Upcoming';
  static const List<String> all = [recent, popular, upcoming];
}

abstract final class ScreenPadding {
  static const EdgeInsets horizontal = EdgeInsets.symmetric(horizontal: AppSpacing.md);
  static const EdgeInsets all = EdgeInsets.all(AppSpacing.md);
  static const EdgeInsets none = EdgeInsets.zero;
}

extension AppXEdgeInsets on EdgeInsets {
  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.md,
  );
}

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];
  static const List<BoxShadow> none = [];
}