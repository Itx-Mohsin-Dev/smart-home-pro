import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF0EA5E9);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentAmber = Color(0xFFF59E0B);

  // Neutral Colors
  static const Color bgLightBlue = Color(0xFFF0F9FF);
  static const Color bgLightBlue2 = Color(0xFFE0F2FE);
  static const Color darkGray = Color(0xFF1E293B);
  static const Color mediumGray = Color(0xFF64748B);
  static const Color lightGray = Color(0xFFF8FAFC);
  static const Color borderGray = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFEF4444);  // Red color
  // Gradients
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primaryBlue, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient bgGradient = const LinearGradient(
    colors: [bgLightBlue, bgLightBlue2],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}