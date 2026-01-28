/// LonePengu Shadows - Tailwind-like Shadow System
///
/// Premium, soft shadows - no dark harsh edges
/// Usage: LPShadows.md, boxShadow: LPShadows.card

import 'package:flutter/material.dart';

class LPShadows {
  LPShadows._();

  // ═══════════════════════════════════════════
  // SHADOW LEVELS
  // ═══════════════════════════════════════════

  /// No shadow
  static const List<BoxShadow> none = [];

  /// Extra small - subtle elevation
  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Small - light cards
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x03000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Medium - default cards - MOST USED
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// Large - floating elements
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x10000000), blurRadius: 16, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 3)),
  ];

  /// Extra large - modals, dialogs
  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  /// 2XL - high prominence elements
  static const List<BoxShadow> xxl = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 32, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 6)),
  ];

  // ═══════════════════════════════════════════
  // SEMANTIC SHADOWS
  // ═══════════════════════════════════════════

  /// Card shadow (default)
  static const List<BoxShadow> card = sm;

  /// Elevated card shadow
  static const List<BoxShadow> cardElevated = md;

  /// Button shadow (subtle)
  static const List<BoxShadow> button = xs;

  /// Button hover shadow
  static const List<BoxShadow> buttonHover = sm;

  /// Floating action button
  static const List<BoxShadow> fab = lg;

  /// Modal/Dialog shadow
  static const List<BoxShadow> modal = xl;

  /// Dropdown/Popover shadow
  static const List<BoxShadow> dropdown = md;

  /// Bottom sheet shadow
  static const List<BoxShadow> sheet = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, -8)),
  ];

  /// Navigation bar shadow
  static const List<BoxShadow> navbar = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// Sticky header shadow
  static const List<BoxShadow> sticky = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  /// Card shadow for dark mode - subtle elevation
  static const List<BoxShadow> cardDark = [
    BoxShadow(color: Color(0x40000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x20000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  // ═══════════════════════════════════════════
  // COLORED SHADOWS (for primary buttons, etc.)
  // ═══════════════════════════════════════════

  /// Primary color shadow
  static List<BoxShadow> primary({double opacity = 0.25}) => [
    BoxShadow(
      color: const Color(0xFF1E3A5F).withValues(alpha: opacity),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Secondary/Teal color shadow
  static List<BoxShadow> secondary({double opacity = 0.25}) => [
    BoxShadow(
      color: const Color(0xFF14B8A6).withValues(alpha: opacity),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Error/Coral color shadow
  static List<BoxShadow> error({double opacity = 0.25}) => [
    BoxShadow(
      color: const Color(0xFFF43F5E).withValues(alpha: opacity),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Success color shadow
  static List<BoxShadow> success({double opacity = 0.25}) => [
    BoxShadow(
      color: const Color(0xFF22C55E).withValues(alpha: opacity),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ═══════════════════════════════════════════
  // INNER SHADOWS (for inputs, etc.)
  // ═══════════════════════════════════════════

  /// Inner shadow for pressed states
  static const List<BoxShadow> inner = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: -1,
    ),
  ];

  // ═══════════════════════════════════════════
  // PREMIUM GLOW SHADOWS
  // ═══════════════════════════════════════════

  /// Soft ambient glow for primary elements
  static List<BoxShadow> glow(Color color, {bool isDark = false}) => [
    BoxShadow(
      color: color.withValues(alpha: isDark ? 0.2 : 0.15),
      blurRadius: isDark ? 32 : 24,
      offset: const Offset(0, 8),
      spreadRadius: isDark ? -2 : -4,
    ),
    BoxShadow(
      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      blurRadius: isDark ? 16 : 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Subtle depth shadow for cards (premium)
  static const List<BoxShadow> premium = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 20,
      offset: Offset(0, 10),
      spreadRadius: -5,
    ),
    BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  /// Deep depth shadow for dark cards
  static const List<BoxShadow> premiumDark = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 24,
      offset: Offset(0, 12),
      spreadRadius: -8,
    ),
    BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  // ═══════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════

  /// Create custom shadow
  static List<BoxShadow> custom({
    Color color = const Color(0x0D000000),
    double blur = 8,
    double x = 0,
    double y = 4,
    double spread = 0,
  }) => [
    BoxShadow(
      color: color,
      blurRadius: blur,
      offset: Offset(x, y),
      spreadRadius: spread,
    ),
  ];

  /// Combine shadow lists
  static List<BoxShadow> combine(List<List<BoxShadow>> shadows) {
    return shadows.expand((s) => s).toList();
  }
}
