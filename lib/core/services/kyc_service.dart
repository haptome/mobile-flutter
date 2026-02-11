// Purpose: KYC service for document upload and submission
// Author: haptome H.
// Linked Spec Section: FR02-FR03

import 'package:dio/dio.dart';
import 'package:et_digital_equb/core/services/cloudinary_service.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/models/api_response.dart';
import 'package:et_digital_equb/models/kyc_models.dart';
import 'package:et_digital_equb/models/queued_upload.dart';
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
      // Import CloudinaryService and AuthService
      final cloudinaryService = Get.find<CloudinaryService>();
      final authService = Get.find<AuthService>();
      
      // Step 1: Validate file using CloudinaryService
      final validation = cloudinaryService.validateFile(filePath, FileType.image);
      if (!validation.isValid) {
        return ApiResponse<KycDocument>(
          success: false,
          error: ApiError(
            code: 'VALIDATION_ERROR',
            message: validation.errorMessage!,
          ),
        );
      }
      
      // Step 2: Get userId and generate folder
      final userId = authService.currentUser.value?.id ?? 'unknown';
      final folder = cloudinaryService.generateKycFolder(userId, docType.value);
      
      // Step 3: Upload to Cloudinary
      final cloudinaryResponse = await cloudinaryService.uploadImage(
        filePath: filePath,
        folder: folder,
        metadata: metadata,
        onProgress: onSendProgress,
      );
      
      if (!cloudinaryResponse.success) {
        return ApiResponse<KycDocument>(
          success: false,
          error: ApiError(
            code: cloudinaryResponse.error!.code,
            message: cloudinaryResponse.error!.message,
          ),
        );
      }
      
      // Step 4: Send URL to backend
      final response = await _apiService.userDio.post(
        '/kyc/documents/upload',
        data: {
          'file_url': cloudinaryResponse.secureUrl,
          'storage_provider': 'cloudinary',
          'public_id': cloudinaryResponse.publicId,
          'doc_type': docType.value,
          'file_name': filePath.split('/').last,
          if (metadata != null) 'metadata': metadata,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) {
          if (data is Map<String, dynamic>) {
            if (data.containsKey('id')) {
              return KycDocument.fromJson(data);
            }
            if (data.containsKey('data') &&
                data['data'] is Map<String, dynamic>) {
              final dataMap = data['data'] as Map<String, dynamic>;
              if (dataMap.containsKey('id')) {
                return KycDocument.fromJson(dataMap);
              }
            }
            return KycDocument(
              id: data['document_id'] as String? ?? data['id'] as String? ?? '',
              docType: data['doc_type'] as String? ?? docType.value,
              fileName:
                  data['file_name'] as String? ?? filePath.split('/').last,
              fileUrl:
                  data['file_url'] as String? ?? cloudinaryResponse.secureUrl,
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
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') &&
              responseData['data'] is Map<String, dynamic>) {
            try {
              return ApiResponse.fromJson(
                responseData,
                (data) => KycDocument.fromJson(data as Map<String, dynamic>),
              );
            } catch (parseError) {
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
      final cloudinaryService = Get.find<CloudinaryService>();
      final authService = Get.find<AuthService>();
      final userId = authService.currentUser.value?.id ?? 'unknown';
      
      String? videoUrl;
      String? photoUrl;
      
      // Upload video if provided
      if (videoPath != null && videoPath.isNotEmpty) {
        final folder = cloudinaryService.generateLivenessVideoFolder(userId);
        final response = await cloudinaryService.uploadVideo(
          filePath: videoPath,
          folder: folder,
          onProgress: onSendProgress,
        );
        
        if (!response.success) {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            error: ApiError(
              code: response.error!.code,
              message: response.error!.message,
            ),
          );
        }
        
        videoUrl = response.secureUrl;
      }
      
      // Upload photo if provided
      if (photoPath != null && photoPath.isNotEmpty) {
        final folder = cloudinaryService.generateLivenessPhotoFolder(userId);
        final response = await cloudinaryService.uploadImage(
          filePath: photoPath,
          folder: folder,
          onProgress: onSendProgress,
        );
        
        if (!response.success) {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            error: ApiError(
              code: response.error!.code,
              message: response.error!.message,
            ),
          );
        }
        
        photoUrl = response.secureUrl;
      }
      
      // Send URLs to backend
      final response = await _apiService.userDio.post(
        '/kyc/liveness/submit',
        data: {
          'session_id': sessionId,
          'storage_provider': 'cloudinary',
          if (videoUrl != null) 'video_url': videoUrl,
          if (photoUrl != null) 'photo_url': photoUrl,
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

  // Upload KYC images (ID front, back, liveness) with progress tracking
  Future<ApiResponse<Map<String, dynamic>>> uploadKYCImages({
    required String idFrontPath,
    String? idBackPath,
    required String livenessImagePath,
    required String idType,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final cloudinaryService = Get.find<CloudinaryService>();
      final authService = Get.find<AuthService>();
      final userId = authService.currentUser.value?.id ?? 'unknown';
      
      // Upload ID front image
      final idFrontFolder = '${cloudinaryService.generateKycFolder(userId, 'id_card')}/front';
      final frontResponse = await cloudinaryService.uploadImage(
        filePath: idFrontPath,
        folder: idFrontFolder,
        metadata: {'type': 'id_front', 'id_type': idType},
        onProgress: onSendProgress,
      );
      
      if (!frontResponse.success) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          error: ApiError(
            code: frontResponse.error!.code,
            message: 'Failed to upload ID front: ${frontResponse.error!.message}',
          ),
        );
      }
      
      // Upload ID back image (if provided)
      String? idBackUrl;
      if (idBackPath != null && idBackPath.isNotEmpty) {
        final idBackFolder = '${cloudinaryService.generateKycFolder(userId, 'id_card')}/back';
        final backResponse = await cloudinaryService.uploadImage(
          filePath: idBackPath,
          folder: idBackFolder,
          metadata: {'type': 'id_back', 'id_type': idType},
          onProgress: onSendProgress,
        );
        
        if (!backResponse.success) {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            error: ApiError(
              code: backResponse.error!.code,
              message: 'Failed to upload ID back: ${backResponse.error!.message}',
            ),
          );
        }
        
        idBackUrl = backResponse.secureUrl;
      }
      
      // Upload liveness image
      final livenessFolder = cloudinaryService.generateLivenessPhotoFolder(userId);
      final livenessResponse = await cloudinaryService.uploadImage(
        filePath: livenessImagePath,
        folder: livenessFolder,
        metadata: {'type': 'liveness'},
        onProgress: onSendProgress,
      );
      
      if (!livenessResponse.success) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          error: ApiError(
            code: livenessResponse.error!.code,
            message: 'Failed to upload liveness image: ${livenessResponse.error!.message}',
          ),
        );
      }
      
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        data: {
          'id_front_url': frontResponse.secureUrl,
          if (idBackUrl != null) 'id_back_url': idBackUrl,
          'liveness_url': livenessResponse.secureUrl,
        },
        message: 'All images uploaded successfully',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: ApiError(
          code: 'UPLOAD_ERROR',
          message: 'Failed to upload KYC images: $e',
        ),
      );
    }
  }

  // Submit KYC verification with image URLs and metadata
  Future<ApiResponse<Map<String, dynamic>>> submitKYCVerification({
    required String idFrontUrl,
    String? idBackUrl,
    required String livenessUrl,
    required String idType,
    required String challengeType,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final response = await _apiService.userDio.post(
        '/kyc/verification/submit',
        data: {
          'id_front_url': idFrontUrl,
          if (idBackUrl != null) 'id_back_url': idBackUrl,
          'liveness_url': livenessUrl,
          'id_type': idType,
          'challenge_type': challengeType,
          'timestamp': DateTime.now().toIso8601String(),
          'storage_provider': 'cloudinary',
          if (additionalMetadata != null) ...additionalMetadata,
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
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: ApiError(
          code: 'SUBMIT_ERROR',
          message: 'Failed to submit KYC verification: $e',
        ),
      );
    }
  }
}
