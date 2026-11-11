import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_gradients.dart';

class AvatarPill extends StatelessWidget {
  const AvatarPill({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppSizes.avatarM,
    this.showRing = true,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    final String initials = name != null && name!.trim().isNotEmpty
        ? name!
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
            .join()
        : '?';

    Widget child = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppGradients.primaryCompact,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: (imageUrl != null && imageUrl!.isNotEmpty)
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                width: size,
                height: size,
                placeholder: (_, _) => _letters(initials, size * 0.35),
                errorWidget: (_, _, _) => _letters(initials, size * 0.35),
              ),
            )
          : _letters(initials, size * 0.35),
    );

    if (showRing) {
      child = Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          shape: BoxShape.circle,
        ),
        child: child,
      );
    }
    return child;
  }

  Widget _letters(String initials, double fontSize) {
    return Text(
      initials,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}