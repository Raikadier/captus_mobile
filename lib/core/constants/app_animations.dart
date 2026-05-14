import 'package:flutter/material.dart';

/// Motion design tokens for Captus.
///
/// All animation durations and curves must reference constants from this
/// file. Never use Duration(milliseconds: 200) or Curves.easeInOut inline.
///
/// Principles:
/// - Respond immediately: every tap must show feedback within [instant]
/// - Exit faster than enter: [exit] < [enter]
/// - Semantic movement: direction communicates hierarchy
class AppDurations {
  AppDurations._();

  /// 80 ms — Tap feedback: ripple, press scale, checkbox toggle.
  static const Duration instant = Duration(milliseconds: 80);

  /// 150 ms — Inline color/opacity changes: chips, badges, icon swaps.
  static const Duration fast = Duration(milliseconds: 150);

  /// 200 ms — Tab switches, container size changes, exit transitions.
  static const Duration exit = Duration(milliseconds: 200);

  /// 250 ms — Card appearances, section expansions, dialog scale.
  static const Duration standard = Duration(milliseconds: 250);

  /// 300 ms — Push navigation, list item slide.
  static const Duration push = Duration(milliseconds: 300);

  /// 350 ms — Screen entry, bottom sheet open, modal open.
  static const Duration enter = Duration(milliseconds: 350);

  /// 500 ms — Onboarding slides, achievement unlock, streak hero.
  static const Duration slow = Duration(milliseconds: 500);

  /// 800 ms — CountUp number animations, progress bar fill.
  static const Duration countUp = Duration(milliseconds: 800);

  /// 900 ms — Looping animations (typing indicator, shimmer).
  static const Duration loop = Duration(milliseconds: 900);

  /// 1200 ms — Skeleton shimmer sweep (full cycle).
  static const Duration shimmer = Duration(milliseconds: 1200);
}

/// Named easing curves following Material 3 motion guidelines.
///
/// - [standard]  → transitions that start AND end at rest (most transitions)
/// - [enter]     → elements entering the screen (fast start, slow end)
/// - [exit]      → elements leaving the screen (slow start, fast end)
/// - [spring]    → micro-interactions with a natural bounce (FAB, completions)
/// - [linear]    → progress indicators and looping animations
class AppCurves {
  AppCurves._();

  /// Standard easing — elements that start and end at rest.
  /// Use for: tab content switches, card appearances, container resizes.
  static const Curve standard = Curves.easeInOut;

  /// Decelerate — elements entering the screen.
  /// Use for: screens pushing in, bottom sheet opening, modals.
  static const Curve enter = Curves.easeOut;

  /// Accelerate — elements leaving the screen.
  /// Use for: screens popping, bottom sheet closing, dismiss animations.
  static const Curve exit = Curves.easeIn;

  /// Spring / elastic — micro-interactions with a natural bounce.
  /// Use for: FAB entrance, task completion check, achievement unlock.
  static const Curve spring = Curves.elasticOut;

  /// Linear — constant-speed looping animations.
  /// Use for: progress indicators, shimmer, typing dots, spinners.
  static const Curve linear = Curves.linear;
}
