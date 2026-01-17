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

  // Upload KYC document with progress tracking
  Future<ApiResponse<KycDocument>> uploadDocument({
    required String filePath,
    required DocumentType docType,
    Map<String, dynamic>? metadata,
    void Function(int sent, int total)? onSendProgress,
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
        onSendProgress: onSendProgress,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) {
          // Backend returns {document_id, file_url, storage_key}
          // We need to fetch the full document or construct a partial one
          if (data is Map<String, dynamic>) {
            // If backend returns full document, use it
            if (data.containsKey('id')) {
              return KycDocument.fromJson(data);
            }
            // If backend returns data with nested document, use that
            if (data.containsKey('data') &&
                data['data'] is Map<String, dynamic>) {
              final dataMap = data['data'] as Map<String, dynamic>;
              if (dataMap.containsKey('id')) {
                return KycDocument.fromJson(dataMap);
              }
            }
            // Otherwise, construct from upload response
            return KycDocument(
              id: data['document_id'] as String? ?? data['id'] as String? ?? '',
              docType: data['doc_type'] as String? ?? docType.value,
              fileName:
                  data['file_name'] as String? ?? filePath.split('/').last,
              fileUrl:
                  data['file_url'] as String? ?? data['file_url'] as String?,
              status: data['status'] as String? ?? 'uploaded',
              uploadedAt: DateTime.now(),
              metadata: metadata,
            );
          }
          throw Exception('Invalid response format');
        },
      );

      return apiResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle error response from server
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          // If the error response has a document in the data field
          if (responseData.containsKey('data') &&
              responseData['data'] is Map<String, dynamic>) {
            try {
              return ApiResponse.fromJson(
                responseData,
                (data) => KycDocument.fromJson(data as Map<String, dynamic>),
              );
            } catch (parseError) {
              // If parsing fails, return error response
              return ApiResponse<KycDocument>(
                success: false,
                error: ApiError(
                  code: 'UPLOAD_ERROR',
                  message:
                      responseData['message'] as String? ??
                      responseData['error'] as String? ??
                      'Upload failed',
                ),
              );
            }
          }
        }

        // Return error response
        return ApiResponse<KycDocument>(
          success: false,
          error: ApiError(
            code: 'UPLOAD_ERROR',
            message: responseData is Map
                ? (responseData['message'] as String? ??
                      responseData['error'] as String? ??
                      'Upload failed')
                : 'Upload failed',
          ),
        );
      }
      rethrow;
    } catch (e) {
      return ApiResponse<KycDocument>(
        success: false,
        error: ApiError(code: 'UPLOAD_ERROR', message: e.toString()),
      );
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
          // Backend returns paginated response: {data: [...], pagination: {...}}
          // The data field is already the array of documents
          if (data is List) {
            return data
                .map((doc) => KycDocument.fromJson(doc as Map<String, dynamic>))
                .toList();
          }
          // Check for nested data array (common API response format)
          if (data is Map && data.containsKey('data')) {
            final dataValue = data['data'];
            if (dataValue is List) {
              return dataValue
                  .map(
                    (doc) => KycDocument.fromJson(doc as Map<String, dynamic>),
                  )
                  .toList();
            }
          }
          // Fallback: check for nested documents key (legacy format)
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
        data: {'document_ids': documentIds},
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

  // Get KYC status from the dedicated endpoint
  Future<ApiResponse<KycStatus>> getKycStatus() async {
    try {
      final response = await _apiService.userDio.get('/kyc/status');
      print('status++++++++++++++++++++++: $response');

      // Directly parse the response since we know the structure
      Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

      // Extract the inner data object
      Map<String, dynamic>? innerData =
          responseData['data'] as Map<String, dynamic>?;
      print('responseData: $innerData');

      if (innerData != null) {
        // Extract kyc_status from the response
        String status = innerData['kyc_status'] as String? ?? 'not_started';

        // Get documents array
        List<dynamic> documentsList =
            innerData['documents'] as List<dynamic>? ?? [];

        List<KycDocument> documents = documentsList
            .map((doc) => KycDocument.fromJson(doc as Map<String, dynamic>))
            .toList();

        // Create and return the KycStatus object
        KycStatus kycStatus = KycStatus(status: status, documents: documents);

        // Create a successful ApiResponse with the parsed data
        return ApiResponse<KycStatus>(
          success: true,
          data: kycStatus,
          message: responseData['message'] as String?,
        );
      }

      // Fallback to default values if data is not available
      return ApiResponse<KycStatus>(
        success: false,
        data: KycStatus(status: 'not_started', documents: []),
        message: 'Unable to parse KYC status response',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
          (data) => KycStatus(status: 'not_started', documents: []),
        );
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting KYC status: $e');
      }
      rethrow;
    }
  }

  // Initiate liveness check session
  Future<ApiResponse<Map<String, dynamic>>> initiateLiveness({
    String? provider,
  }) async {
    try {
      final response = await _apiService.userDio.post(
        '/kyc/liveness/initiate',
        data: {if (provider != null) 'provider': provider},
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

  // Submit liveness check video/photo files with progress tracking
  Future<ApiResponse<Map<String, dynamic>>> submitLiveness({
    required String sessionId,
    String? videoPath,
    String? photoPath,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final formData = dio.FormData();

      // Add session ID
      formData.fields.add(MapEntry('session_id', sessionId));

      // Add video file if provided
      if (videoPath != null && videoPath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'files',
            await dio.MultipartFile.fromFile(
              videoPath,
              filename: videoPath.split('/').last,
            ),
          ),
        );
      }

      // Add photo file if provided
      if (photoPath != null && photoPath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'files',
            await dio.MultipartFile.fromFile(
              photoPath,
              filename: photoPath.split('/').last,
            ),
          ),
        );
      }

      final response = await _apiService.userDio.post(
        '/kyc/liveness/submit',
        data: formData,
        onSendProgress: onSendProgress,
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
}
