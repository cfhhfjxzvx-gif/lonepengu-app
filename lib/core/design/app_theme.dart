/// LonePengu App Theme - ThemeData configuration
///
/// Uses design tokens for all theme values
/// Usage: import in main.dart, use AppTheme.light

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'radius.dart';
import 'text_styles.dart';

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════

  static ThemeData get light => _createTheme(Brightness.light);

  // ═══════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════

  static ThemeData get dark => _createTheme(Brightness.dark);

  static ThemeData _createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // Premium color assignments based on mode
    final primaryColor = LPColors.primary;

    final backgroundColor = isDark
        ? LPColors.backgroundDark
        : LPColors.background;
    final surfaceColor = isDark ? LPColors.surfaceDark : LPColors.surface;
    final cardColor = isDark ? LPColors.cardDark : LPColors.surface;
    final textPrimary = isDark
        ? LPColors.textPrimaryDark
        : LPColors.textPrimary;
    final textSecondary = isDark
        ? LPColors.textSecondaryDark
        : LPColors.textSecondary;
    final dividerColor = isDark ? LPColors.dividerDark : LPColors.divider;
    final borderColor = isDark ? LPColors.borderDark : LPColors.border;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // Colors
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,

      // Color scheme
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: LPColors.secondary,
        onSecondary: Colors.white,
        tertiary: LPColors.accent,
        onTertiary: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimary,
        surfaceContainerLow: isDark
            ? LPColors.backgroundDark
            : LPColors.surface,
        surfaceContainer: isDark ? LPColors.cardDark : Colors.white,
        surfaceContainerHigh: isDark
            ? LPColors.cardElevatedDark
            : LPColors.iceWhite,
        outline: borderColor,
        outlineVariant: isDark
            ? LPColors.borderLightDark
            : LPColors.borderLight,
        error: LPColors.error,
        onError: Colors.white,
      ),

      // Typography
      textTheme: LPText.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
        decorationColor: textPrimary,
      ),

      // AppBar - matches background for seamless look
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        centerTitle: true,
        titleTextStyle: LPText.hMD.copyWith(color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),

      // Cards - visible in all modes with proper elevation
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: LPRadius.card,
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: LPRadius.button),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: LPText.button,
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? LPColors.secondary : primaryColor,
          side: BorderSide(
            color: isDark ? LPColors.secondary : primaryColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: LPRadius.button),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: LPText.button,
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? LPColors.secondary : primaryColor,
          shape: RoundedRectangleBorder(borderRadius: LPRadius.button),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: LPText.button,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? LPColors.surfaceDark : Colors.white,
        border: OutlineInputBorder(
          borderRadius: LPRadius.input,
          borderSide: BorderSide(
            color: isDark ? LPColors.borderDark : dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: LPRadius.input,
          borderSide: BorderSide(
            color: isDark ? LPColors.borderDark : dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: LPRadius.input,
          borderSide: BorderSide(color: LPColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: LPRadius.input,
          borderSide: BorderSide(color: LPColors.coral),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: LPRadius.input,
          borderSide: BorderSide(color: LPColors.coral, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: LPText.bodySM.copyWith(color: textSecondary),
        labelStyle: LPText.labelMD.copyWith(color: textSecondary),
        errorStyle: LPText.caption.copyWith(color: LPColors.coral),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return LPColors.secondary;
          }
          return isDark ? LPColors.surfaceDark : LPColors.grey300;
        }),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark ? LPColors.secondary : LPColors.primary;
          }
          return LPColors.grey400;
        }),
      ),

      // List tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: LPRadius.smBorder),
        tileColor: Colors.transparent,
        selectedTileColor: primaryColor.withValues(alpha: 0.08),
      ),

      // Icon
      iconTheme: IconThemeData(color: textSecondary, size: 24),

      // Bottom Sheets
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: LPColors.dark,
          borderRadius: LPRadius.xsBorder,
        ),
        textStyle: LPText.caption.copyWith(color: Colors.white),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // SYSTEM UI OVERLAY
  // ═══════════════════════════════════════════

  static const SystemUiOverlayStyle lightOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: LPColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle darkOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: LPColors.dark,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
