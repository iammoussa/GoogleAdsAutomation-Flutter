import 'package:flutter/material.dart';

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double? fontSize;

  const CustomFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.padding,
    this.borderRadius,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Modern elevated background - distinct from surface
    final unselectedBgColor = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Theme.of(context).colorScheme.surfaceContainerHigh;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ?? Theme.of(context).colorScheme.primary)
              : (unselectedColor ?? unselectedBgColor),
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          // No border - clean modern look
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.15 : 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 2 : 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? (selectedTextColor ?? Colors.white)
                : (unselectedTextColor ?? Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}