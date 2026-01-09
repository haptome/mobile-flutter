// Purpose: API service with Dio for HTTP requests and token refresh
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:dio/dio.dart';
import 'package:et_digital_equb/config/env.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

class ApiService extends GetxService {
  static ApiService get to => Get.find();

  late Dio _dio;

  Future<void> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: Env.connectTimeout,
        receiveTimeout: Env.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());

    // Add logging interceptor (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  // Helper methods for different services
  // All services route through API Gateway at apiBaseUrl
  // The gateway automatically routes based on path prefix:
  // /auth/* → Auth Service
  // /users/* → User Service
  // /groups/* → Group Service
  // /wallets/* → Wallet Service
  // /payments/* → Payment Service
  // /rotations/* → Rotation Service
  Dio get authDio => _dio; // Routes via /auth/* path
  Dio get userDio => _dio; // Routes via /users/* path
  Dio get groupDio => _dio; // Routes via /groups/* path
  Dio get walletDio => _dio; // Routes via /wallets/* path
  Dio get paymentDio => _dio; // Routes via /payments/* path
  Dio get rotationDio => _dio; // Routes via /rotations/* path
  Dio get notificationDio => _dio; // Routes via /notifications/* path

  /// Get the current user ID from storage
  Future<String?> getCurrentUserId() async {
    final storage = StorageService.to;
    final user = await storage.getUser();
    return user?.id;
  }
}

class _AuthInterceptor extends Interceptor {
  final StorageService _storage = StorageService.to;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
          final refreshResponse = await dio.post(
            '/auth/refresh',
            data: {'refresh_token': refreshToken},
          );

          if (refreshResponse.data['success'] == true) {
            final newAccessToken = refreshResponse.data['data']['access_token'];
            await _storage.saveAccessToken(newAccessToken);

            // Retry the original request
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.request(
              opts.path,
              options: Options(method: opts.method, headers: opts.headers),
              data: opts.data,
              queryParameters: opts.queryParameters,
            );
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // Refresh failed, logout user
          await _storage.clearTokens();
          Get.offAllNamed('/login');
        }
      }
    }
    handler.next(err);
  }
}
