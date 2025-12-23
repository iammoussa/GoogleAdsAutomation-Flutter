import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const Color lightPrimary = Color(0xFF2196F3);
  static const Color lightPrimaryDark = Color(0xFF1976D2);
  static const Color lightPrimaryLight = Color(0xFFBBDEFB);
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);

  // Dark Mode Colors (from screenshot)
  static const Color darkPrimary = Color(0xFF2196F3);
  static const Color darkPrimaryDark = Color(0xFF1565C0);
  static const Color darkPrimaryLight = Color(0xFF64B5F6);
  static const Color darkBackground = Color(0xFF0A1929); // Navy blue dark background
  static const Color darkSurface = Color(0xFF1E2A3A); // Card background
  static const Color darkSurfaceVariant = Color(0xFF2C3E50); // Alternative card bg
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0BEC5);

  // Status colors (same for both themes)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Campaign status colors
  static const Color campaignEnabled = Color(0xFF4CAF50);
  static const Color campaignPaused = Color(0xFFFFA726);
  static const Color campaignDisabled = Color(0xFF9E9E9E);

  // Priority colors
  static const Color priorityHigh = Color(0xFFF44336);
  static const Color priorityMedium = Color(0xFFFFA726);
  static const Color priorityLow = Color(0xFF4CAF50);

  // Divider and border
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightBorder = Color(0xFFBDBDBD);
  static const Color darkDivider = Color(0xFF37474F);
  static const Color darkBorder = Color(0xFF455A64);

  AppColors._();
}