import 'package:dio/dio.dart';
import 'package:frontend/managers/error_manager.dart';
import 'package:frontend/managers/logger_manager.dart';
class ApiService {
  static const String baseUrl = 'https://ads-optimizer-backend.onrender.com/api';

  final Dio _dio;
  final _logger = AppLogger();
  final _errorManager = ErrorManager();

  ApiService() : _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    // Add interceptors for logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.info('🌐 ${options.method} ${options.uri}');
          if (options.queryParameters.isNotEmpty) {
            _logger.debug('📋 Query: ${options.queryParameters}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.info('✅ ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) {
          final appError = _errorManager.handleError(error, error.stackTrace);
          _logger.error('❌ API Error', error);
          return handler.next(error);
        },
      ),
    );
  }

  // Helper to handle Dio errors consistently
  Never _handleDioError(DioException e, StackTrace stackTrace) {
    final appError = _errorManager.handleError(e, stackTrace);
    throw Exception(appError.message);
  }

  // ============================================
  // CAMPAIGNS ENDPOINTS
  // ============================================

  Future<Response> getCampaigns({
    bool live = true,
    String? startDate,
    String? endDate,
    List<String>? extendedFields,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'live': live,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };

      if (extendedFields != null && extendedFields.isNotEmpty) {
        queryParams['extended_fields'] = extendedFields;
      }

      return await _dio.get('/campaigns', queryParameters: queryParams);
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  Future<Response> getAvailableFields() async {
    try {
      return await _dio.get('/campaigns/available-fields');
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  // ============================================
  // STATS ENDPOINTS
  // ============================================

  Future<Response> getDashboardStats({
    required String startDate,
    required String endDate,
  }) async {
    try {
      return await _dio.get(
        '/stats/dashboard',
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        },
      );
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  // ============================================
  // OPTIMIZATIONS ENDPOINTS
  // ============================================

  Future<Response> getOptimizations({
    int? campaignId,
    String? status,
    String? priority,
    int limit = 100,
  }) async {
    try {
      return await _dio.get(
        '/optimizations',
        queryParameters: {
          if (campaignId != null) 'campaign_id': campaignId,
          if (status != null) 'status': status,
          if (priority != null) 'priority': priority,
          'limit': limit,
        },
      );
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  Future<Response> getOptimizationsCount({String? status}) async {
    try {
      return await _dio.get(
        '/optimizations/count',
        queryParameters: {
          if (status != null) 'status': status,
        },
      );
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  Future<Response> applyOptimization(int optimizationId) async {
    try {
      return await _dio.post('/optimizations/$optimizationId/apply');
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  Future<Response> dismissOptimization(int optimizationId) async {
    try {
      return await _dio.post('/optimizations/$optimizationId/dismiss');
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  Future<Response> getOptimizationDetail({
    required int optimizationId,
    bool includeLogs = false,
  }) async {
    try {
      return await _dio.get(
        '/optimizations/$optimizationId',
        queryParameters: {'include_logs': includeLogs},
      );
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  // ============================================
  // ACTIONS ENDPOINTS
  // ============================================

  Future<Response> getPendingActions({
    int? campaignId,
    String? priority,
    int limit = 100,
  }) async {
    try {
      return await _dio.get(
        '/actions/pending',
        queryParameters: {
          if (campaignId != null) 'campaign_id': campaignId,
          if (priority != null) 'priority': priority,
          'limit': limit,
        },
      );
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  Future<Response> getActionDetail(int actionId) async {
    try {
      return await _dio.get('/actions/$actionId');
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  Future<Response> approveAction({
    required int actionId,
    required bool approved,
    String approvedBy = 'user@dashboard',
  }) async {
    try {
      return await _dio.post(
        '/actions/$actionId/approve',
        data: {
          'action_id': actionId,
          'approved': approved,
          'approved_by': approvedBy,
        },
      );
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  Future<Response> executeActions({
    List<int>? actionIds,
    bool dryRun = false,
  }) async {
    try {
      return await _dio.post(
        '/actions/execute',
        data: {
          if (actionIds != null) 'action_ids': actionIds,
          'dry_run': dryRun,
        },
      );
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  // ============================================
  // ALERTS ENDPOINTS
  // ============================================

  Future<Response> getActiveAlerts({
    int? campaignId,
    String? severity,
    int limit = 100,
  }) async {
    try {
      return await _dio.get(
        '/alerts/active',
        queryParameters: {
          if (campaignId != null) 'campaign_id': campaignId,
          if (severity != null) 'severity': severity,
          'limit': limit,
        },
      );
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  Future<Response> resolveAlert({
    required int alertId,
    String? resolvedBy,
    String? notes,
  }) async {
    try {
      return await _dio.post(
        '/alerts/$alertId/resolve',
        data: {
          if (resolvedBy != null) 'resolved_by': resolvedBy,
          if (notes != null) 'notes': notes,
        },
      );
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  // ============================================
  // HEALTH ENDPOINTS
  // ============================================

  Future<Response> healthCheck() async {
    try {
      return await _dio.get('/health');
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }

  Future<Response> getSystemSummary() async {
    try {
      return await _dio.get('/health/summary');
    } on DioException catch (e, stackTrace) {
      _handleDioError(e, stackTrace);
    }
  }
}