import 'package:flutter/material.dart';

/// Shadow / elevation token system for Captus — v2.0
///
/// Model: two-layer shadow for each elevation level.
///   Layer 1 (ambient): diffuse, no offset, low opacity
///   Layer 2 (direct):  tighter, Y offset, medium opacity
///
/// Brand shadows: colored with primary green for CTAs and FABs.
///
/// Reference: CAPTUS_DESIGN_SYSTEM.md §5
class AppShadows {
  AppShadows._();

  // ─── NEUTRAL ELEVATION ──────────────────────────────────────────────────────

  /// xs — barely lifts from background
  /// Use: chips, badges needing subtle separation
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0A0F172A), // rgba(15,23,42, 0.04)
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// sm — cards, focused inputs
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x140F172A), // rgba(15,23,42, 0.08)
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // rgba(15,23,42, 0.04)
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// md — elevated cards, dropdowns, hover states
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x120F172A), // rgba(15,23,42, 0.07)
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // rgba(15,23,42, 0.04)
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// lg — modals, bottom sheets, popovers
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x140F172A), // rgba(15,23,42, 0.08)
      blurRadius: 15,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // rgba(15,23,42, 0.04)
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
  ];

  /// xl — critical dialogs, overlay elements
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A0F172A), // rgba(15,23,42, 0.10)
      blurRadius: 25,
      offset: Offset(0, 20),
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // rgba(15,23,42, 0.04)
      blurRadius: 10,
      offset: Offset(0, 8),
    ),
  ];

  // ─── BRAND-TINTED ELEVATION ──────────────────────────────────────────────────
  //
  // Colored shadows reinforce brand identity on primary CTAs.
  // rgba(29, 185, 84, alpha)
  //

  /// brandSm — primary button, elevated chip
  static const List<BoxShadow> brandSm = [
    BoxShadow(
      color: Color(0x3D1DB954), // rgba(29,185,84, 0.24)
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// brandMd — FAB, primary CTA hover
  static const List<BoxShadow> brandMd = [
    BoxShadow(
      color: Color(0x4D1DB954), // rgba(29,185,84, 0.30)
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1E1DB954), // rgba(29,185,84, 0.12) — ambient
      blurRadius: 4,
      offset: Offset(0, 0),
    ),
  ];

  /// brandLg — achievement unlock, streak hero, celebration
  static const List<BoxShadow> brandLg = [
    BoxShadow(
      color: Color(0x591DB954), // rgba(29,185,84, 0.35)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x1E1DB954), // rgba(29,185,84, 0.12) — ambient glow
      blurRadius: 8,
      offset: Offset(0, 0),
    ),
  ];

  // ─── DARK-MODE SHADOWS ───────────────────────────────────────────────────────
  //
  // In dark mode, shadows become deeper; add subtle inset highlight.
  //

  /// smDark
  static const List<BoxShadow> smDark = [
    BoxShadow(
      color: Color(0x59000000), // rgba(0,0,0, 0.35)
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  /// mdDark
  static const List<BoxShadow> mdDark = [
    BoxShadow(
      color: Color(0x66000000), // rgba(0,0,0, 0.40)
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// brandDark — primary elements in dark mode
  static const List<BoxShadow> brandDark = [
    BoxShadow(
      color: Color(0x4034D399), // rgba(52,211,153, 0.25)
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x2634D399), // rgba(52,211,153, 0.15) — glow ring
      blurRadius: 1,
      offset: Offset(0, 0),
      spreadRadius: 1,
    ),
  ];
}
