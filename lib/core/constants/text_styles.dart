import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // h1 — 24px / Bold
  static const TextStyle displayLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 32 / 24,
  );

  // h2 — 20px / SemiBold
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 28 / 20,
  );

  // h2 alias for widgets using titleLarge
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // body-lg — 16px / Regular
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 24 / 16,
  );

  // body-sm — 14px / Regular
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 20 / 14,
  );

  // label-caps — 12px / SemiBold + letter spacing
  static const TextStyle labelCaps = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
    height: 16 / 12,
    letterSpacing: 0.05 * 12,
  );

  // data-tabular — 14px / Medium (untuk tabel nilai)
  static const TextStyle dataTabular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
    height: 20 / 14,
  );

  // labelLarge — dipakai di button
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
    letterSpacing: 0.4,
  );
}