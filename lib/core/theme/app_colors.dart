import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bgVoid = Color(0xFF070B11);
  static const Color bgCard = Color(0xFF0D1320);
  static const Color bgElevated = Color(0xFF111827);

  // Glass surface (use with BackdropFilter)
  static const Color glassSurface = Color(0x14FFFFFF); // 8% white
  static const Color glassBorder = Color(0x26FFFFFF); // 15% white
  static const Color glassRedBorder = Color(0x40FF3B3B); // red glass border

  // Semantic Colors
  static const Color crisisRed = Color(0xFFFF3B3B); // active crisis ONLY
  static const Color crisisRedDim = Color(0x22FF3B3B); // red bg fills
  static const Color statusTeal = Color(0xFF14B8A6); // live / active / online
  static const Color warningAmber = Color(0xFFF59E0B); // warnings / moderate
  static const Color intelViolet = Color(0xFF8B5CF6); // AI/Gemini features
  static const Color commandBlue = Color(0xFF3B82F6); // navigation / info
  static const Color safeGreen = Color(0xFF22C55E); // resolved / all clear
  static const Color alertOrange = Color(0xFFF97316); // IoT triggers

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF7A8FA8);
  static const Color textMuted = Color(0xFF3D5068);

  // Borders
  static const Color borderDefault = Color(0xFF1E2D45);
  static const Color borderLight = Color(0xFF1A2840);
}
