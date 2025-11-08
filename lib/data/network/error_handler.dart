import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../domain/core/failure.dart';

class ApiErrorHandler {
  static Either<Failure, T> handleDioError<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Left(NetworkFailure('Connection timeout, please try again'));
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data['error_message'] ?? e.response?.statusMessage;
        if (statusCode == 400) {
          return Left(ValidationFailure(errorMessage ?? 'Invalid request'));
        } else {
          return Left(ServerFailure('Server error: $statusCode $errorMessage'));
        }
      case DioExceptionType.connectionError:
        return Left(NetworkFailure('No internet connection'));
      case DioExceptionType.cancel:
        return Left(NetworkFailure('Request cancelled'));
      case DioExceptionType.badCertificate:
        return Left(ServerFailure('Invalid SSL certificate'));
      case DioExceptionType.unknown:
      return Left(ServerFailure('Unexpected error: ${e.message}'));
    }
  }
}