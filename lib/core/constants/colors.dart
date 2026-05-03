import 'package:flutter/material.dart';

/// AMBIS colour palette — 60/30/10 rule from logoAMBIS.png.
///
/// 60 % — Deep Navy  (#0B1540) : background, dominant canvas
/// 30 % — Royal Blue (#162264) : surfaces, cards, interactive components
/// 10 % — Gold       (#F5B800) : accent, primary CTAs, active indicators
class AppColors {
  AppColors._();

  // ── 60 % DOMINANT — Deep Navy ──────────────────────────────────────
  static const Color background    = Color(0xFF0B1540);
  static const Color backgroundAlt = Color(0xFF0D1B52);

  // ── 30 % SECONDARY — Royal Blue ────────────────────────────────────
  static const Color surface       = Color(0xFF162264);
  static const Color surfaceAlt    = Color(0xFF1E2E7A);
  static const Color primary       = Color(0xFF1E66F5);
  static const Color primaryDark   = Color(0xFF0B1540);

  // ── 10 % ACCENT — Gold ─────────────────────────────────────────────
  static const Color accent        = Color(0xFFF5B800);
  static const Color accentDark    = Color(0xFFE0A500);

  // Supporting
  static const Color secondary     = Color(0xFF38BDF8);

  // Status
  static const Color success       = Color(0xFF2EE6A6);
  static const Color warning       = Color(0xFFFFB020);
  static const Color error         = Color(0xFFFF5A5A);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8C8FF);
  static const Color textHint      = Color(0xFF6B85CC);

  // Gradients
  /// Subtle background canvas
  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B1540), Color(0xFF0D1B52)],
  );

  /// Logo "A" blue-to-purple brand gradient
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E66F5), Color(0xFF7B2FBE)],
  );

  /// Gold shimmer for accent highlights
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5B800), Color(0xFFFDD835)],
  );
}
