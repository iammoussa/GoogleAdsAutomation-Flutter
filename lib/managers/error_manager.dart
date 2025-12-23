import 'package:frontend/managers/logger_manager.dart';

enum ErrorType {
  network,
  api,
  validation,
  unauthorized,
  notFound,
  unknown,
}

class AppError {
  final String message;
  final ErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final int? statusCode;

  AppError({
    required this.message,
    required this.type,
    this.originalError,
    this.stackTrace,
    this.statusCode,
  });

  @override
  String toString() {
    return 'AppError{type: $type, message: $message, statusCode: $statusCode}';
  }
}

class ErrorManager {
  static final ErrorManager _instance = ErrorManager._internal();
  factory ErrorManager() => _instance;
  ErrorManager._internal();

  final _logger = AppLogger();

  AppError handleError(dynamic error, StackTrace? stackTrace) {
    if (error is AppError) {
      _logError(error);
      return error;
    }

    final appError = _convertToAppError(error, stackTrace);
    _logError(appError);
    return appError;
  }

  AppError _convertToAppError(dynamic error, StackTrace? stackTrace) {
    if (error is Exception) {
      final errorString = error.toString();

      if (errorString.contains('SocketException') ||
          errorString.contains('Network error')) {
        return AppError(
          message: 'Network connection failed. Please check your internet.',
          type: ErrorType.network,
          originalError: error,
          stackTrace: stackTrace,
        );
      }

      if (errorString.contains('401')) {
        return AppError(
          message: 'Unauthorized. Please login again.',
          type: ErrorType.unauthorized,
          originalError: error,
          stackTrace: stackTrace,
          statusCode: 401,
        );
      }

      if (errorString.contains('404')) {
        return AppError(
          message: 'Resource not found.',
          type: ErrorType.notFound,
          originalError: error,
          stackTrace: stackTrace,
          statusCode: 404,
        );
      }

      if (errorString.contains('Failed to load') ||
          errorString.contains('Failed to fetch')) {
        return AppError(
          message: 'Failed to load data from server.',
          type: ErrorType.api,
          originalError: error,
          stackTrace: stackTrace,
        );
      }

      return AppError(
        message: errorString.replaceAll('Exception: ', ''),
        type: ErrorType.unknown,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    return AppError(
      message: error?.toString() ?? 'Unknown error occurred',
      type: ErrorType.unknown,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  void _logError(AppError error) {
    _logger.error(
      '[${error.type.name.toUpperCase()}] ${error.message}',
      error.originalError,
      error.stackTrace,
    );
  }

  String getUserFriendlyMessage(AppError error) {
    switch (error.type) {
      case ErrorType.network:
        return 'No internet connection. Please check your network.';
      case ErrorType.api:
        return 'Unable to load data. Please try again.';
      case ErrorType.validation:
        return error.message;
      case ErrorType.unauthorized:
        return 'Session expired. Please login again.';
      case ErrorType.notFound:
        return 'Data not found.';
      case ErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }
}