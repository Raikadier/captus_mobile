import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_animations.dart';
import '../../core/providers/connectivity_provider.dart';

/// Renders an animated "Sin conexión" banner when offline.
/// Mount it above your main content (e.g. inside the shell scaffold body).
///
/// ```dart
/// Column(children: [
///   const OfflineBanner(),
///   Expanded(child: child),
/// ])
/// ```
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider);

    return AnimatedSwitcher(
      duration: AppDurations.exit,
      child: online
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('offline'),
              width: double.infinity,
              color: AppColors.offline,
              padding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 14, color: AppColors.textOnDark),
                  const SizedBox(width: 8),
                  Text(
                    'Sin conexión a internet',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnDark,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
