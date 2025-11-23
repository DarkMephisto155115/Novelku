import 'package:flutter/material.dart';

class AppThemeData {
  // Primary Colors - Purple
  static const Color primaryColor = Color(0xFF9333EA);
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF9333EA,
    <int, Color>{
      50: Color(0xFFFAF5FF),
      100: Color(0xFFF3E8FF),
      200: Color(0xFFE9D5FF),
      300: Color(0xFFD8B4FE),
      400: Color(0xFFC084FC),
      500: Color(0xFFA855F7),
      600: Color(0xFF9333EA),
      700: Color(0xFF7C3AED),
      800: Color(0xFF6B21A8),
      900: Color(0xFF581C87),
    },
  );

  // Accent Colors
  static const Color pinkColor = Color(0xFFEC4899); // Untuk gradasi profile
  static const Color premiumColor = Color(0xFFFBBF24); // Yellow-400
  static const Color successColor = Color(0xFF10B981); // Green-600
  static const Color errorColor = Color(0xFFEF4444); // Red-600

  // Light Theme Colors (dari Figma Anda)
  static const Color lightTextPrimary = Color(0xFF0A0A0A);
  static const Color lightBadgeColor = Color(0xFFECEEF2);
  static const Color lightTextSecondary = Color(0xFF717182);
  static const Color lightScaffoldBackground = Color(0xFFF9FAFB); // bg-1
  static const Color lightCardBackground = Color(0xFFFFFFFF); // bg-card
  static const Color lightInputBackground = Color(0xFFF3F3F5); // bg-2
  
  // Border colors untuk light mode
  static const Color lightInputBorder = Color(0xFFE5E7EB);
  static const Color lightAppBarBackground = Color(0xFFFFFFFF);

  // Dark Theme Colors (versi dark mode)
  static const Color darkTextPrimary = Color(0xFFF9FAFB); // Text utama dark mode
  static const Color darkBadgeColor = Color(0xFF374151); // Badge dark mode
  static const Color darkTextSecondary = Color(0xFFD1D5DB); // Text secondary dark mode
  static const Color darkScaffoldBackground = Color(0xFF111827); // Background utama dark mode
  static const Color darkCardBackground = Color(0xFF1F2937); // Card background dark mode
  static const Color darkInputBackground = Color(0xFF374151); // Input background dark mode
  
  // Border colors untuk dark mode
  static const Color darkInputBorder = Color(0xFF4B5563);
  static const Color darkAppBarBackground = Color(0xFF1F2937);

  // Additional dark mode colors untuk konsistensi
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkHintText = Color(0xFF9CA3AF);
}