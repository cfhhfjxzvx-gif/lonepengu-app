import 'package:flutter/material.dart';

/// LonePengu brand color palette
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color arcticBlue = Color(0xFF1E3A5F);
  static const Color penguinBlack = Color(0xFF1A1A2E);
  static const Color iceWhite = Color(0xFFF8FAFC);

  // Accent Colors
  static const Color auroraTeal = Color(0xFF14B8A6);
  static const Color frostPurple = Color(0xFF8B5CF6);
  static const Color sunsetCoral = Color(0xFFF43F5E);

  // Utility Colors
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [arcticBlue, penguinBlack],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [auroraTeal, frostPurple],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D4A6F), Color(0xFF252545)],
  );
}
