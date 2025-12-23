import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final EdgeInsets? padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? actionStyle;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.padding,
    this.titleStyle,
    this.subtitleStyle,
    this.actionStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle ??
                      const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: subtitleStyle ??
                        TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (actionText != null && onActionPressed != null) ...[
            TextButton(
              onPressed: onActionPressed,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                actionText!,
                style: actionStyle ??
                    const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}