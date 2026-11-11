import 'package:flutter/material.dart';

import '../theme/app_gradients.dart';

abstract final class CategoryMeta {
  static Gradient gradientFor(String? category) {
    switch (category?.toLowerCase()) {
      case 'teaching':
      case 'education':
        return AppGradients.info;
      case 'health':
        return AppGradients.warning;
      case 'environment':
      case 'sustainability':
        return AppGradients.success;
      case 'community':
        return AppGradients.sunrise;
      case 'animal welfare':
        return AppGradients.primary;
      case 'disaster relief':
        return AppGradients.danger;
      default:
        return AppGradients.primaryCompact;
    }
  }

  static IconData iconFor(String? category) {
    switch (category?.toLowerCase()) {
      case 'teaching':
      case 'education':
        return Icons.school_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'environment':
      case 'sustainability':
        return Icons.park_rounded;
      case 'community':
        return Icons.groups_rounded;
      case 'animal welfare':
        return Icons.pets_rounded;
      case 'disaster relief':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.public_rounded;
    }
  }
}