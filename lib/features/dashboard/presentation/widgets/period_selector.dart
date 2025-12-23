import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DateRangeType {
  today,
  yesterday,
  thisWeek,
  last7Days,
  lastWeek,
  last14Days,
  thisMonth,
  last30Days,
  lastMonth,
  allTime,
  custom,
}

class DateRangeOption {
  final DateRangeType type;
  final String label;
  final DateTime? startDate;
  final DateTime? endDate;

  DateRangeOption({
    required this.type,
    required this.label,
    this.startDate,
    this.endDate,
  });

  static DateRangeOption calculate(DateRangeType type) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? start;
    DateTime? end;
    String label;

    switch (type) {
      case DateRangeType.today:
        label = 'Today';
        start = today;
        end = today;
        break;

      case DateRangeType.yesterday:
        label = 'Yesterday';
        start = today.subtract(const Duration(days: 1));
        end = start;
        break;

      case DateRangeType.thisWeek:
        label = 'This week (Sun – Today)';
        final daysFromSunday = now.weekday % 7;
        start = today.subtract(Duration(days: daysFromSunday));
        end = today;
        break;

      case DateRangeType.last7Days:
        label = 'Last 7 days';
        start = today.subtract(const Duration(days: 6));
        end = today;
        break;

      case DateRangeType.lastWeek:
        label = 'Last week (Sun – Sat)';
        final daysFromSunday = now.weekday % 7;
        final lastSunday = today.subtract(Duration(days: daysFromSunday + 7));
        start = lastSunday;
        end = lastSunday.add(const Duration(days: 6));
        break;

      case DateRangeType.last14Days:
        label = 'Last 14 days';
        start = today.subtract(const Duration(days: 13));
        end = today;
        break;

      case DateRangeType.thisMonth:
        label = 'This month';
        start = DateTime(now.year, now.month, 1);
        end = today;
        break;

      case DateRangeType.last30Days:
        label = 'Last 30 days';
        start = today.subtract(const Duration(days: 29));
        end = today;
        break;

      case DateRangeType.lastMonth:
        label = 'Last month';
        final firstDayThisMonth = DateTime(now.year, now.month, 1);
        final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
        start = firstDayLastMonth;
        end = firstDayThisMonth.subtract(const Duration(days: 1));
        break;

      case DateRangeType.allTime:
        label = 'All time';
        start = null;
        end = null;
        break;

      case DateRangeType.custom:
        label = 'Custom';
        start = null;
        end = null;
        break;
    }

    return DateRangeOption(
      type: type,
      label: label,
      startDate: start,
      endDate: end,
    );
  }

  String get startDateFormatted {
    if (startDate == null) return '';
    return '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
  }

  String get endDateFormatted {
    if (endDate == null) return '';
    return '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
  }

  String toPreferenceString() {
    return type.toString().split('.').last;
  }

  static DateRangeType fromPreferenceString(String value) {
    try {
      return DateRangeType.values.firstWhere(
            (e) => e.toString().split('.').last == value,
        orElse: () => DateRangeType.today,
      );
    } catch (e) {
      return DateRangeType.today;
    }
  }
}

class PeriodSelector extends StatelessWidget {
  final DateRangeOption selectedRange;
  final Function(DateRangeOption) onRangeChanged;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const PeriodSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.padding,
    this.borderRadius,
  });

  Future<void> _saveSelectedRange(DateRangeType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_date_range', type.toString().split('.').last);
  }

  static Future<DateRangeOption> loadSelectedRange() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString('selected_date_range');

    if (savedValue != null) {
      final type = DateRangeOption.fromPreferenceString(savedValue);
      return DateRangeOption.calculate(type);
    }

    return DateRangeOption.calculate(DateRangeType.today);
  }

  void _showPeriodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Period',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRangeOption(context, DateRangeType.today),
                    _buildRangeOption(context, DateRangeType.yesterday),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Divider(),
                    ),

                    _buildRangeOption(context, DateRangeType.thisWeek, hasArrow: true),
                    _buildRangeOption(context, DateRangeType.last7Days),
                    _buildRangeOption(context, DateRangeType.lastWeek, hasArrow: true),
                    _buildRangeOption(context, DateRangeType.last14Days),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Divider(),
                    ),

                    _buildRangeOption(context, DateRangeType.thisMonth),
                    _buildRangeOption(context, DateRangeType.last30Days),
                    _buildRangeOption(context, DateRangeType.lastMonth),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Divider(),
                    ),

                    _buildRangeOption(context, DateRangeType.allTime),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Custom date range coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Custom range'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeOption(
      BuildContext context,
      DateRangeType type, {
        bool hasArrow = false,
      }) {
    final option = DateRangeOption.calculate(type);
    final isSelected = selectedRange.type == type;

    return ListTile(
      title: Text(
        option.label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasArrow)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          const SizedBox(width: 8),
          if (isSelected)
            Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            )
          else
            const SizedBox(width: 24),
        ],
      ),
      onTap: () async {
        await _saveSelectedRange(option.type);
        onRangeChanged(option);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Modern elevated background
    final bgColor = backgroundColor ??
        (isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surfaceContainerHigh);

    return GestureDetector(
      onTap: () => _showPeriodPicker(context),
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          // No border - clean modern look
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.calendar_today,
              size: 18,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              selectedRange.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: textColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}