/// LonePengu Spacing - Tailwind-like Spacing System
///
/// 8px grid system
/// Usage: LPSpacing.md, EdgeInsets.all(LPSpacing.lg)

import 'package:flutter/material.dart';

class LPSpacing {
  LPSpacing._();

  // ═══════════════════════════════════════════
  // BASE UNIT (8px grid)
  // ═══════════════════════════════════════════

  static const double unit = 8.0;

  // ═══════════════════════════════════════════
  // SPACING SCALE (like p-1, p-2, p-4, etc.)
  // ═══════════════════════════════════════════

  /// 0px - none
  static const double none = 0;

  /// 2px - hairline
  static const double hair = 2.0;

  /// 4px - xxs (0.5x)
  static const double xxs = 4.0;

  /// 8px - xs (1x)
  static const double xs = 8.0;

  /// 12px - sm (1.5x)
  static const double sm = 12.0;

  /// 16px - md (2x) - DEFAULT
  static const double md = 16.0;

  /// 20px - between md and lg
  static const double mdLg = 20.0;

  /// 24px - lg (3x)
  static const double lg = 24.0;

  /// 32px - xl (4x)
  static const double xl = 32.0;

  /// 40px - between xl and xxl
  static const double xlXxl = 40.0;

  /// 48px - xxl (6x)
  static const double xxl = 48.0;

  /// 64px - xxxl (8x)
  static const double xxxl = 64.0;

  // ═══════════════════════════════════════════
  // PAGE PADDING (screen-level)
  // ═══════════════════════════════════════════

  /// Standard page padding
  static const EdgeInsets page = EdgeInsets.all(md);

  /// Horizontal only
  static const EdgeInsets pageH = EdgeInsets.symmetric(horizontal: md);

  /// Vertical only
  static const EdgeInsets pageV = EdgeInsets.symmetric(vertical: md);

  /// Compact page padding
  static const EdgeInsets pageCompact = EdgeInsets.all(sm);

  /// Large page padding
  static const EdgeInsets pageLarge = EdgeInsets.all(lg);

  // ═══════════════════════════════════════════
  // CARD PADDING
  // ═══════════════════════════════════════════

  /// Standard card padding
  static const EdgeInsets card = EdgeInsets.all(md);

  /// Compact card padding
  static const EdgeInsets cardCompact = EdgeInsets.all(sm);

  /// Large card padding
  static const EdgeInsets cardLarge = EdgeInsets.all(lg);

  /// Card with different H/V
  static const EdgeInsets cardWide = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  // ═══════════════════════════════════════════
  // BUTTON PADDING
  // ═══════════════════════════════════════════

  /// Standard button padding
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );

  /// Compact button padding
  static const EdgeInsets buttonCompact = EdgeInsets.symmetric(
    horizontal: md,
    vertical: xs,
  );

  /// Large button padding
  static const EdgeInsets buttonLarge = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );

  // ═══════════════════════════════════════════
  // INPUT PADDING
  // ═══════════════════════════════════════════

  /// Standard input content padding
  static const EdgeInsets input = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Large input padding
  static const EdgeInsets inputLarge = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );

  // ═══════════════════════════════════════════
  // LIST ITEM PADDING
  // ═══════════════════════════════════════════

  /// Standard list item padding
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Compact list item
  static const EdgeInsets listItemCompact = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );

  // ═══════════════════════════════════════════
  // SECTION SPACING (vertical gaps between sections)
  // ═══════════════════════════════════════════

  static const double sectionSm = md;
  static const double sectionMd = lg;
  static const double sectionLg = xl;
  static const double sectionXl = xxl;

  // ═══════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════

  /// Create EdgeInsets.all from multiplier
  static EdgeInsets all(double multiplier) => EdgeInsets.all(unit * multiplier);

  /// Create symmetric EdgeInsets
  static EdgeInsets symmetric({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: unit * h, vertical: unit * v);

  /// Create EdgeInsets from LTRB multipliers
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

  /// Create horizontal padding
  static EdgeInsets h(double value) => EdgeInsets.symmetric(horizontal: value);

  /// Create vertical padding
  static EdgeInsets v(double value) => EdgeInsets.symmetric(vertical: value);
}

// ═══════════════════════════════════════════
// GAP WIDGETS (SizedBox shortcuts)
// ═══════════════════════════════════════════

/// Gap utility widgets - Tailwind-like spacing shortcuts
/// Usage: Gap.md, Gap.lg, Gap.vertical(24)
class Gap extends StatelessWidget {
  final double width;
  final double height;

  const Gap({super.key, this.width = 0, this.height = 0});

  /// No gap
  static const Gap none = Gap(width: 0, height: 0);

  /// 2px gap
  static const Gap hair = Gap(width: 2, height: 2);

  /// 4px gap
  static const Gap xxs = Gap(width: 4, height: 4);

  /// 8px gap
  static const Gap xs = Gap(width: 8, height: 8);

  /// 12px gap
  static const Gap sm = Gap(width: 12, height: 12);

  /// 16px gap - DEFAULT
  static const Gap md = Gap(width: 16, height: 16);

  /// 24px gap
  static const Gap lg = Gap(width: 24, height: 24);

  /// 32px gap
  static const Gap xl = Gap(width: 32, height: 32);

  /// 48px gap
  static const Gap xxl = Gap(width: 48, height: 48);

  /// 64px gap
  static const Gap xxxl = Gap(width: 64, height: 64);

  /// Create horizontal gap
  static Widget horizontal(double width) => SizedBox(width: width);

  /// Create vertical gap
  static Widget vertical(double height) => SizedBox(height: height);

  /// Create horizontal gap from spacing constant
  static Widget h(double value) => SizedBox(width: value);

  /// Create vertical gap from spacing constant
  static Widget v(double value) => SizedBox(height: value);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}
