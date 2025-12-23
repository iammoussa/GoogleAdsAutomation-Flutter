import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/managers/error_manager.dart';
import 'package:frontend/managers/logger_manager.dart';
import '../models/campaign.dart';

class CampaignRepository {
  final ApiService _apiService;
  final _logger = AppLogger();
  final _errorManager = ErrorManager();

  CampaignRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get campaigns with optional extended fields
  Future<List<Campaign>> getCampaigns({
    bool live = true,
    String? startDate,
    String? endDate,
    List<String>? extendedFields,
  }) async {
    try {
      _logger.info('📡 Fetching campaigns (live: $live)');

      final response = await _apiService.getCampaigns(
        live: live,
        startDate: startDate,
        endDate: endDate,
        extendedFields: extendedFields,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final campaignsJson = data['campaigns'] as List;

        final campaigns = campaignsJson
            .map((json) => Campaign.fromJson(json))
            .toList();

        _logger.info('✅ Loaded ${campaigns.length} campaigns');
        return campaigns;
      } else {
        throw Exception('Failed to load campaigns: ${response.statusCode}');
      }
    } on DioException catch (e, stackTrace) {
      final appError = _errorManager.handleError(e, stackTrace);
      _logger.error('❌ Error getting campaigns', e, stackTrace);
      throw Exception(appError.message);
    } catch (e, stackTrace) {
      final appError = _errorManager.handleError(e, stackTrace);
      _logger.error('❌ Unexpected error getting campaigns', e, stackTrace);
      throw Exception(appError.message);
    }
  }

  /// Get campaign by ID
  Future<Campaign?> getCampaignById(String campaignId) async {
    try {
      final campaigns = await getCampaigns(live: true);
      return campaigns.firstWhere(
            (c) => c.campaignId == campaignId,
        orElse: () => throw Exception('Campaign not found'),
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Error getting campaign by ID', e, stackTrace);
      return null;
    }
  }

  /// Get available metric fields
  Future<Map<String, dynamic>> getAvailableFields() async {
    try {
      final response = await _apiService.getAvailableFields();

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get available fields: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      final appError = _errorManager.handleError(e, stackTrace);
      _logger.error('❌ Error getting available fields', e, stackTrace);
      throw Exception(appError.message);
    }
  }

  /// Filter campaigns by status
  List<Campaign> filterByStatus(List<Campaign> campaigns, String status) {
    if (status.toLowerCase() == 'all' || status.toLowerCase() == 'tutte') {
      return campaigns;
    }

    final statusMap = {
      'active': 'ENABLED',
      'attive': 'ENABLED',
      'paused': 'PAUSED',
      'in pausa': 'PAUSED',
      'removed': 'REMOVED',
      'rimosse': 'REMOVED',
    };

    final targetStatus = statusMap[status.toLowerCase()] ?? status.toUpperCase();

    return campaigns.where((c) => c.status.toUpperCase() == targetStatus).toList();
  }

  /// Filter campaigns needing attention (high cost or low CTR)
  List<Campaign> filterNeedingAttention(
      List<Campaign> campaigns, {
        double maxCost = 1000.0,
        double minCtr = 1.0,
      }) {
    return campaigns.where((c) {
      return c.cost > maxCost || c.ctr < minCtr;
    }).toList();
  }

  /// Sort campaigns by metric
  List<Campaign> sortByMetric(
      List<Campaign> campaigns,
      String metric, {
        bool descending = true,
      }) {
    final sorted = List<Campaign>.from(campaigns);

    sorted.sort((a, b) {
      late num aValue;
      late num bValue;

      switch (metric.toLowerCase()) {
        case 'cost':
        case 'spend':
          aValue = a.cost;
          bValue = b.cost;
          break;
        case 'conversions':
          aValue = a.conversions;
          bValue = b.conversions;
          break;
        case 'ctr':
          aValue = a.ctr;
          bValue = b.ctr;
          break;
        case 'cpc':
          aValue = a.cpc;
          bValue = b.cpc;
          break;
        case 'roas':
          aValue = a.roas!.toDouble();
          bValue = b.roas!.toDouble();
          break;
        case 'impressions':
          aValue = a.impressions;
          bValue = b.impressions;
          break;
        case 'clicks':
          aValue = a.clicks;
          bValue = b.clicks;
          break;
        default:
          aValue = a.cost;
          bValue = b.cost;
      }

      return descending ? bValue.compareTo(aValue) : aValue.compareTo(bValue);
    });

    return sorted;
  }

  /// Get top performing campaigns
  List<Campaign> getTopPerformers(
      List<Campaign> campaigns, {
        int limit = 5,
        String metric = 'roas',
      }) {
    final sorted = sortByMetric(campaigns, metric, descending: true);
    return sorted.take(limit).toList();
  }

  /// Calculate total metrics across campaigns
  Map<String, num> calculateTotals(List<Campaign> campaigns) {
    if (campaigns.isEmpty) {
      return {
        'cost': 0,
        'conversions': 0,
        'conversion_value': 0,
        'impressions': 0,
        'clicks': 0,
        'ctr': 0,
        'cpc': 0,
        'roas': 0,
      };
    }

    final totalCost = campaigns.fold<double>(0, (sum, c) => sum + c.cost);
    final totalConversions = campaigns.fold<int>(0, (sum, c) => sum + c.conversions);
    final totalConversionValue = campaigns.fold<double>(0, (sum, c) => sum + c.conversionValue);
    final totalImpressions = campaigns.fold<int>(0, (sum, c) => sum + c.impressions);
    final totalClicks = campaigns.fold<int>(0, (sum, c) => sum + c.clicks);

    final avgCtr = totalImpressions > 0 ? (totalClicks / totalImpressions) * 100 : 0;
    final avgCpc = totalClicks > 0 ? totalCost / totalClicks : 0;
    final avgRoas = totalCost > 0 ? totalConversionValue / totalCost : 0;

    return {
      'cost': totalCost,
      'conversions': totalConversions,
      'conversion_value': totalConversionValue,
      'impressions': totalImpressions,
      'clicks': totalClicks,
      'ctr': avgCtr,
      'cpc': avgCpc,
      'roas': avgRoas,
    };
  }
}