// Purpose: KYC service for document upload and submission
// Author: haptome H.
// Linked Spec Section: FR02-FR03

import 'package:dio/dio.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart' as dio show FormData, MultipartFile;
import 'package:et_digital_equb/models/api_response.dart';
import 'package:et_digital_equb/models/kyc_models.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'api_service.dart';

class KycService extends GetxService {
  static KycService get to => Get.find();

  final ApiService _apiService = ApiService.to;

  // Upload KYC document
  Future<ApiResponse<KycDocument>> uploadDocument({
    required String filePath,
    required DocumentType docType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        'doc_type': docType.value,
        if (metadata != null) 'metadata': metadata,
      });

      final response = await _apiService.userDio.post(
        '/kyc/documents/upload',
        data: formData,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => KycDocument.fromJson(data as Map<String, dynamic>),
      );

      return apiResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
          (data) => KycDocument.fromJson(data as Map<String, dynamic>),
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Get user's KYC documents
  Future<ApiResponse<List<KycDocument>>> getDocuments({
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiService.userDio.get(
        '/kyc/documents',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) {
          if (data is Map && data.containsKey('documents')) {
            return (data['documents'] as List<dynamic>)
                .map((doc) => KycDocument.fromJson(doc as Map<String, dynamic>))
                .toList();
          }
          return <KycDocument>[];
        },
      );

      return apiResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
          (data) => <KycDocument>[],
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Submit documents for KYC review
  Future<ApiResponse<Map<String, dynamic>>> submitDocuments({
    required List<String> documentIds,
  }) async {
    try {
      final response = await _apiService.userDio.post(
        '/kyc/documents/submit',
        data: {
          'document_ids': documentIds,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      return apiResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
          (data) => data as Map<String, dynamic>,
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Get KYC status (combines documents and user profile kyc_status)
  Future<ApiResponse<KycStatus>> getKycStatus() async {
    try {
      // Get documents
      final documentsResponse = await getDocuments();
      
      // Get user profile to check kyc_status
      String kycStatus = 'not_started';
      
      try {
        // Try to get current user's kyc_status from AuthService
        // This is a workaround - ideally we'd have a dedicated endpoint
        final profileResponse = await _apiService.authDio.get('/auth/profile');
        if (profileResponse.data['success'] == true && 
            profileResponse.data['data'] != null) {
          kycStatus = profileResponse.data['data']['kyc_status'] ?? 'not_started';
        }
      } catch (e) {
        // If profile fetch fails, use default
        if (kDebugMode) {
          print('Could not fetch user profile for KYC status: $e');
        }
      }
      
      final status = KycStatus(
        status: kycStatus,
        documents: documentsResponse.success && documentsResponse.data != null
            ? documentsResponse.data!
            : [],
      );

      return ApiResponse(
        success: true,
        data: status,
        message: 'KYC status retrieved successfully',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting KYC status: $e');
      }
      rethrow;
    }
  }
}

