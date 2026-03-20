// Purpose: Service for lottery/drawing API operations
// Author: Auto-generated

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'api_service.dart';
import '../../models/api_response.dart';

class LotteryService extends GetxService {
  static LotteryService get to => Get.find();

  final ApiService _apiService = ApiService.to;

  /// Get current cycle information including countdown and status
  Future<ApiResponse<Map<String, dynamic>>> getCurrentCycle(String groupId) async {
    try {
      final response = await _apiService.rotationDio.get(
        '/rotations/$groupId/current-cycle',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.data['success'] == true) {
        return ApiResponse.success(response.data['data']);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get current cycle');
      }
    } on DioException catch (e) {
      // Handle 404 specifically - rotation service not available
      if (e.response?.statusCode == 404) {
        return ApiResponse.error('Rotation service not available - using fallback data');
      }
      // Handle timeout specifically
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse.error('Rotation service timeout - using fallback data');
      }
      return ApiResponse.error(e.message ?? 'Network error occurred');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  /// Get current cycle winner(s)
  Future<ApiResponse<Map<String, dynamic>>> getCurrentWinner(String groupId) async {
    try {
      final response = await _apiService.rotationDio.get(
        '/rotations/$groupId/current-winner',
      );

      if (response.data['success'] == true) {
        return ApiResponse.success(response.data['data']);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get current winner');
      }
    } on DioException catch (e) {
      // Handle 404 specifically - rotation service not available
      if (e.response?.statusCode == 404) {
        return ApiResponse.error('Rotation service not available - using fallback data');
      }
      return ApiResponse.error(e.message ?? 'Network error occurred');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  /// Get previous cycles results with pagination
  Future<ApiResponse<Map<String, dynamic>>> getPreviousCycles(
    String groupId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.rotationDio.get(
        '/rotations/$groupId/previous-cycles',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success'] == true) {
        return ApiResponse.success(response.data['data']);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get previous cycles');
      }
    } on DioException catch (e) {
      // Handle 404 specifically - rotation service not available
      if (e.response?.statusCode == 404) {
        return ApiResponse.error('Rotation service not available - using fallback data');
      }
      return ApiResponse.error(e.message ?? 'Network error occurred');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  /// Get lottery numbers for current cycle
  Future<ApiResponse<List<Map<String, dynamic>>>> getLotteryNumbers(String groupId) async {
    try {
      final response = await _apiService.rotationDio.get(
        '/rotations/$groupId/lottery-numbers',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.data['success'] == true) {
        return ApiResponse.success(List<Map<String, dynamic>>.from(response.data['data']));
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get lottery numbers');
      }
    } on DioException catch (e) {
      // Handle 404 specifically - rotation service not available
      if (e.response?.statusCode == 404) {
        return ApiResponse.error('Rotation service not available - using fallback data');
      }
      // Handle timeout specifically
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse.error('Rotation service timeout - using fallback data');
      }
      return ApiResponse.error(e.message ?? 'Network error occurred');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  /// Trigger manual drawing (for testing purposes)
  Future<ApiResponse<Map<String, dynamic>>> triggerDrawing(String groupId) async {
    try {
      final response = await _apiService.rotationDio.post(
        '/rotations/$groupId/trigger-drawing',
      );

      if (response.data['success'] == true) {
        return ApiResponse.success(response.data['data']);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to trigger drawing');
      }
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Network error occurred');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  /// Get drawing schedule for a group
  Future<ApiResponse<Map<String, dynamic>>> getDrawingSchedule(String groupId) async {
    try {
      final response = await _apiService.rotationDio.get(
        '/rotations/$groupId/schedule',
      );

      if (response.data['success'] == true) {
        return ApiResponse.success(response.data['data']);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get drawing schedule');
      }
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Network error occurred');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred');
    }
  }
}