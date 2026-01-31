/// LonePengu Text Styles - Tailwind-like Typography System
///
/// Google Fonts Inter ONLY
/// Usage: LPText.hMD, LPText.bodyLG

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class LPText {
  LPText._();

  // ═══════════════════════════════════════════
  // FONT FAMILY
  // ═══════════════════════════════════════════

  /// Get Inter text style
  static TextStyle _inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    double letterSpacing = 0,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ═══════════════════════════════════════════
  // FONT WEIGHTS
  // ═══════════════════════════════════════════

  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // ═══════════════════════════════════════════
  // DISPLAY STYLES (Hero text, big headlines)
  // ═══════════════════════════════════════════

  /// 48px - Display XL
  static TextStyle get displayXL =>
      _inter(fontSize: 48, fontWeight: bold, height: 1.1, letterSpacing: -1.0);

  /// 40px - Display LG
  static TextStyle get displayLG => _inter(
    fontSize: 40,
    fontWeight: bold,
    height: 1.15,
    letterSpacing: -0.75,
  );

  /// 32px - Display MD
  static TextStyle get displayMD =>
      _inter(fontSize: 32, fontWeight: bold, height: 1.2, letterSpacing: -0.5);

  /// 28px - Display SM
  static TextStyle get displaySM => _inter(
    fontSize: 28,
    fontWeight: bold,
    height: 1.25,
    letterSpacing: -0.25,
  );

  // ═══════════════════════════════════════════
  // HEADING STYLES (Section headers, cards)
  // ═══════════════════════════════════════════

  /// 24px - Heading XL
  static TextStyle get hXL => _inter(
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: -0.2,
  );

  /// 20px - Heading LG
  static TextStyle get hLG =>
      _inter(fontSize: 20, fontWeight: semiBold, height: 1.35);

  /// 18px - Heading MD
  static TextStyle get hMD =>
      _inter(fontSize: 18, fontWeight: semiBold, height: 1.4);

  /// 16px - Heading SM
  static TextStyle get hSM =>
      _inter(fontSize: 16, fontWeight: semiBold, height: 1.45);

  /// 14px - Heading XS
  static TextStyle get hXS =>
      _inter(fontSize: 14, fontWeight: semiBold, height: 1.5);

  // ═══════════════════════════════════════════
  // BODY STYLES (Paragraphs, content)
  // ═══════════════════════════════════════════

  /// 18px - Body LG
  static TextStyle get bodyLG =>
      _inter(fontSize: 18, fontWeight: regular, height: 1.6);

  /// 16px - Body MD (default)
  static TextStyle get bodyMD =>
      _inter(fontSize: 16, fontWeight: regular, height: 1.5);

  /// 14px - Body SM
  static TextStyle get bodySM =>
      _inter(fontSize: 14, fontWeight: regular, height: 1.5);

  /// 12px - Body XS
  static TextStyle get bodyXS =>
      _inter(fontSize: 12, fontWeight: regular, height: 1.5);

  // ═══════════════════════════════════════════
  // LABEL STYLES (Buttons, inputs, tabs)
  // ═══════════════════════════════════════════

  /// 16px - Label LG
  static TextStyle get labelLG =>
      _inter(fontSize: 16, fontWeight: medium, height: 1.4, letterSpacing: 0.1);

  /// 14px - Label MD
  static TextStyle get labelMD =>
      _inter(fontSize: 14, fontWeight: medium, height: 1.4, letterSpacing: 0.1);

  /// 12px - Label SM
  static TextStyle get labelSM =>
      _inter(fontSize: 12, fontWeight: medium, height: 1.4, letterSpacing: 0.2);

  /// 10px - Label XS
  static TextStyle get labelXS =>
      _inter(fontSize: 10, fontWeight: medium, height: 1.4, letterSpacing: 0.3);

  // ═══════════════════════════════════════════
  // SPECIAL STYLES
  // ═══════════════════════════════════════════

  /// Caption - small helper text
  static TextStyle get caption =>
      _inter(fontSize: 12, fontWeight: regular, height: 1.4);

  /// Overline - uppercase labels
  static TextStyle get overline => _inter(
    fontSize: 10,
    fontWeight: semiBold,
    height: 1.6,
    letterSpacing: 1.5,
  );

  /// Button text
  static TextStyle get button => _inter(
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Button text large
  static TextStyle get buttonLG => _inter(
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Button text small
  static TextStyle get buttonSM => _inter(
    fontSize: 12,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Link text
  static TextStyle get link =>
      _inter(fontSize: 14, fontWeight: medium, height: 1.5);

  /// Error/Hint text
  static TextStyle get hint =>
      _inter(fontSize: 12, fontWeight: regular, height: 1.4);

  // ═══════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════

  /// Apply color to any style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply weight to any style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Make style secondary color
  static TextStyle secondary(TextStyle style) {
    return style.copyWith(color: LPColors.textSecondary);
  }

  /// Make style tertiary color
  static TextStyle tertiary(TextStyle style) {
    return style.copyWith(color: LPColors.textTertiary);
  }

  /// Make style error color
  static TextStyle error(TextStyle style) {
    return style.copyWith(color: LPColors.error);
  }

  /// Make style success color
  static TextStyle success(TextStyle style) {
    return style.copyWith(color: LPColors.success);
  }

  /// Make style primary color
  static TextStyle primary(TextStyle style) {
    return style.copyWith(color: LPColors.primary);
  }

  /// Make style white (for dark backgrounds)
  static TextStyle onDark(TextStyle style) {
    return style.copyWith(color: LPColors.textOnDark);
  }

  // ═══════════════════════════════════════════
  // STRICT SEMANTIC TEXT ROLES (MANDATORY USE)
  // Use ONLY these for UI text to ensure consistency
  // ═══════════════════════════════════════════

  /// Page Title - ONE style for all screen titles (20px, semibold)
  static TextStyle get pageTitle => hLG;

  /// Section Title - ONE style for all section headers (16px, semibold)
  static TextStyle get sectionTitle => hSM;

  /// Card Title - ONE style for card headers (16px, semibold)
  static TextStyle get cardTitle => hSM;

  /// Body - ONE style for body text (16px, regular)
  static TextStyle get body => bodyMD;

  /// Body Secondary - ONE style for secondary body text (14px, regular)
  static TextStyle get bodySecondary =>
      bodySM.copyWith(color: LPColors.textSecondary);

  /// Caption - ONE style for small helper text (12px)
  static TextStyle get captionText => caption;

  /// Button - ONE style for all button text (14px, semibold)
  static TextStyle get buttonText => button;

  /// Input Label - ONE style for form labels (14px, medium)
  static TextStyle get inputLabel => labelMD;

  /// Input Text - ONE style for input content (16px, regular)
  static TextStyle get inputText => bodyMD;

  /// Chip/Tag - ONE style for chips (12px, medium)
  static TextStyle get chipText => labelSM;

  /// Stat/Number - ONE style for metrics (24px, semibold)
  static TextStyle get statText => hXL;

  /// Nav Item - ONE style for navigation (14px, medium)
  static TextStyle get navText => labelMD;

  // ═══════════════════════════════════════════
  // TEXT THEME FOR ThemeData
  // ═══════════════════════════════════════════

  static TextTheme get textTheme => TextTheme(
    displayLarge: displayXL,
    displayMedium: displayLG,
    displaySmall: displayMD,
    headlineLarge: hXL,
    headlineMedium: hLG,
    headlineSmall: hMD,
    titleLarge: hLG,
    titleMedium: hMD,
    titleSmall: hSM,
    labelLarge: labelLG,
    labelMedium: labelMD,
    labelSmall: labelSM,
    bodyLarge: bodyLG,
    bodyMedium: bodyMD,
    bodySmall: bodySM,
  );
}
