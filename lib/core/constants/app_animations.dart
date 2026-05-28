import 'package:flutter/material.dart';

/// Motion design tokens for Captus — v2.0
///
/// Principles:
///   1. Immediate response — every tap shows feedback within [instant]
///   2. Exit < Enter — leaving is faster than entering
///   3. Natural physics — spring for micro-interactions, not mechanical linear
///   4. Semantic movement — direction communicates hierarchy
///
/// Reference: CAPTUS_DESIGN_SYSTEM.md §6
class AppDurations {
  AppDurations._();

  /// 80 ms — Press feedback: ripple, scale, checkbox toggle.
  static const Duration instant = Duration(milliseconds: 80);

  /// 120 ms — Icon state change, color/icon swap.
  static const Duration quick = Duration(milliseconds: 120);

  /// 180 ms — Chip/badge state, inline opacity, hover color.
  static const Duration fast = Duration(milliseconds: 180);

  /// 240 ms — Card appearances, tab switches, container resizes.
  static const Duration standard = Duration(milliseconds: 240);

  /// 320 ms — Screen entries, modal opens, bottom sheet.
  static const Duration comfortable = Duration(milliseconds: 320);

  /// 420 ms — Achievement unlock, streak celebration.
  static const Duration slow = Duration(milliseconds: 420);

  /// 600 ms — Count-up numbers, progress bar fill, onboarding.
  static const Duration deliberate = Duration(milliseconds: 600);

  /// 900 ms — Looping: typing indicator, spinner dots.
  static const Duration loop = Duration(milliseconds: 900);

  /// 1200 ms — Skeleton shimmer sweep (full cycle).
  static const Duration shimmer = Duration(milliseconds: 1200);

  // ── Legacy aliases (backwards compat) ───────────────────────────────────────
  /// @deprecated Use [comfortable] instead.
  static const Duration push = comfortable;

  /// @deprecated Use [comfortable] instead.
  static const Duration enter = comfortable;

  /// @deprecated Use [fast] instead.
  static const Duration exit = fast;

  /// @deprecated Use [deliberate] instead.
  static const Duration countUp = deliberate;
}

/// Named easing curves following Design System v2.0 motion guidelines.
///
/// Each curve corresponds to a specific interaction pattern.
/// See AppDurations for the matching duration tokens.
class AppCurves {
  AppCurves._();

  /// Standard — both start and end at rest.
  /// Use for: tab content switches, card appearances, container resizes.
  static const Curve standard = Curves.easeInOutCubic;

  /// Enter — decelerate; element enters from rest, eases to stop.
  /// Use for: screens pushing in, modal opening, list item appearing.
  static const Curve enter = Curves.easeOut;

  /// Exit — accelerate; element starts at rest, leaves quickly.
  /// Use for: screens popping, bottom sheet closing, dismiss.
  static const Curve exit = Curves.easeIn;

  /// Spring — natural bounce for micro-interactions.
  /// Use for: FAB entrance, task completion check, achievement badge.
  static const Curve spring = Curves.elasticOut;

  /// Spring soft — mild overshoot (less dramatic than spring).
  /// Use for: button release, chip selection, toggle switches.
  static const Curve springShort = Cubic(0.34, 1.56, 0.64, 1.0);

  /// Linear — constant-speed for looping animations.
  /// Use for: progress indicators, shimmer sweep, spinners.
  static const Curve linear = Curves.linear;

  /// Ease-in-out — smooth and elegant for premium feel.
  /// Use for: color transitions, opacity cross-fades.
  static const Curve smooth = Curves.easeInOutSine;
}

/// Named interaction animation specifications.
///
/// Each constant describes a named motion pattern from the design system.
/// Use these as documentation references when implementing custom animations.
///
/// Pattern format: (transform, duration, curve, trigger)
class AppMotion {
  AppMotion._();

  // ─── Press / Release ────────────────────────────────────────────────────────
  /// scale(0.97) + opacity(0.9) @ instant/exit → on tap down
  static const pressDuration = AppDurations.instant;
  static const pressCurve = AppCurves.exit;
  static const double pressScale = 0.97;
  static const double pressOpacity = 0.90;

  /// scale(1.0) + opacity(1.0) @ quick/springShort → on tap up
  static const releaseDuration = AppDurations.quick;
  static const releaseCurve = AppCurves.springShort;

  // ─── Appear / Exit ──────────────────────────────────────────────────────────
  /// opacity(0→1) + translateY(8→0) @ standard/enter → on mount
  static const appearDuration = AppDurations.standard;
  static const appearCurve = AppCurves.enter;
  static const double appearOffset = 8.0; // px

  /// opacity(1→0) + translateY(0→-8) @ fast/exit → on unmount
  static const dismissDuration = AppDurations.fast;
  static const dismissCurve = AppCurves.exit;

  // ─── Float-in (modals, bottom sheets) ───────────────────────────────────────
  /// translateY(16→0) + opacity(0→1) @ comfortable/enter
  static const floatInDuration = AppDurations.comfortable;
  static const floatInCurve = AppCurves.enter;
  static const double floatInOffset = 16.0; // px

  // ─── Pop (achievements, celebrations) ──────────────────────────────────────
  /// scale(0.8→1.05→1) @ slow/spring
  static const popDuration = AppDurations.slow;
  static const popCurve = AppCurves.spring;

  // ─── Stagger delay ──────────────────────────────────────────────────────────
  /// 40ms delay between each item in a staggered list
  static const staggerDelay = Duration(milliseconds: 40);

  // ─── Page transitions ────────────────────────────────────────────────────────
  /// Horizontal slide offset for push navigation
  static const double pageSlideOffset = 1.0; // fraction (FractionalOffset)
  static const pageDuration = AppDurations.comfortable;
  static const pageCurve = AppCurves.enter;
}
