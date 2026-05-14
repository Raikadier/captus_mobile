import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_animations.dart';

/// Standard Captus bottom sheet wrapper.
///
/// Enforces the design system: 20dp top radius, handle bar, correct
/// padding, slide+fade animation, and keyboard-safe bottom inset.
///
/// Usage:
/// ```dart
/// CaptusBottomSheet.show(
///   context: context,
///   title: 'Filtros',
///   child: YourContent(),
/// );
/// ```
class CaptusBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool showHandle;
  final EdgeInsetsGeometry? padding;

  const CaptusBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.showHandle = true,
    this.padding,
  });

  /// Show as a modal bottom sheet with the Captus design system styling.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(AppAlpha.a40),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: AppDurations.enter,
        reverseDuration: AppDurations.exit,
      ),
      builder: (_) => CaptusBottomSheet(
        title: title,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: (padding ??
                  EdgeInsets.fromLTRB(24, 0, 24, 32 + bottomInset)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHandle) ...[
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 20),
              if (title != null) ...[
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
