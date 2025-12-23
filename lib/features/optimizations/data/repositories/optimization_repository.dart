import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/managers/error_manager.dart';
import 'package:frontend/managers/logger_manager.dart';
import '../models/optimization.dart';

class OptimizationRepository {
  final ApiService _apiService;
  final _logger = AppLogger();
  final _errorManager = ErrorManager();

  OptimizationRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get list of optimizations
  Future<List<Optimization>> getOptimizations({
    int? campaignId,
    String? status,
    String? priority,
    int limit = 100,
  }) async {
    try {
      _logger.info('📋 Fetching optimizations (status: $status, priority: $priority)');

      final response = await _apiService.getOptimizations(
        campaignId: campaignId,
        status: status,
        priority: priority,
        limit: limit,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final optimizationsJson = data['optimizations'] as List;

        final optimizations = optimizationsJson
            .map((json) => Optimization.fromJson(json))
            .toList();

        _logger.info('✅ Loaded ${optimizations.length} optimizations');
        return optimizations;
      } else {
        throw Exception('Failed to load optimizations: ${response.statusCode}');
      }
    } on DioException catch (e, stackTrace) {
      final appError = _errorManager.handleError(e, stackTrace);
      _logger.error('❌ Error getting optimizations', e, stackTrace);
      throw Exception(appError.message);
    } catch (e, stackTrace) {
      final appError = _errorManager.handleError(e, stackTrace);
      _logger.error('❌ Unexpected error getting optimizations', e, stackTrace);
      throw Exception(appError.message);
    }
  }

