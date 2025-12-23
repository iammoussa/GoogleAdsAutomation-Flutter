import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(
      BuildContext context, {
        required String message,
        String? actionLabel,
        VoidCallback? onActionPressed,
        Duration duration = const Duration(seconds: 4),
        IconData? icon,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null
            ? SnackBarAction(
          label: actionLabel,
          textColor: isDark
              ? Colors.white  // White in dark mode
              : Colors.blue.shade700,  // Blue in light mode
          onPressed: onActionPressed ?? () {},
        )
            : null,
        backgroundColor: isDark
            ? const Color(0xFF2C3E50).withOpacity(0.95)  // Dark semi-transparent
            : const Color(0xFF323232).withOpacity(0.95),  // Standard dark semi-transparent
        behavior: SnackBarBehavior.floating,  // Floating!
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),  // Rounded corners
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        duration: duration,
        elevation: 6,
      ),
    );
  }

  // Preset: Success
  static void showSuccess(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 3),
      }) {
    show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  // Preset: Error
  static void showError(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 4),
      }) {
    show(
      context,
      message: message,
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  // Preset: Info
  static void showInfo(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 3),
      }) {
    show(
      context,
      message: message,
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  // Preset: Dismissable card (with undo)
  static void showDismissed(
      BuildContext context, {
        required String message,
        required VoidCallback onUndo,
        Duration duration = const Duration(seconds: 4),
      }) {
    show(
      context,
      message: message,
      icon: Icons.visibility_off_outlined,
      actionLabel: 'Annulla',
      onActionPressed: onUndo,
      duration: duration,
    );
  }
}