/// Border-radius token system for Captus — v2.0
///
/// 8-level scale aligned with the design system.
/// All values map to BorderRadius.circular(N) for consistency.
///
/// Reference: CAPTUS_DESIGN_SYSTEM.md §4
import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  // ─── SCALE ──────────────────────────────────────────────────────────────────
  static const double r0   = 0.0;   //  0px — sharp corners
  static const double r1   = 4.0;   //  4px — chips, badges compact
  static const double r2   = 6.0;   //  6px — inputs, small chips
  static const double r3   = 8.0;   //  8px — tags, small cards
  static const double r4   = 10.0;  // 10px — buttons compact, icon containers
  static const double r5   = 12.0;  // 12px — buttons standard
  static const double r6   = 14.0;  // 14px — cards standard
  static const double r7   = 16.0;  // 16px — cards large, modals
  static const double r8   = 20.0;  // 20px — bottom sheets
  static const double r9   = 24.0;  // 24px — dialogs, hero cards
  static const double r10  = 28.0;  // 28px — bottom sheet top
  static const double full = 999.0; // full — pills, circles

  // ─── NAMED ALIASES ──────────────────────────────────────────────────────────
  /// xs — chips, badges (4px)
  static const double xs = r1;

  /// sm — inputs, text fields (6px)
  static const double sm = r2;

  /// md — buttons standard (12px)
  static const double md = r5;

  /// lg — cards standard (14px)
  static const double lg = r6;

  /// xl — cards large, panels (16px)
  static const double xl = r7;

  /// xxl — bottom sheets, overlays (20px)
  static const double xxl = r8;

  /// dialog — dialogs, hero cards (24px)
  static const double dialog = r9;

  /// sheet — bottom sheet top corners (28px)
  static const double sheet = r10;

  /// pill — fully rounded (chips, toggles)
  static const double pill = full;

  // ─── BORDER RADIUS HELPERS ──────────────────────────────────────────────────
  static BorderRadius circular(double r) => BorderRadius.circular(r);

  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(r6));
  static const BorderRadius buttonBorderRadius = BorderRadius.all(Radius.circular(r5));
  static const BorderRadius inputBorderRadius = BorderRadius.all(Radius.circular(r2));
  static const BorderRadius chipBorderRadius = BorderRadius.all(Radius.circular(full));
  static const BorderRadius sheetBorderRadius = BorderRadius.vertical(top: Radius.circular(r10));
  static const BorderRadius dialogBorderRadius = BorderRadius.all(Radius.circular(r9));
}
