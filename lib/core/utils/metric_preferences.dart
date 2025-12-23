import 'dart:convert';
import 'package:frontend/core/models/metric_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages persistence of user's metric preferences
class MetricPreferences {
  static const String _selectedMetricsKey = 'selected_dashboard_metrics';
  static const String _dashboardViewModeKey = 'dashboard_view_mode';

  /// Save selected metrics to SharedPreferences
  static Future<void> saveSelectedMetrics(List<SelectedMetric> metrics) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = metrics.map((m) => m.toJson()).toList();
    await prefs.setString(_selectedMetricsKey, jsonEncode(jsonList));
  }

  /// Load selected metrics from SharedPreferences
  /// Returns default metrics if none saved
  static Future<List<SelectedMetric>> loadSelectedMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_selectedMetricsKey);

    if (jsonString == null) {
      return _getDefaultMetrics();
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => SelectedMetric.fromJson(json)).toList();
    } catch (e) {
      return _getDefaultMetrics();
    }
  }

  /// Get default metrics (Cost, Conversions, Cost/Conv, Conv. Value)
  static List<SelectedMetric> _getDefaultMetrics() {
    return [
      SelectedMetric(
        config: MetricConfig.findByKey('cost')!,
        order: 0,
      ),
      SelectedMetric(
        config: MetricConfig.findByKey('conversions')!,
        order: 1,
      ),
      SelectedMetric(
        config: MetricConfig.findByKey('cost_per_conv')!,
        order: 2,
      ),
      SelectedMetric(
        config: MetricConfig.findByKey('conversion_value')!,
        order: 3,
      ),
    ];
  }

  /// Save dashboard view mode (card or chart)
  static Future<void> saveDashboardViewMode(DashboardViewMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dashboardViewModeKey, mode.name);
  }

  /// Load dashboard view mode
  static Future<DashboardViewMode> loadDashboardViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_dashboardViewModeKey);

    if (modeString == null) {
      return DashboardViewMode.card;
    }

    return DashboardViewMode.values.firstWhere(
          (mode) => mode.name == modeString,
      orElse: () => DashboardViewMode.card,
    );
  }
}

/// Dashboard view modes
enum DashboardViewMode {
  card, // 2x2 grid of StatCards
  chart, // Line chart with multiple metrics
}