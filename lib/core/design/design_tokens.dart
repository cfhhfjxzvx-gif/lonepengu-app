/// Design Tokens - BRD Section 10: Design Guidelines
///
/// Centralized design tokens following:
/// - Inter font only
/// - 8px grid system
/// - Consistent radius (8-12px)
/// - Clean, minimal UI

import 'package:flutter/material.dart';

/// Application color palette
/// Inspired by LonePengu branding - Arctic/Antarctic theme
class AppDesignColors {
  // Primary palette
  static const Color primary = Color(0xFF2196F3); // Arctic Blue
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF26A69A); // Aurora Teal
  static const Color secondaryLight = Color(0xFF4DB6AC);
  static const Color secondaryDark = Color(0xFF00897B);

  // Accent colors
  static const Color accent = Color(0xFF7C4DFF); // Frost Purple
  static const Color accentLight = Color(0xFFB388FF);
  static const Color accentDark = Color(0xFF651FFF);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Grey scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Border colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderFocus = Color(0xFF2196F3);

  // Overlay colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // ═══════════════════════════════════════════
  // DARK MODE COLORS - Charcoal/Slate theme
  // ═══════════════════════════════════════════

  /// Dark mode background
  static const Color backgroundDark = Color(0xFF1A1D29);

  /// Dark mode surface
  static const Color surfaceDark = Color(0xFF22262F);

  /// Dark mode card (elevated)
  static const Color cardDark = Color(0xFF2A2F3C);

  /// Dark mode elevated card
  static const Color cardElevatedDark = Color(0xFF343A4A);

  /// Dark mode text
  static const Color textPrimaryDark = Color(0xFFF7FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E0);
  static const Color textTertiaryDark = Color(0xFF9AA5B4);

  /// Dark mode borders
  static const Color borderDark = Color(0xFF4A5568);
  static const Color borderLightDark = Color(0xFF2D3748);
  static const Color dividerDark = Color(0xFF3D4454);

  // Platform colors
  static const Color instagram = Color(0xFFE4405F);
  static const Color facebook = Color(0xFF1877F2);
  static const Color linkedin = Color(0xFF0A66C2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color tiktok = Color(0xFF010101);
  static const Color youtube = Color(0xFFFF0000);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, surfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// 8px grid-based spacing system
class AppSpacing {
  /// Base unit (8px)
  static const double unit = 8.0;

  /// Spacing values based on 8px grid
  static const double none = 0;
  static const double xxs = 2.0; // 0.25x
  static const double xs = 4.0; // 0.5x
  static const double sm = 8.0; // 1x
  static const double md = 16.0; // 2x
  static const double lg = 24.0; // 3x
  static const double xl = 32.0; // 4x
  static const double xxl = 48.0; // 6x
  static const double xxxl = 64.0; // 8x

  /// Section spacing
  static const double sectionSm = 16.0;
  static const double sectionMd = 24.0;
  static const double sectionLg = 32.0;
  static const double sectionXl = 48.0;

  /// Page padding
  static const EdgeInsets pagePadding = EdgeInsets.all(16.0);
  static const EdgeInsets pagePaddingHorizontal = EdgeInsets.symmetric(
    horizontal: 16.0,
  );
  static const EdgeInsets pagePaddingVertical = EdgeInsets.symmetric(
    vertical: 16.0,
  );

  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(12.0);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20.0);

  /// Input padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  static const EdgeInsets inputPaddingCompact = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 8.0,
  );

  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 12.0,
  );
  static const EdgeInsets buttonPaddingCompact = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: 32.0,
    vertical: 16.0,
  );

  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );

  /// Insets helper
  static EdgeInsets all(double multiplier) => EdgeInsets.all(unit * multiplier);
  static EdgeInsets symmetric({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: unit * h, vertical: unit * v);
  static EdgeInsets only({
    double l = 0,
    double t = 0,
    double r = 0,
    double b = 0,
  }) => EdgeInsets.only(
    left: unit * l,
    top: unit * t,
    right: unit * r,
    bottom: unit * b,
  );
}

/// Border radius values (8-12px range)
class AppRadius {
  static const double none = 0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;

  // Common BorderRadius objects
  static const BorderRadius noneBorder = BorderRadius.zero;
  static const BorderRadius xsBorder = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlBorder = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlBorder = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius fullBorder = BorderRadius.all(
    Radius.circular(full),
  );

  // Card radius (default)
  static const BorderRadius cardBorder = mdBorder;

  // Button radius
  static const BorderRadius buttonBorder = smBorder;

  // Input radius
  static const BorderRadius inputBorder = smBorder;

  // Chip radius
  static const BorderRadius chipBorder = fullBorder;

  // Bottom sheet radius
  static const BorderRadius bottomSheetBorder = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
}

/// Shadow definitions
class AppShadows {
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  // Card shadow (default)
  static const List<BoxShadow> card = sm;

  // Elevated card shadow
  static const List<BoxShadow> cardElevated = md;

  // Button shadow
  static const List<BoxShadow> button = sm;

  // Floating element shadow
  static const List<BoxShadow> floating = lg;

  // Modal shadow
  static const List<BoxShadow> modal = xl;
}

/// Duration constants for animations
class AppDurations {
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);

  // Specific use cases
  static const Duration buttonPress = fast;
  static const Duration pageTransition = normal;
  static const Duration modalOpen = slow;
  static const Duration snackbar = Duration(seconds: 3);
}

/// Curve constants for animations
class AppCurves {
  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve emphasize = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
}

/// Size constraints
class AppSizes {
  // Icon sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;

  // Button heights
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 56.0;

  // Input heights
  static const double inputHeightSm = 36.0;
  static const double inputHeightMd = 48.0;
  static const double inputHeightLg = 56.0;

  // Card min heights
  static const double cardMinHeight = 80.0;

  // Max content width (for web)
  static const double maxContentWidth = 600.0;
  static const double maxFormWidth = 480.0;

  // Bottom sheet
  static const double bottomSheetMaxHeight = 0.9; // 90% of screen

  // Divider
  static const double dividerThickness = 1.0;

  // Border width
  static const double borderWidth = 1.0;
  static const double borderWidthThick = 2.0;
}
