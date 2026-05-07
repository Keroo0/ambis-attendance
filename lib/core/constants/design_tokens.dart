/// Design Tokens — centralized from Stitch Design System
/// Colors derived from SMAN 07 Smart Presence project
library;

import 'package:flutter/material.dart';

abstract class DesignTokens {
  // ── Color Palette ──────────────────────────────────────
  static const primary = Color(0xFF002B5B);
  static const primaryContainer = Color(0xFF7594CA);
  static const onPrimary = Colors.white;
  static const secondary = Color(0xFF006A63);
  static const onSecondary = Colors.white;
  static const tertiary = Color(0xFF201600);
  static const background = Color(0xFFF7F9FB);
  static const surface = Colors.white;
  static const surfaceVariant = Color(0xFFE0E3E5);
  static const surfaceContainer = Color(0xFFECEEF0);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF43474F);
  static const outline = Color(0xFFC4C6D0);
  static const outlineVariant = Color(0xFFE2E8F0);
  static const error = Color(0xFFBA1A1A);
  static const onError = Colors.white;
  static const cyanAccent = Color(0xFF47FBEB);
  static const hintText = Color(0xFF9EA3AB);
  static const iconDefault = Color(0xFF747780);

  // ── Spacing (8pt grid) ─────────────────────────────────
  static const spacing4 = 4.0;
  static const spacing8 = 8.0;
  static const spacing12 = 12.0;
  static const spacing16 = 16.0;
  static const spacing20 = 20.0;
  static const spacing24 = 24.0;
  static const spacing32 = 32.0;

  // ── Border Radius (Stitch ROUND_EIGHT) ────────────────
  static const radius8 = BorderRadius.all(Radius.circular(8));
  static const radius10 = BorderRadius.all(Radius.circular(10));
  static const radius16 = BorderRadius.all(Radius.circular(16));

  // ── Shadows ────────────────────────────────────────────
  static final cardShadow = BoxShadow(
    color: Colors.black.withAlpha(5),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  // ── Typography Scale (Lexend) ─────────────────────────
  static const fontFamily = 'Lexend';

  static const h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
  );

  static const h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  static const bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static const labelCaps = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    height: 16 / 12,
  );

  static const buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 20 / 13,
  );

  static const smallText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 16 / 11,
  );

  // ── Input Decoration ───────────────────────────────────
  static const inputBorder = OutlineInputBorder(
    borderRadius: radius8,
    borderSide: const BorderSide(color: outline),
  );

  static final inputEnabledBorder = OutlineInputBorder(
    borderRadius: radius8,
    borderSide: BorderSide(color: outline.withAlpha(130)),
  );

  static const inputFocusedBorder = OutlineInputBorder(
    borderRadius: radius8,
    borderSide: const BorderSide(color: secondary, width: 1.5),
  );

  static const inputErrorBorder = OutlineInputBorder(
    borderRadius: radius8,
    borderSide: const BorderSide(color: error, width: 1.0),
  );

  static const inputErrorFocusedBorder = OutlineInputBorder(
    borderRadius: radius8,
    borderSide: const BorderSide(color: error, width: 1.5),
  );
}
