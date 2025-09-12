import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_constant.dart';
import '../../../domain/core/failure.dart';
import '../../network/error_handler.dart';
import '../local/shared_preference_helper.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstant.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = SharedPreferencesHelper(
            await SharedPreferences.getInstance(),
          ).getString(SharedPreferencesHelper.TOKEN_KEY);
          if (kDebugMode) {
            print(
              'API Request - Token: ${token != null ? "Present (${token.length} chars)" : "Not found"}',
            );
            print('API Request - URL: ${options.uri}');
          }
          if (token != null && token.isNotEmpty) {
            // Add Authorization header
            options.headers['Authorization'] = 'Bearer $token';
            if (kDebugMode) {
              print('API Request - Authorization header added');
            }
          } else {
            if (kDebugMode) {
              print(
                'API Request - No token available, skipping Authorization header',
              );
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('Response: ${response.statusCode}');
          }
          return handler.next(response);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) {
          final failure = ApiErrorHandler.handleDioError(e);
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: failure,
              response: e.response,
              type: e.type,
            ),
          );
        },
      ),
    );
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (log) => print(log), // This is where logs are printed
      ),
    );
  }

  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return Right(
        fromJson != null ? fromJson(response.data) : response.data as T,
      );
    } on DioException catch (e) {
      return ApiErrorHandler.handleDioError<T>(e);
    } catch (e, stack) {
      // Catch everything else (like invalid JSON, String response, etc.)
      return Left(InValidResponseFailure("Invalid response from server: $e"));
    }
  }

  // Uses: dio, dartz (Either), your ApiErrorHandler

  Future<Either<Failure, T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return Right(
        fromJson != null ? fromJson(response.data) : response.data as T,
      );
    } on DioException catch (e) {
      return ApiErrorHandler.handleDioError<T>(e);
    }
  }

  // Add other methods (post, put, etc.) as needed
}
