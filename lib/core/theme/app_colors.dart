import 'package:flutter/material.dart';

abstract class AppColors {
  // --- New Brand Main Palette ---
  // Light Mode
  static const primaryGreenLight = Color(0xFF22C55E);
  static const accentLimeLight = Color(0xFFA3E635);
  static const backgroundLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF3F4F6);
  static const borderLight = Color(0xFFE5E7EB);
  static const textPrimaryLight = Color(0xFF111827);
  static const textSecondaryLight = Color(0xFF6B7280);

  // Dark Mode
  static const primaryGreenDark = Color(0xFF4ADE80);
  static const accentLimeDark = Color(0xFFBEF264);
  static const backgroundDark = Color(0xFF0B0F14);
  static const surfaceDark = Color(0xFF111827);
  static const surfaceElevatedDark = Color(0xFF1F2937);
  static const borderDark = Color(0xFF374151);
  static const textPrimaryDark = Color(0xFFF9FAFB);
  static const textSecondaryDark = Color(0xFF9CA3AF);

  // --- Legacy Compatibility Aliases ---
  static const Color background = backgroundLight;
  static const Color cardBackground = surfaceLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color divider = borderLight;
  static const Color blue = primaryGreenLight; // Mapped to primary brand green
  static const Color green = primaryGreenLight;
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color black = textPrimaryLight;

  // --- Status & Feedback ---
  static const successLight = Color(0xFF22C55E);
  static const warningLight = Color(0xFFF59E0B);
  static const errorLight = Color(0xFFEF4444);
  static const infoLight = Color(0xFF3B82F6);

  static const successDark = Color(0xFF4ADE80);
  static const warningDark = Color(0xFFFBBF24);
  static const errorDark = Color(0xFFF87171);
  static const infoDark = Color(0xFF60A5FA);

  // --- Charts & Statistics ---
  static const chartGreenLight = Color(0xFF22C55E);
  static const chartGreenDark = Color(0xFF4ADE80);
  static const chartLimeLight = Color(0xFFA3E635);
  static const chartLimeDark = Color(0xFFBEF264);
  static const chartBlueLight = Color(0xFF3B82F6);
  static const chartBlueDark = Color(0xFF60A5FA);
  static const chartPurpleLight = Color(0xFF8B5CF6);
  static const chartPurpleDark = Color(0xFFA78BFA);
  static const chartPinkLight = Color(0xFFEC4899);
  static const chartPinkDark = Color(0xFFF472B6);
  static const chartOrangeLight = Color(0xFFF97316);
  static const chartOrangeDark = Color(0xFFFB923C);
}