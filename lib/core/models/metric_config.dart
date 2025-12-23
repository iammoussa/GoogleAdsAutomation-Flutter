import 'package:flutter/material.dart';

/// Available metric categories
enum MetricCategory {
  recommended,
  performance,
  results,
  viewability,
  conversions,
  attribution,
  competitive,
}

extension MetricCategoryExtension on MetricCategory {
  String get displayName {
    switch (this) {
      case MetricCategory.recommended:
        return 'Recommended columns';
      case MetricCategory.performance:
        return 'Performance';
      case MetricCategory.results:
        return 'Results';
      case MetricCategory.viewability:
        return 'Viewability';
      case MetricCategory.conversions:
        return 'Conversions';
      case MetricCategory.attribution:
        return 'Attribution';
      case MetricCategory.competitive:
        return 'Competitive metrics';
    }
  }
}

/// Represents a single metric configuration
class MetricConfig {
  final String key; // Internal key (e.g., 'cost', 'conversions')
  final String displayName; // Display name (e.g., 'Cost', 'Conversions')
  final String description; // Tooltip description
  final MetricCategory category;
  final String? unit; // Unit (e.g., '€', '%')
  final bool isPercentage; // If true, format as percentage

  const MetricConfig({
    required this.key,
    required this.displayName,
    required this.description,
    required this.category,
    this.unit,
    this.isPercentage = false,
  });

  /// All available metrics organized by category
  static const Map<MetricCategory, List<MetricConfig>> allMetrics = {
    MetricCategory.recommended: [
      MetricConfig(
        key: 'cost',
        displayName: 'Cost',
        description: 'Total amount spent on this campaign',
        category: MetricCategory.recommended,
        unit: '€',
      ),
      MetricConfig(
        key: 'impressions',
        displayName: 'Impressions',
        description: 'Number of times your ads were shown',
        category: MetricCategory.recommended,
      ),
      MetricConfig(
        key: 'conversions',
        displayName: 'Conversions',
        description: 'Number of conversions tracked',
        category: MetricCategory.recommended,
      ),
      MetricConfig(
        key: 'cost_per_conv',
        displayName: 'Cost / conv.',
        description: 'Average cost per conversion',
        category: MetricCategory.recommended,
        unit: '€',
      ),
    ],
    MetricCategory.performance: [
      MetricConfig(
        key: 'clicks',
        displayName: 'Clicks',
        description: 'Number of clicks on your ads',
        category: MetricCategory.performance,
      ),
      MetricConfig(
        key: 'ctr',
        displayName: 'CTR',
        description: 'Click-through rate (clicks / impressions)',
        category: MetricCategory.performance,
        isPercentage: true,
      ),
      MetricConfig(
        key: 'average_cpc',
        displayName: 'Avg. CPC',
        description: 'Average cost per click',
        category: MetricCategory.performance,
        unit: '€',
      ),
      MetricConfig(
        key: 'average_cpm',
        displayName: 'Avg. CPM',
        description: 'Average cost per 1000 impressions',
        category: MetricCategory.performance,
        unit: '€',
      ),
      MetricConfig(
        key: 'interactions',
        displayName: 'Interactions',
        description: 'Number of user interactions with your ads',
        category: MetricCategory.performance,
      ),
      MetricConfig(
        key: 'interaction_rate',
        displayName: 'Interaction rate',
        description: 'Percentage of impressions that resulted in interaction',
        category: MetricCategory.performance,
        isPercentage: true,
      ),
      MetricConfig(
        key: 'engagements',
        displayName: 'Engagements',
        description: 'Number of engagements with your ads',
        category: MetricCategory.performance,
      ),
      MetricConfig(
        key: 'engagement_rate',
        displayName: 'Engagement rate',
        description: 'Percentage of impressions that resulted in engagement',
        category: MetricCategory.performance,
        isPercentage: true,
      ),
    ],
    MetricCategory.results: [
      MetricConfig(
        key: 'conversion_value',
        displayName: 'Conv. value',
        description: 'Total value of conversions',
        category: MetricCategory.results,
        unit: '€',
      ),
      MetricConfig(
        key: 'cost_per_action',
        displayName: 'Cost per action',
        description: 'Average cost per action',
        category: MetricCategory.results,
        unit: '€',
      ),
      MetricConfig(
        key: 'roas',
        displayName: 'ROAS',
        description: 'Return on ad spend (conv. value / cost)',
        category: MetricCategory.results,
      ),
    ],
    MetricCategory.viewability: [
      MetricConfig(
        key: 'viewable_impressions',
        displayName: 'Viewable impr.',
        description: 'Number of viewable impressions',
        category: MetricCategory.viewability,
      ),
      MetricConfig(
        key: 'viewable_ctr',
        displayName: 'Viewable CTR',
        description: 'Click-through rate for viewable impressions',
        category: MetricCategory.viewability,
        isPercentage: true,
      ),
    ],
    MetricCategory.conversions: [
      MetricConfig(
        key: 'conversion_rate',
        displayName: 'Conv. rate',
        description: 'Percentage of interactions that resulted in conversion',
        category: MetricCategory.conversions,
        isPercentage: true,
      ),
    ],
    MetricCategory.attribution: [
      MetricConfig(
        key: 'all_conversions',
        displayName: 'All conv.',
        description: 'All conversions including cross-device',
        category: MetricCategory.attribution,
      ),
      MetricConfig(
        key: 'all_conversion_value',
        displayName: 'All conv. value',
        description: 'Total value of all conversions',
        category: MetricCategory.attribution,
        unit: '€',
      ),
    ],
    MetricCategory.competitive: [
      MetricConfig(
        key: 'search_impression_share',
        displayName: 'Search impr. share',
        description: 'Percentage of impressions you received out of total available',
        category: MetricCategory.competitive,
        isPercentage: true,
      ),
      MetricConfig(
        key: 'search_top_impression_share',
        displayName: 'Search top impr. share',
        description: 'Percentage of impressions shown at top of search results',
        category: MetricCategory.competitive,
        isPercentage: true,
      ),
    ],
  };

