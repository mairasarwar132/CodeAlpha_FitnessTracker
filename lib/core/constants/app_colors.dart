import 'package:flutter/material.dart';

/// Premium fitness app color palette inspired by Fitbit, Nike Training Club,
/// Samsung Health, and Strava.
class AppColors {
  AppColors._();

  // ── Primary Palette ──
  static const primary = Color(0xFF1E293B); // Dark slate
  static const accent = Color(0xFF00D4AA); // Vibrant mint
  static const secondary = Color(0xFF3B82F6); // Bright blue
  static const background = Color(0xFFF8FAFC); // Cool light grey
  static const surface = Color(0xFFFFFFFF); // White cards
  static const darkBackground = Color(0xFF0F172A); // Deep navy

  // ── Semantic Colors ──
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // ── Accent Variations ──
  static const accentLight = Color(0xFF33DFBB);
  static const accentDark = Color(0xFF00B894);

  // ── Neutral Tones ──
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const divider = Color(0xFFF1F5F9);

  // ── Gradients ──
  static const gradientAccent = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientDark = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCard = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
