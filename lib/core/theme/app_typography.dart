import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Display (hero numbers, logo)
  static const TextStyle displayXL = TextStyle(
    fontFamily: 'Inter',
    fontSize: 72,
    fontWeight: FontWeight.w900,
    letterSpacing: -3,
    color: AppColors.textPrimary,
  );

  // Headlines
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body
  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // Status / System labels
  static const TextStyle mono = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: AppColors.textMuted,
  );

  static const TextStyle monoLarge = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
    color: AppColors.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.textMuted,
  );
}