  /// Get all metrics as flat list
  static List<MetricConfig> get allMetricsList {
    return allMetrics.values.expand((list) => list).toList();
  }

  /// Find metric by key
  static MetricConfig? findByKey(String key) {
    return allMetricsList.firstWhere(
          (metric) => metric.key == key,
      orElse: () => const MetricConfig(
        key: '',
        displayName: '',
        description: '',
        category: MetricCategory.recommended,
      ),
    );
  }
}

/// User's selected metric with color configuration
class SelectedMetric {
  final MetricConfig config;
  final Color? color; // null means use default theme color
  final int order; // Display order (0-3)

  const SelectedMetric({
    required this.config,
    this.color,
    required this.order,
  });

  SelectedMetric copyWith({
    MetricConfig? config,
    Color? color,
    int? order,
    bool clearColor = false,
  }) {
    return SelectedMetric(
      config: config ?? this.config,
      color: clearColor ? null : (color ?? this.color),
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metric_key': config.key,
      'color': color?.value,
      'order': order,
    };
  }

  factory SelectedMetric.fromJson(Map<String, dynamic> json) {
    final metricKey = json['metric_key'] as String;
    final config = MetricConfig.findByKey(metricKey);

    return SelectedMetric(
      config: config!,
      color: json['color'] != null ? Color(json['color'] as int) : null,
      order: json['order'] as int,
    );
  }
}

/// Available chart colors
class MetricColors {
  static const Color yellow = Color(0xFFF9AB02);
  static const Color red = Color(0xFFD92F25);
  static const Color green = Color(0xFF1A8039);
  static const Color blue = Color(0xFF1A73E7);

  static const List<Color> available = [yellow, red, green, blue];

  static final Map<Color, String> names = {
    yellow: 'Yellow',
    red: 'Red',
    green: 'Green',
    blue: 'Blue',
  };
}