import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF5C8299);
  static const secondary = Color(0xFF8B97A2);

  static const background = Color(0xFFF6F7F9);
  static const surface = Colors.white;

  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF059669);
  static const warning = Color(0xFFFFA000);

  static const textPrimary = Color(0xFF364E60);
  static const textSecondary = Color(0xFF6B7280);
  static const textDisabled = Color(0xFFB0B7BE);
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  static const button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const tabLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}