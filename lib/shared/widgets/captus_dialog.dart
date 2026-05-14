import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_animations.dart';

/// Standard Captus dialog wrapper.
///
/// Enforces design system: 16dp radius, scale+fade animation,
/// standard button layout (cancel left, action right).
///
/// Usage:
/// ```dart
/// // Confirmation dialog
/// final confirmed = await CaptusDialog.confirm(
///   context: context,
///   title: '¿Eliminar tarea?',
///   message: 'Esta acción no se puede deshacer.',
///   confirmLabel: 'Eliminar',
///   isDangerous: true,
/// );
///
/// // Custom dialog
/// CaptusDialog.show(
///   context: context,
///   title: 'Título',
///   content: YourWidget(),
/// );
/// ```
class CaptusDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDangerous;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const CaptusDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmLabel = 'Aceptar',
    this.cancelLabel = 'Cancelar',
    this.isDangerous = false,
    this.onConfirm,
    this.onCancel,
  });

  /// Show a confirmation dialog. Returns `true` if the user confirmed.
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    String? message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool isDangerous = false,
  }) async {
    final result = await show<bool>(
      context: context,
      dialog: CaptusDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDangerous: isDangerous,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }

  /// Show a custom dialog with the Captus styling.
  static Future<T?> show<T>({
    required BuildContext context,
    required CaptusDialog dialog,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withAlpha(AppAlpha.a40),
      transitionDuration: AppDurations.standard,
      pageBuilder: (_, __, ___) => dialog,
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: AppCurves.enter);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            // Body
            if (message != null) ...[
              const SizedBox(height: 10),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: 12),
              content!,
            ],
            const SizedBox(height: 24),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      onCancel ?? () => Navigator.of(context).pop(false),
                  child: Text(cancelLabel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: isDangerous
                      ? ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.textOnPrimary,
                        )
                      : null,
                  onPressed:
                      onConfirm ?? () => Navigator.of(context).pop(true),
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
