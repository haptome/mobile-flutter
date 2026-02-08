// Purpose: Payment service for handling payment-related API calls
// Author: Generated
// Linked Spec Section: Payment History Integration

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/api_service.dart';

class PaymentService extends GetxService {
  static PaymentService get to => Get.find();

  final ApiService _apiService = Get.find<ApiService>();

  /// Get transaction history for the current user
  Future<List<Map<String, dynamic>>?> getUserTransactionHistory({
    String? groupId,
    String? gateway,
    String? status,
    String? startDate,
    String? endDate,
    int? limit = 20,
    int? offset = 0,
  }) async {
    try {
      final userId = await _apiService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final queryParameters = <String, dynamic>{};
      if (groupId != null) queryParameters['groupId'] = groupId;
      if (gateway != null) queryParameters['gateway'] = gateway;
      if (status != null) queryParameters['status'] = status;
      if (startDate != null) queryParameters['startDate'] = startDate;
      if (endDate != null) queryParameters['endDate'] = endDate;
      if (limit != null) queryParameters['limit'] = limit;
      if (offset != null) queryParameters['offset'] = offset;

      final response = await _apiService.paymentDio.get(
        '/payments/user/$userId/history',
        queryParameters: queryParameters,
      );

      if (response.data['success'] == true) {
        // Handle both direct array and wrapped data structure
        final data = response.data['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          return [];
        }
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch transaction history',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get payment by ID
  Future<Map<String, dynamic>?> getPaymentById(String paymentId) async {
    try {
      final response = await _apiService.paymentDio.get('/payments/$paymentId');

      if (response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch payment');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get payment status
  Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) async {
    try {
      final response = await _apiService.paymentDio.get(
        '/payments/$paymentId/status',
      );

      if (response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch payment status',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
