import 'package:flutter/material.dart';

/// LonePengu Colors - Premium SaaS Color System
///
/// Theme: Ice white, soft blue, light gradients
/// Dark mode: Charcoal/slate with visible elevated surfaces
///
/// Usage: LPColors.primary, LPColors.surface
class LPColors {
  LPColors._();

  // ═══════════════════════════════════════════
  // BRAND COLORS - Soft Blue Arctic Theme
  // ═══════════════════════════════════════════

  /// Primary: Soft Navy Blue (main brand color)
  static const Color primary = Color(0xFF3B5998);
  static const Color primaryLight = Color(0xFF5A7FBF);
  static const Color primaryDark = Color(0xFF2D4373);

  /// Secondary: Teal/Cyan accent (actions, success)
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color secondaryDark = Color(0xFF0891B2);

  /// Accent: Soft purple for highlights
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentLight = Color(0xFFA78BFA);
  static const Color accentDark = Color(0xFF7C3AED);

  /// Coral: Warning/destructive actions
  static const Color coral = Color(0xFFF43F5E);
  static const Color coralLight = Color(0xFFFB7185);
  static const Color coralDark = Color(0xFFE11D48);

  // ═══════════════════════════════════════════
  // LIGHT PALETTE - Ice White & Soft Gradients
  // ═══════════════════════════════════════════

  /// Pure white background, clean and crisp
  static const Color background = Color(0xFFFAFBFC);

  /// Slightly off-white for surfaces
  static const Color surface = Color(0xFFFFFFFF);

  /// Ice white variant for cards
  static const Color iceWhite = Color(0xFFF8FAFF);

  /// Soft blue tint for subtle sections
  static const Color softBlue = Color(0xFFF0F7FF);

  /// Text hierarchy - clear contrast
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF7FAFC);

  /// Borders and dividers - subtle lines
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // ═══════════════════════════════════════════
  // DARK PALETTE - Charcoal/Slate (NOT Pure Black)
  // Premium SaaS look with visible elevated surfaces
  // ═══════════════════════════════════════════

  /// Background: Dark charcoal (not pure black)
  static const Color backgroundDark = Color(0xFF1A1D29);

  /// Surface: Slightly lighter than background
  static const Color surfaceDark = Color(0xFF22262F);

  /// Card: Elevated surface - CLEARLY VISIBLE
  static const Color cardDark = Color(0xFF2A2F3C);

  /// Card elevated: For nested/hover cards
  static const Color cardElevatedDark = Color(0xFF343A4A);

  /// Text hierarchy for dark mode - high contrast
  static const Color textPrimaryDark = Color(0xFFF7FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E0);
  static const Color textTertiaryDark = Color(0xFF9AA5B4);

  /// Borders for dark mode - visible but subtle
  static const Color dividerDark = Color(0xFF3D4454);
  static const Color borderDark = Color(0xFF4A5568);
  static const Color borderLightDark = Color(0xFF2D3748);

  // ═══════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════

  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF16A34A);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // ═══════════════════════════════════════════
  // SOCIAL PLATFORM COLORS
  // ═══════════════════════════════════════════

  static const Color instagram = Color(0xFFE4405F);
  static const Color facebook = Color(0xFF1877F2);
  static const Color linkedin = Color(0xFF0A66C2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color tiktok = Color(0xFF010101);
  static const Color youtube = Color(0xFFFF0000);

  // ═══════════════════════════════════════════
  // GREY SCALE
  // ═══════════════════════════════════════════

  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  static const Color dark = Color(0xFF1A1A2E);
  static const Color darkAlt = Color(0xFF2D2D44);
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  static const Color scrim = Color(0x33000000);

  // ═══════════════════════════════════════════
  // GRADIENTS - Premium Soft Gradients
  // ═══════════════════════════════════════════

  /// Primary brand gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF5B79C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient for highlights
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Light mode: Soft ice white gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFAFBFC), Color(0xFFF5F7FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Dark mode: Charcoal gradient
  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF1A1D29), Color(0xFF141720)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Premium soft blue gradient for hero sections
  static const LinearGradient softBlueGradient = LinearGradient(
    colors: [Color(0xFFF0F7FF), Color(0xFFE8F4FD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Card highlight gradient
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════

  static Color getBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? Colors.white
      : backgroundDark;

  static Gradient getBackgroundGradient(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? backgroundGradient
      : backgroundGradientDark;

  static Color getSurfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? surface : surfaceDark;

  static Color getCardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? surface : cardDark;

  static Color getTextPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? textPrimary
      : textPrimaryDark;

  static Color getTextSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? textSecondary
      : textSecondaryDark;

  static Color getDividerColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? divider : dividerDark;

  static Color getBorderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? border : borderDark;

  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
