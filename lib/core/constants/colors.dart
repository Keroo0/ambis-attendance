import 'package:flutter/material.dart';

/// AMBIS Color System — SMAN 07 Academic Design System
/// Source: DESIGN.md (light theme, Material 3 token names)
class AppColors {
  AppColors._();

  // ── Background ─────────────────────────────────────────────────────────
  static const Color background         = Color(0xFFF7F9FB);
  static const Color onBackground       = Color(0xFF191C1E);

  // ── Surface ────────────────────────────────────────────────────────────
  static const Color surface                  = Color(0xFFF7F9FB);
  static const Color surfaceDim               = Color(0xFFD8DADC);
  static const Color surfaceBright            = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest   = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow      = Color(0xFFF2F4F6);
  static const Color surfaceContainer         = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh     = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest  = Color(0xFFE0E3E5);
  static const Color surfaceVariant           = Color(0xFFE0E3E5);
  static const Color surfaceTint              = Color(0xFF405F91);

  // ── On Surface ─────────────────────────────────────────────────────────
  static const Color onSurface            = Color(0xFF191C1E);
  static const Color onSurfaceVariant     = Color(0xFF43474F);
  static const Color inverseSurface       = Color(0xFF2D3133);
  static const Color inverseOnSurface     = Color(0xFFEFF1F3);

  // ── Outline ────────────────────────────────────────────────────────────
  static const Color outline              = Color(0xFF747780);
  static const Color outlineVariant       = Color(0xFFC4C6D0);

  // ── Primary — Deep Navy ────────────────────────────────────────────────
  static const Color primary              = Color(0xFF001736);
  static const Color onPrimary            = Color(0xFFFFFFFF);
  static const Color primaryContainer     = Color(0xFF002B5B);
  static const Color onPrimaryContainer   = Color(0xFF7594CA);
  static const Color inversePrimary       = Color(0xFFA9C7FF);
  static const Color primaryFixed         = Color(0xFFD6E3FF);
  static const Color primaryFixedDim      = Color(0xFFA9C7FF);
  static const Color onPrimaryFixed       = Color(0xFF001B3D);
  static const Color onPrimaryFixedVariant = Color(0xFF264778);

  // ── Secondary — Teal ───────────────────────────────────────────────────
  static const Color secondary              = Color(0xFF006A63);
  static const Color onSecondary            = Color(0xFFFFFFFF);
  static const Color secondaryContainer     = Color(0xFF47FBEB);
  static const Color onSecondaryContainer   = Color(0xFF007169);
  static const Color secondaryFixed         = Color(0xFF47FBEB);
  static const Color secondaryFixedDim      = Color(0xFF00DECF);
  static const Color onSecondaryFixed       = Color(0xFF00201D);
  static const Color onSecondaryFixedVariant = Color(0xFF00504A);

  // ── Tertiary — Gold/Amber ──────────────────────────────────────────────
  static const Color tertiary               = Color(0xFF201600);
  static const Color onTertiary             = Color(0xFFFFFFFF);
  static const Color tertiaryContainer      = Color(0xFF3A2900);
  static const Color onTertiaryContainer    = Color(0xFFBA8C00);
  static const Color tertiaryFixed          = Color(0xFFFFDF9E);
  static const Color tertiaryFixedDim       = Color(0xFFFABD00);
  static const Color onTertiaryFixed        = Color(0xFF261A00);
  static const Color onTertiaryFixedVariant = Color(0xFF5B4300);

  // ── Error ──────────────────────────────────────────────────────────────
  static const Color error                  = Color(0xFFBA1A1A);
  static const Color onError                = Color(0xFFFFFFFF);
  static const Color errorContainer         = Color(0xFFFFDAD6);
  static const Color onErrorContainer       = Color(0xFF93000A);

  // ── Semantic Status ────────────────────────────────────────────────────
  static const Color success  = Color(0xFF006A63);  // = secondary (teal = hadir)
  static const Color warning  = Color(0xFFFABD00);  // = tertiaryFixedDim (gold = terlambat)

  // ── Accent (Gold) ──────────────────────────────────────────────────────
  static const Color accent = Color(0xFFF5B800); // Gold — CTA, active state

  // ── Dark Screen Tokens ─────────────────────────────────────────────────
  // Dipakai oleh: splash_screen, welcome_screen, scanner_screen,
  // gradient_background (sengaja dark — jangan diubah ke light)
  static const Color darkBackground    = Color(0xFF0B1540);
  static const Color darkSurface       = Color(0xFF162264);
  static const Color darkAccent        = Color(0xFFF5B800);
  static const Color darkPrimary       = Color(0xFF1E66F5);
  static const Color darkSecondary     = Color(0xFF38BDF8);
  static const Color darkTextPrimary   = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB8C8FF);
  static const Color darkSuccess       = Color(0xFF2EE6A6);
  static const Color darkWarning       = Color(0xFFFFB020);
  static const Color darkError         = Color(0xFFFF5A5A);

  // ── Gradients ──────────────────────────────────────────────────────────
  /// Dark navy gradient — hanya untuk splash/welcome/scanner
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B1540), Color(0xFF0D1B52)],
  );

  /// Brand blue-to-purple gradient (logo "A")
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E66F5), Color(0xFF7B2FBE)],
  );
}
