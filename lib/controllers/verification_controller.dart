// Purpose: Verification controller for KYC document upload
// Author: haptome H.
// Linked Spec Section: FR02-FR03

import 'package:et_digital_equb/core/services/kyc_service.dart';
import 'package:et_digital_equb/core/services/permission_service.dart';
import 'package:et_digital_equb/models/kyc_models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../features/profile/id_card_camera_view.dart';
import '../features/profile/liveness_video_view.dart';
import 'package:get/get.dart';
import 'dart:io';

// Failed upload model for retry functionality
class FailedUpload {
  final String filePath;
  final UploadType type;
  final DocumentType? docType;
  final String errorMessage;
  final DateTime failedAt;

  FailedUpload({
    required this.filePath,
    required this.type,
    this.docType,
    required this.errorMessage,
    DateTime? failedAt,
  }) : failedAt = failedAt ?? DateTime.now();
}

enum UploadType { verification, document, liveness }

class VerificationController extends GetxController {
  final KycService _kycService = KycService.to;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<KycDocument> uploadedDocuments = <KycDocument>[].obs;

  // Upload progress tracking
  final RxDouble uploadProgress = 0.0.obs;
  final RxBool isUploading = false.obs;
  final Rxn<String> currentUploadingFile = Rxn<String>();

  // Failed uploads for retry
  final RxList<FailedUpload> failedUploads = <FailedUpload>[].obs;

  // KYC Status tracking
  final Rxn<KycStatus> kycStatus = Rxn<KycStatus>();
  final RxBool isCheckingKycStatus = false.obs;

  final _selectedVerificationMethod = ''.obs;
  final _verificationFile = Rxn<PlatformFile?>();
  final _uploadedFile = Rxn<PlatformFile?>();
  final _verificationDocument = Rxn<KycDocument?>();
  final _uploadedDocument = Rxn<KycDocument?>();

