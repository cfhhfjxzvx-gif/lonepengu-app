/// LonePengu Radius - Tailwind-like Border Radius System
///
/// Usage: LPRadius.md, BorderRadius.circular(LPRadius.lg)

import 'package:flutter/material.dart';

class LPRadius {
  LPRadius._();

  // ═══════════════════════════════════════════
  // RADIUS VALUES
  // ═══════════════════════════════════════════

  /// 0px - none (sharp corners)
  static const double none = 0;

  /// 4px - xs (subtle rounding)
  static const double xs = 4.0;

  /// 8px - sm (rounded-sm)
  static const double sm = 8.0;

  /// 12px - md (rounded-md) - DEFAULT
  static const double md = 12.0;

  /// 16px - lg (rounded-lg)
  static const double lg = 16.0;

  /// 20px - xl (rounded-xl)
  static const double xl = 20.0;

  /// 24px - xxl (rounded-2xl)
  static const double xxl = 24.0;

  /// 32px - xxxl (rounded-3xl)
  static const double xxxl = 32.0;

  /// 9999px - full (pill shape)
  static const double full = 9999.0;

  // ═══════════════════════════════════════════
  // BORDER RADIUS OBJECTS
  // ═══════════════════════════════════════════

  /// No rounding
  static const BorderRadius noneBorder = BorderRadius.zero;

  /// 4px all corners
  static const BorderRadius xsBorder = BorderRadius.all(Radius.circular(xs));

  /// 8px all corners
  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));

  /// 12px all corners - DEFAULT
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));

  /// 16px all corners
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));

  /// 20px all corners
  static const BorderRadius xlBorder = BorderRadius.all(Radius.circular(xl));

  /// 24px all corners
  static const BorderRadius xxlBorder = BorderRadius.all(Radius.circular(xxl));

  /// Pill shape
  static const BorderRadius fullBorder = BorderRadius.all(
    Radius.circular(full),
  );

  // ═══════════════════════════════════════════
  // SEMANTIC SHORTCUTS
  // ═══════════════════════════════════════════

  /// Card default radius
  static const BorderRadius card = mdBorder;

  /// Button default radius
  static const BorderRadius button = smBorder;

  /// Input/TextField radius
  static const BorderRadius input = smBorder;

  /// Chip/Tag radius (pill)
  static const BorderRadius chip = fullBorder;

  /// Avatar radius (circular)
  static const BorderRadius avatar = fullBorder;

  /// Modal/Sheet top corners
  static const BorderRadius sheet = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  /// Dialog radius
  static const BorderRadius dialog = lgBorder;

  /// Image thumbnail radius
  static const BorderRadius thumbnail = smBorder;

  // ═══════════════════════════════════════════
  // TOP ONLY RADIUS
  // ═══════════════════════════════════════════

  static BorderRadius topOnly(double radius) => BorderRadius.only(
    topLeft: Radius.circular(radius),
    topRight: Radius.circular(radius),
  );

  static const BorderRadius topSm = BorderRadius.only(
    topLeft: Radius.circular(sm),
    topRight: Radius.circular(sm),
  );

  static const BorderRadius topMd = BorderRadius.only(
    topLeft: Radius.circular(md),
    topRight: Radius.circular(md),
  );

  static const BorderRadius topLg = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );

  static const BorderRadius topXl = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  // ═══════════════════════════════════════════
  // BOTTOM ONLY RADIUS
  // ═══════════════════════════════════════════

  static BorderRadius bottomOnly(double radius) => BorderRadius.only(
    bottomLeft: Radius.circular(radius),
    bottomRight: Radius.circular(radius),
  );

  static const BorderRadius bottomSm = BorderRadius.only(
    bottomLeft: Radius.circular(sm),
    bottomRight: Radius.circular(sm),
  );

  static const BorderRadius bottomMd = BorderRadius.only(
    bottomLeft: Radius.circular(md),
    bottomRight: Radius.circular(md),
  );

  // ═══════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════

  /// Create BorderRadius from value
  static BorderRadius circular(double radius) => BorderRadius.circular(radius);

  /// Create custom BorderRadius
  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) => BorderRadius.only(
    topLeft: Radius.circular(topLeft),
    topRight: Radius.circular(topRight),
    bottomLeft: Radius.circular(bottomLeft),
    bottomRight: Radius.circular(bottomRight),
  );
}