  /// Get optimizations count
  Future<int> getOptimizationsCount({String? status}) async {
    try {
      final response = await _apiService.getOptimizationsCount(status: status);

      if (response.statusCode == 200) {
        final count = response.data['count'] as int;
        _logger.info('📊 Optimizations count ($status): $count');
        return count;
      } else {
        throw Exception('Failed to get optimizations count: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.error('❌ Error getting optimizations count', e, stackTrace);
      return 0;
    }
  }

  /// Apply optimization (approve and execute)
  Future<bool> applyOptimization(int optimizationId) async {
    try {
      _logger.info('✅ Applying optimization $optimizationId');

      final response = await _apiService.applyOptimization(optimizationId);

      if (response.statusCode == 200) {
        final success = response.data['success'] as bool? ?? false;
        if (success) {
          _logger.info('✅ Optimization $optimizationId applied successfully');
        } else {
          _logger.warning('⚠️ Optimization $optimizationId application returned false');
        }
        return success;
      } else {
        throw Exception('Failed to apply optimization: ${response.statusCode}');
      }
    } on DioException catch (e, stackTrace) {
      final appError = _errorManager.handleError(e, stackTrace);
      _logger.error('❌ Error applying optimization', e, stackTrace);

      // Check if it's a validation error (400)
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['detail'] ?? 'Validation error';
        throw Exception(errorMessage);
      }

      throw Exception(appError.message);
    } catch (e, stackTrace) {
      final appError = _errorManager.handleError(e, stackTrace);
      _logger.error('❌ Unexpected error applying optimization', e, stackTrace);
      throw Exception(appError.message);
    }
  }

  /// Dismiss optimization (reject)
  Future<bool> dismissOptimization(int optimizationId) async {
    try {
      _logger.info('🚫 Dismissing optimization $optimizationId');

      final response = await _apiService.dismissOptimization(optimizationId);

      if (response.statusCode == 200) {
        final success = response.data['success'] as bool? ?? false;
        if (success) {
          _logger.info('✅ Optimization $optimizationId dismissed');
        }
        return success;
      } else {
        throw Exception('Failed to dismiss optimization: ${response.statusCode}');
      }
    } on DioException catch (e, stackTrace) {
      final appError = _errorManager.handleError(e, stackTrace);
      _logger.error('❌ Error dismissing optimization', e, stackTrace);
      throw Exception(appError.message);
    } catch (e, stackTrace) {
      final appError = _errorManager.handleError(e, stackTrace);
      _logger.error('❌ Unexpected error dismissing optimization', e, stackTrace);
      throw Exception(appError.message);
    }
  }

  /// Get optimization details
  Future<Optimization?> getOptimizationDetail({
    required int optimizationId,
    bool includeLogs = false,
  }) async {
    try {
      final response = await _apiService.getOptimizationDetail(
        optimizationId: optimizationId,
        includeLogs: includeLogs,
      );

      if (response.statusCode == 200) {
        return Optimization.fromJson(response.data);
      } else {
        throw Exception('Failed to get optimization detail: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.error('❌ Error getting optimization detail', e, stackTrace);
      return null;
    }
  }

  /// Filter optimizations by status
  List<Optimization> filterByStatus(List<Optimization> optimizations, String status) {
    if (status.toLowerCase() == 'all' || status.toLowerCase() == 'tutte') {
      return optimizations;
    }

    return optimizations
        .where((o) => o.status.toUpperCase() == status.toUpperCase())
        .toList();
  }

  /// Filter optimizations by priority
  List<Optimization> filterByPriority(List<Optimization> optimizations, String priority) {
    return optimizations
        .where((o) => o.priority.toUpperCase() == priority.toUpperCase())
        .toList();
  }

  /// Get pending optimizations only
  List<Optimization> getPending(List<Optimization> optimizations) {
    return optimizations.where((o) => o.status.toUpperCase() == 'PENDING').toList();
  }

  /// Get applied optimizations only
  List<Optimization> getApplied(List<Optimization> optimizations) {
    return optimizations.where((o) => o.status.toUpperCase() == 'APPLIED').toList();
  }

  /// Get dismissed optimizations only
  List<Optimization> getDismissed(List<Optimization> optimizations) {
    return optimizations.where((o) => o.status.toUpperCase() == 'DISMISSED').toList();
  }

  /// Sort optimizations by priority
  List<Optimization> sortByPriority(
      List<Optimization> optimizations, {
        bool descending = true,
      }) {
    final priorityOrder = {'HIGH': 3, 'MEDIUM': 2, 'LOW': 1};

    final sorted = List<Optimization>.from(optimizations);
    sorted.sort((a, b) {
      final aValue = priorityOrder[a.priority.toUpperCase()] ?? 0;
      final bValue = priorityOrder[b.priority.toUpperCase()] ?? 0;
      return descending ? bValue.compareTo(aValue) : aValue.compareTo(bValue);
    });

    return sorted;
  }

  /// Sort optimizations by creation date
  List<Optimization> sortByDate(
      List<Optimization> optimizations, {
        bool descending = true,
      }) {
    final sorted = List<Optimization>.from(optimizations);
    sorted.sort((a, b) {
      return descending
          ? b.createdAt!.compareTo(a.createdAt!)
          : a.createdAt!.compareTo(b.createdAt!);
    });

    return sorted;
  }

  /// Group optimizations by campaign
  Map<String, List<Optimization>> groupByCampaign(List<Optimization> optimizations) {
    final grouped = <String, List<Optimization>>{};

    for (final optimization in optimizations) {
      final campaignName = optimization.campaignName;
      if (!grouped.containsKey(campaignName)) {
        grouped[campaignName] = [];
      }
      grouped[campaignName]!.add(optimization);
    }

    return grouped;
  }

  /// Calculate potential impact across optimizations
  double calculateTotalPotentialImpact(List<Optimization> optimizations) {
    double total = 0;

    for (final opt in optimizations) {
      if (opt.expectedImpact != null) {
        // Extract percentage from string like "Increase ROAS by 15%"
        final match = RegExp(r'(\d+\.?\d*)%').firstMatch(opt.expectedImpact!);
        if (match != null) {
          final percentage = double.tryParse(match.group(1)!) ?? 0;
          total += percentage;
        }
      }
    }

    return total;
  }
}