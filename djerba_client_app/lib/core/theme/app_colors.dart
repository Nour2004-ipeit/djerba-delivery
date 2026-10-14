import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color djerbaBlue = Color(0xFF0A2540);
  static const Color djerbaBlueLight = Color(0xFFE6EDF8);
  static const Color djerbaGold = Color(0xFFE5A93B);
  static const Color djerbaGreen = Color(0xFF22C55E);
  
  // Neutral Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);

  // Gradients
  static const Color primaryGradientStart = Color(0xFF0A2540);
  static const Color primaryGradientEnd = Color(0xFF1E3A8A);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