  String? get selectedVerificationMethod =>
      _selectedVerificationMethod.value.isNotEmpty
      ? _selectedVerificationMethod.value
      : null;
  PlatformFile? get verificationFile => _verificationFile.value;
  PlatformFile? get uploadedFile => _uploadedFile.value;
  KycDocument? get verificationDocument => _verificationDocument.value;
  KycDocument? get uploadedDocument => _uploadedDocument.value;

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
    checkKycStatus();
  }

  Future<void> loadDocuments() async {
    try {
      isLoading.value = true;
      final response = await _kycService.getDocuments();
      if (response.success && response.data != null) {
        uploadedDocuments.value = response.data!;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load documents: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void setVerificationMethod(String method) {
    _selectedVerificationMethod.value = method;
    update();
  }

  DocumentType? _getDocumentTypeFromMethod(String method) {
    switch (method.toLowerCase()) {
      case 'national id':
        return DocumentType.nationalId;
      case 'kebele id':
        return DocumentType.nationalId; // Kebele ID is treated as national ID
      case 'passport':
        return DocumentType.passport;
      case 'selfie':
        return DocumentType
            .nationalId; // Selfie is part of national ID verification
      default:
        return null;
    }
  }

  Future<void> uploadVerificationFile(String filePath) async {
    if (_selectedVerificationMethod.value.isEmpty) {
      errorMessage.value = 'Please select a verification method first';
      Get.snackbar('Error', errorMessage.value);
      return;
    }

    final docType = _getDocumentTypeFromMethod(
      _selectedVerificationMethod.value,
    );
    print('Selected Verification Method: ${_selectedVerificationMethod.value}');
    print('Selected Document Type: $docType');
    if (docType == null) {
      errorMessage.value = 'Invalid verification method';
      Get.snackbar('Error', errorMessage.value);
      return;
    }

    if (filePath.isEmpty) {
      errorMessage.value = 'Invalid file path';
      Get.snackbar('Error', errorMessage.value);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate file extension
      final fileExtension = _getFileExtension(filePath);
      final supportedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
      if (!supportedExtensions.contains(fileExtension)) {
        throw Exception(
          'Unsupported file format. Please select an image (JPG, PNG) or PDF file. Detected extension: .$fileExtension',
        );
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found at path: $filePath');
      }

      // Check if file is readable
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('File is empty');
      }

      // Limit file size to 5MB (same as backend)
      const maxSize = 5 * 1024 * 1024; // 5MB
      if (fileSize > maxSize) {
        throw Exception('File size too large. Maximum allowed size is 5MB.');
      }

      // Reset progress
      uploadProgress.value = 0.0;
      isUploading.value = true;
      currentUploadingFile.value = filePath;

      final response = await _kycService.uploadDocument(
        filePath: filePath,
        docType: docType,
        metadata: {
          'verification_method': _selectedVerificationMethod.value,
          'uploaded_at': DateTime.now().toIso8601String(),
        },
        onSendProgress: (sent, total) {
          uploadProgress.value = sent / total;
        },
      );

      if (response.success && response.data != null) {
        _verificationDocument.value = response.data;
        _verificationFile.value = PlatformFile(
          path: filePath,
          name: file.path.split('/').last,
          size: await file.length(),
        );
        uploadedDocuments.add(response.data!);
        uploadProgress.value = 1.0;
        Get.snackbar('Success', 'Verification document uploaded successfully');
      } else {
        errorMessage.value =
            response.error?.message ??
            response.message ??
            'Failed to upload document';
        // Add to failed uploads for retry
        failedUploads.add(
          FailedUpload(
            filePath: filePath,
            type: UploadType.verification,
            docType: docType,
            errorMessage: errorMessage.value,
          ),
        );
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Error uploading file: $e';
      // Add to failed uploads for retry
      failedUploads.add(
        FailedUpload(
          filePath: filePath,
          type: UploadType.verification,
          docType: docType,
          errorMessage: errorMessage.value,
        ),
      );
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
      isUploading.value = false;
      currentUploadingFile.value = null;
      uploadProgress.value = 0.0;
      update();
    }
  }

  Future<void> uploadDocumentFile(
    String filePath, {
    DocumentType? docType,
  }) async {
    if (filePath.isEmpty) {
      errorMessage.value = 'Invalid file path';
      Get.snackbar('Error', errorMessage.value);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('Selected filePath: ${filePath}');
      // Validate file extension
      final fileExtension = _getFileExtension(filePath);
      final supportedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
      if (!supportedExtensions.contains(fileExtension)) {
        throw Exception(
          'Unsupported file format. Please select an image (JPG, PNG) or PDF file. Detected extension: .$fileExtension',
        );
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found at path: $filePath');
      }

      // Check if file is readable
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('File is empty');
      }

      // Limit file size to 5MB (same as backend)
      const maxSize = 5 * 1024 * 1024; // 5MB
      if (fileSize > maxSize) {
        throw Exception('File size too large. Maximum allowed size is 5MB.');
      }

      // Use provided docType or default to utility_bill for additional documents
      final documentType = docType ?? DocumentType.utilityBill;

      // Reset progress
      uploadProgress.value = 0.0;
      isUploading.value = true;
      currentUploadingFile.value = filePath;

      final response = await _kycService.uploadDocument(
        filePath: filePath,
        docType: documentType,
        metadata: {'uploaded_at': DateTime.now().toIso8601String()},
        onSendProgress: (sent, total) {
          uploadProgress.value = sent / total;
        },
      );

      if (response.success && response.data != null) {
        _uploadedDocument.value = response.data;
        _uploadedFile.value = PlatformFile(
          path: filePath,
          name: file.path.split('/').last,
          size: await file.length(),
        );
        uploadedDocuments.add(response.data!);
        uploadProgress.value = 1.0;
        Get.snackbar('Success', 'Document uploaded successfully');
      } else {
        errorMessage.value =
            response.error?.message ??
            response.message ??
            'Failed to upload document';
        // Add to failed uploads for retry
        failedUploads.add(
          FailedUpload(
            filePath: filePath,
            type: UploadType.document,
            docType: documentType,
            errorMessage: errorMessage.value,
          ),
        );
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Error uploading file: $e';
      // Add to failed uploads for retry
      final documentType = docType ?? DocumentType.utilityBill;
      failedUploads.add(
        FailedUpload(
          filePath: filePath,
          type: UploadType.document,
          docType: documentType,
          errorMessage: errorMessage.value,
        ),
      );
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
      isUploading.value = false;
      currentUploadingFile.value = null;
      uploadProgress.value = 0.0;
      update();
    }
  }

  // Helper method to validate file extension
  bool isValidFileExtension(String filePath) {
    final fileExtension = _getFileExtension(filePath);
    final supportedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
    return supportedExtensions.contains(fileExtension);
  }

  // Extract file extension properly
  String _getFileExtension(String filePath) {
    final lastDotIndex = filePath.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return filePath.substring(lastDotIndex + 1).toLowerCase();
  }

  Future<void> submitDocuments() async {
    if (uploadedDocuments.isEmpty) {
      Get.snackbar('Error', 'Please upload at least one document');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final documentIds = uploadedDocuments.map((doc) => doc.id).toList();
      final response = await _kycService.submitDocuments(
        documentIds: documentIds,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Documents submitted for review. You will be notified once the review is complete.',
        );
        // Reload documents to get updated status
        await loadDocuments();
        // Navigate back or to a success screen
        Get.back();
        Get.back();
      } else {
        errorMessage.value =
            response.error?.message ?? 'Failed to submit documents';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Error submitting documents: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void removeVerificationFile() {
    final doc = _verificationDocument.value;
    if (doc != null) {
      uploadedDocuments.remove(doc);
    }
    _verificationDocument.value = null;
    _verificationFile.value = null;
    _selectedVerificationMethod.value = '';
    update();
  }

  void removeUploadedFile() {
    final doc = _uploadedDocument.value;
    if (doc != null) {
      uploadedDocuments.remove(doc);
    }
    _uploadedDocument.value = null;
    _uploadedFile.value = null;
    update();
  }

  // Liveness check methods
  final _livenessSessionId = Rxn<String>();
  final _livenessVideoPath = Rxn<String>();
  final _livenessCompleted = false.obs;

  String? get livenessSessionId => _livenessSessionId.value;
  String? get livenessVideoPath => _livenessVideoPath.value;
  bool get livenessCompleted => _livenessCompleted.value;

  Future<void> initiateLivenessCheck() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _kycService.initiateLiveness();

      if (response.success && response.data != null) {
        final sessionId = response.data!['session_id'] as String?;
        if (sessionId != null) {
          _livenessSessionId.value = sessionId;
          Get.snackbar('Success', 'Liveness check session started');
        } else {
          errorMessage.value = 'Invalid session ID received';
          Get.snackbar('Error', errorMessage.value);
        }
      } else {
        errorMessage.value =
            response.error?.message ?? 'Failed to initiate liveness check';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Error initiating liveness check: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> submitLivenessVideo(String videoPath) async {
    final sessionId = _livenessSessionId.value;
    if (sessionId == null) {
      errorMessage.value = 'Please initiate liveness check first';
      Get.snackbar('Error', errorMessage.value);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _kycService.submitLiveness(
        sessionId: sessionId,
        videoPath: videoPath,
      );

      if (response.success && response.data != null) {
        final status = response.data!['status'] as String?;
        _livenessVideoPath.value = videoPath;
        _livenessCompleted.value = status == 'passed';
        uploadProgress.value = 1.0;

        if (_livenessCompleted.value) {
          Get.snackbar('Success', 'Liveness check passed!');
        } else {
          Get.snackbar('Warning', 'Liveness check failed. Please try again.');
        }
      } else {
        errorMessage.value =
            response.error?.message ?? 'Failed to submit liveness video';
        // Add to failed uploads for retry
        failedUploads.add(
          FailedUpload(
            filePath: videoPath,
            type: UploadType.liveness,
            errorMessage: errorMessage.value,
          ),
        );
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Error submitting liveness video: $e';
      // Add to failed uploads for retry
      failedUploads.add(
        FailedUpload(
          filePath: videoPath,
          type: UploadType.liveness,
          errorMessage: errorMessage.value,
        ),
      );
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
      isUploading.value = false;
      currentUploadingFile.value = null;
      uploadProgress.value = 0.0;
      update();
    }
  }

  void resetLiveness() {
    _livenessSessionId.value = null;
    _livenessVideoPath.value = null;
    _livenessCompleted.value = false;
    update();
  }

  // Retry failed upload
  Future<void> retryUpload(FailedUpload failedUpload) async {
    failedUploads.remove(failedUpload);

    if (failedUpload.type == UploadType.verification) {
      await uploadVerificationFile(failedUpload.filePath);
    } else if (failedUpload.type == UploadType.document) {
      await uploadDocumentFile(
        failedUpload.filePath,
        docType: failedUpload.docType,
      );
    } else if (failedUpload.type == UploadType.liveness) {
      final sessionId = _livenessSessionId.value;
      if (sessionId != null && failedUpload.filePath.isNotEmpty) {
        await submitLivenessVideo(failedUpload.filePath);
      }
    }
  }

  // Clear failed uploads
  void clearFailedUploads() {
    failedUploads.clear();
  }

  /// Request necessary permissions before file operations
  Future<bool> requestStoragePermissions() async {
    // Permissions removed: always allow storage operations.
    return true;
  }

  /// Request specific permission type
  Future<bool> requestSpecificPermission(PermissionType type) async {
    // Permissions removed — always allow requested permission.
    return true;
  }

  /// Check specific permission status
  Future<bool> checkSpecificPermission(PermissionType type) async {
    // Permissions removed — always report granted status.
    return true;
  }

  /// Check KYC status from the API
  Future<void> checkKycStatus() async {
    try {
      isCheckingKycStatus.value = true;
      final response = await _kycService.getKycStatus();
      if (response.success && response.data != null) {
        kycStatus.value = response.data;
        update();
      }
    } catch (e) {
      print('Error checking KYC status: $e');
    } finally {
      isCheckingKycStatus.value = false;
    }
  }

  /// Check if user is in draft or pending status
  bool get isDraftOrPending {
    if (kycStatus.value == null) return false;
    final status = kycStatus.value!.status.toLowerCase();
    return status == 'draft' || status == 'pending';
  }

  /// Check if user is approved
  bool get isApproved {
    if (kycStatus.value == null) return false;
    final status = kycStatus.value!.status.toLowerCase();
    return status == 'approved' || status == 'verified';
  }

  /// Check if permissions are already granted
  Future<bool> checkPermissions() async {
    try {
      // Ensure PermissionService is available
      PermissionService permissionService;
      if (Get.isRegistered<PermissionService>()) {
        permissionService = Get.find<PermissionService>();
      } else {
        // If not registered, try to get it via the 'to' pattern which may trigger lazy loading
        permissionService = PermissionService.to;
      }
      return await permissionService.hasRequiredKycPermissions();
    } catch (e) {
      print('Error getting permission service: $e');
      // If there's an error, try to register and get it again
      if (!Get.isRegistered<PermissionService>()) {
        Get.put(PermissionService(), permanent: true);
      }
      final permissionService = PermissionService.to;
      return await permissionService.hasRequiredKycPermissions();
    }
  }

  /// Intent-based helper: capture ID photo via camera flow
  Future<void> captureIdPhoto() async {
    // Permissions removed — directly open camera view.
    final result = await Get.to<Map<String, dynamic>>(
      () => IdCardCameraView(
        verificationMethod: _selectedVerificationMethod.value,
      ),
    );

    if (result != null && result['imagePath'] != null) {
      await uploadVerificationFile(result['imagePath']);
    }
  }

  /// Intent-based helper: pick ID/image from gallery
  Future<void> pickIdFromGallery() async {
    // Permissions removed — open gallery picker directly.
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await uploadVerificationFile(image.path);
    }
  }

  /// Intent-based helper: record liveness video
  Future<void> recordLivenessVideo() async {
    // Permissions removed — open liveness view directly.
    final result = await Get.to<Map<String, dynamic>>(
      () => const LivenessVideoView(),
    );

    if (result != null && result['videoPath'] != null) {
      await submitLivenessVideo(result['videoPath']);
    }
  }

  /// Intent-based helper: pick a document (PDF / image)
  Future<void> pickDocument() async {
    // Permissions removed — open file picker directly.
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        await uploadDocumentFile(path);
      }
    }
  }
}
