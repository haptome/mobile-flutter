// Purpose: Payment service for handling payment-related API calls
// Author: Generated
// Linked Spec Section: Payment History Integration

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/api_service.dart';

class PaymentService extends GetxService {
  static PaymentService get to => Get.find();

  final ApiService _apiService = Get.find<ApiService>();

  // ─── TeleBirr ─────────────────────────────────────────────────────────────

  /// Create a TeleBirr H5 C2B payment session.
  /// Returns { paymentId, gateway_url, expires_at }.
  Future<Map<String, dynamic>> createTelebirrSession({
    required String groupId,
    required double amount,
    int? cycleNumber,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'group_id': groupId,
        'amount': amount,
      };
      final Map<String, dynamic> meta = {...?metadata};
      if (cycleNumber != null) meta['cycle_number'] = cycleNumber;
      if (meta.isNotEmpty) body['metadata'] = meta;

      final response = await _apiService.paymentDio.post(
        '/payments/telebirr/create',
        data: body,
      );

      if (response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(
        response.data['message'] ?? 'Failed to create TeleBirr session',
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Network error occurred');
    }
  }

  /// Poll TeleBirr for the current order status and sync the DB.
  /// Returns { status, trade_status, amount }.
  Future<Map<String, dynamic>> queryTelebirrOrder(String paymentId) async {
    try {
      final response = await _apiService.paymentDio.get(
        '/payments/telebirr/$paymentId/query',
      );

      if (response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(
        response.data['message'] ?? 'Failed to query TeleBirr order',
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Network error occurred');
    }
  }

  // ─── Generic / shared ─────────────────────────────────────────────────────

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
      if (userId == null) throw Exception('User not authenticated');

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
        final responseData = response.data['data'];
        if (responseData == null) return [];
        if (responseData is List) return List<Map<String, dynamic>>.from(responseData);
        if (responseData is Map) {
          if (responseData.containsKey('data') && responseData['data'] is List) {
            return List<Map<String, dynamic>>.from(responseData['data']);
          } else if (responseData.containsKey('items') && responseData['items'] is List) {
            return List<Map<String, dynamic>>.from(responseData['items']);
          } else if (responseData.containsKey('transactions') && responseData['transactions'] is List) {
            return List<Map<String, dynamic>>.from(responseData['transactions']);
          }
          return [Map<String, dynamic>.from(responseData)];
        }
        return [];
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch transaction history');
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
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch payment');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get payment status
  Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) async {
    try {
      final response = await _apiService.paymentDio.get('/payments/$paymentId/status');
      if (response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch payment status');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
