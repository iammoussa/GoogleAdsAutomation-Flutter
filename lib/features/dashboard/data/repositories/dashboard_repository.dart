import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/managers/error_manager.dart';
import 'package:frontend/managers/logger_manager.dart';
import '../../domain/entities/dashboard_stats.dart';

class DashboardRepository {
  final ApiService _apiService;
  final _logger = AppLogger();
  final _errorManager = ErrorManager();

  DashboardRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get dashboard statistics with period comparison
  Future<DashboardStats> getStats({
    required String startDate,
    required String endDate,
  }) async {
    try {
      _logger.info('📊 Fetching dashboard stats from $startDate to $endDate');

      final response = await _apiService.getDashboardStats(
        startDate: startDate,
        endDate: endDate,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final stats = DashboardStats(
          spend: (data['spend'] as num).toDouble(),
          spendChange: (data['spend_change'] as num).toDouble(),
          conversions: data['conversions'] as int,
          conversionsChange: (data['conversions_change'] as num).toDouble(),
          costPerConversion: (data['cost_per_conversion'] as num).toDouble(),
          costPerConversionChange: (data['cost_per_conv_change'] as num).toDouble(),
          conversionValue: (data['conversion_value'] as num).toDouble(),
          conversionValueChange: (data['value_change'] as num).toDouble(),
        );

        _logger.info('✅ Dashboard stats loaded: €${stats.spend}, ${stats.conversions} conv');
        return stats;
      } else {
        throw Exception('Failed to load dashboard stats: ${response.statusCode}');
      }
    } on DioException catch (e, stackTrace) {
      final appError = _errorManager.handleError(e, stackTrace);
      _logger.error('❌ Error getting dashboard stats', e, stackTrace);
      throw Exception(appError.message);
    } catch (e, stackTrace) {
      final appError = _errorManager.handleError(e, stackTrace);
      _logger.error('❌ Unexpected error getting dashboard stats', e, stackTrace);
      throw Exception(appError.message);
    }
  }

  /// Get pending optimizations count
  Future<int> getPendingOptimizationsCount() async {
    try {
      final response = await _apiService.getOptimizationsCount(status: 'pending');

      if (response.statusCode == 200) {
        final count = response.data['count'] as int;
        _logger.info('📋 Pending optimizations: $count');
        return count;
      } else {
        throw Exception('Failed to get optimizations count: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.error('❌ Error getting optimizations count', e, stackTrace);
      return 0; // Return 0 on error to prevent breaking dashboard
    }
  }

  /// Calculate ROAS (Return on Ad Spend)
  double calculateRoas(double conversionValue, double spend) {
    if (spend <= 0) return 0;
    return conversionValue / spend;
  }

  /// Calculate CPA (Cost per Acquisition)
  double calculateCpa(double spend, int conversions) {
    if (conversions <= 0) return 0;
    return spend / conversions;
  }

  /// Determine if metric change is positive
  bool isPositiveChange(String metricKey, double change) {
    // For cost metrics, negative change is good
    final negativeBetterMetrics = ['cost', 'cpc', 'cpa', 'cost_per_conversion'];

    if (negativeBetterMetrics.contains(metricKey.toLowerCase())) {
      return change < 0;
    }

    // For revenue/conversion metrics, positive change is good
    return change > 0;
  }

  /// Format currency
  String formatCurrency(double amount, {String symbol = '€'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format percentage
  String formatPercentage(double value, {bool showSign = true}) {
    final formatted = value.toStringAsFixed(1);
    if (showSign && value > 0) {
      return '+$formatted%';
    }
    return '$formatted%';
  }

  /// Format large numbers with K/M suffix
  String formatCompactNumber(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}