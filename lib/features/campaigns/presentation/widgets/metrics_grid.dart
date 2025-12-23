import 'package:flutter/material.dart';
import 'metric_item.dart';

class MetricsGrid extends StatelessWidget {
  final Map<String, String> metrics;

  const MetricsGrid({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final entries = metrics.entries.toList();

    return Column(
      children: [
        for (int i = 0; i < entries.length; i += 2) ...[
          Row(
            children: [
              Expanded(
                child: MetricItem(
                  label: entries[i].key,
                  value: entries[i].value,
                  valueColor: _getValueColor(entries[i].key),
                ),
              ),
              if (i + 1 < entries.length)
                Expanded(
                  child: MetricItem(
                    label: entries[i + 1].key,
                    value: entries[i + 1].value,
                    valueColor: _getValueColor(entries[i + 1].key),
                  ),
                ),
            ],
          ),
          if (i + 2 < entries.length) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Color? _getValueColor(String label) {
    if (label.toUpperCase().contains('ROAS')) {
      return Colors.green;
    }
    return null;
  }
}