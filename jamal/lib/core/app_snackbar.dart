import 'package:flutter/material.dart';
import 'app_fonts.dart';

enum AppSnackBarStyle { info, success, error }

class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    AppSnackBarStyle style = AppSnackBarStyle.info,
  }) {
    final accent = _accentFor(style);
    final icon = _iconFor(style);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF6F8), Color(0xFFFFE1EA), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _accentFor(AppSnackBarStyle style) {
    switch (style) {
      case AppSnackBarStyle.success:
        return const Color(0xFF22C55E);
      case AppSnackBarStyle.error:
        return const Color(0xFFEF4444);
      case AppSnackBarStyle.info:
      default:
        return const Color(0xFFFF6F91);
    }
  }

  static IconData _iconFor(AppSnackBarStyle style) {
    switch (style) {
      case AppSnackBarStyle.success:
        return Icons.check_rounded;
      case AppSnackBarStyle.error:
        return Icons.error_outline_rounded;
      case AppSnackBarStyle.info:
      default:
        return Icons.info_outline_rounded;
    }
  }
}
