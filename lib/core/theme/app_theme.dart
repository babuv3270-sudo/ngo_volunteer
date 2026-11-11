import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    final TextTheme poppins = GoogleFonts.poppinsTextTheme();
    final TextTheme manrope = GoogleFonts.manropeTextTheme();

    final TextTheme textTheme = TextTheme(
      displayLarge: poppins.displayLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      displayMedium: poppins.displayMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      displaySmall: poppins.displaySmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      headlineLarge: poppins.headlineLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      headlineMedium: poppins.headlineMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      headlineSmall: poppins.headlineSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleLarge: poppins.titleLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleMedium: poppins.titleMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleSmall: poppins.titleSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: manrope.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w400),
      bodyMedium: manrope.bodyMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w400),
      bodySmall: manrope.bodySmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w400),
      labelLarge: manrope.labelLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      labelMedium: manrope.labelMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
      labelSmall: manrope.labelSmall?.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w500),
    );

    final InputDecorationTheme inputDecoration = InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceMuted,
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.error),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      prefixIconColor: AppColors.textMuted,
      suffixIconColor: AppColors.textMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.6),
      ),
    );

    final ElevatedButtonThemeData elevatedButton = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );

    final OutlinedButtonThemeData outlinedButton = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        elevation: 0,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );

    final TextButtonThemeData textButton = TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    final ChipThemeData chipTheme = ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withValues(alpha: 0.14),
      labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: AppColors.primary),
      side: const BorderSide(color: AppColors.divider),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: AppColors.divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );

    final NavigationBarThemeData navigationBar = NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.14),
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textMuted,
          size: 24,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => textTheme.labelSmall?.copyWith(
          color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textMuted,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );

    final AppBarTheme appBarTheme = AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      foregroundColor: AppColors.textPrimary,
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
    );

    final CardThemeData cardTheme = CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: AppColors.shadow,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );

    final BottomSheetThemeData bottomSheet = const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      showDragHandle: true,
      dragHandleColor: AppColors.divider,
    );

    final DialogThemeData dialogTheme = DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 20,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
    );

    final SnackBarThemeData snackBarTheme = SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textOnPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      inputDecorationTheme: inputDecoration,
      elevatedButtonTheme: elevatedButton,
      outlinedButtonTheme: outlinedButton,
      textButtonTheme: textButton,
      chipTheme: chipTheme,
      navigationBarTheme: navigationBar,
      appBarTheme: appBarTheme,
      cardTheme: cardTheme,
      bottomSheetTheme: bottomSheet,
      dialogTheme: dialogTheme,
      snackBarTheme: snackBarTheme,
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceMuted,
        circularTrackColor: AppColors.surfaceMuted,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x3310B981),
        selectionHandleColor: AppColors.primary,
      ),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.primary : null,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: const BorderSide(color: AppColors.textMuted),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : AppColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.primary : AppColors.surfaceMuted,
        ),
        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
      ),
    );
  }
}