// Purpose: Verification controller for KYC document upload
// Author: haptome H.
// Linked Spec Section: FR02-FR03

import 'package:et_digital_equb/core/services/kyc_service.dart';
import 'package:et_digital_equb/models/kyc_models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'dart:io';

class VerificationController extends GetxController {
  final KycService _kycService = KycService.to;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<KycDocument> uploadedDocuments = <KycDocument>[].obs;
  
  String? _selectedVerificationMethod;
  PlatformFile? _verificationFile;
  PlatformFile? _uploadedFile;
  KycDocument? _verificationDocument;
  KycDocument? _uploadedDocument;

  String? get selectedVerificationMethod => _selectedVerificationMethod;
  PlatformFile? get verificationFile => _verificationFile;
  PlatformFile? get uploadedFile => _uploadedFile;
  KycDocument? get verificationDocument => _verificationDocument;
  KycDocument? get uploadedDocument => _uploadedDocument;

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
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
    _selectedVerificationMethod = method;
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
        return DocumentType.nationalId; // Selfie is part of national ID verification
      default:
        return null;
    }
  }

  Future<void> uploadVerificationFile(String filePath) async {
    if (_selectedVerificationMethod == null) {
      errorMessage.value = 'Please select a verification method first';
      Get.snackbar('Error', errorMessage.value);
      return;
    }

    final docType = _getDocumentTypeFromMethod(_selectedVerificationMethod!);
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

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found at path: $filePath');
      }

      // Check if file is readable
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('File is empty');
      }

      final response = await _kycService.uploadDocument(
        filePath: filePath,
        docType: docType,
        metadata: {
          'verification_method': _selectedVerificationMethod,
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      );

      if (response.success && response.data != null) {
        _verificationDocument = response.data;
        _verificationFile = PlatformFile(
          path: filePath,
          name: file.path.split('/').last,
          size: await file.length(),
        );
        uploadedDocuments.add(response.data!);
        Get.snackbar('Success', 'Verification document uploaded successfully');
      } else {
        errorMessage.value = response.error?.message ?? 'Failed to upload document';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Error uploading file: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> uploadDocumentFile(String filePath) async {
    if (filePath.isEmpty) {
      errorMessage.value = 'Invalid file path';
      Get.snackbar('Error', errorMessage.value);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found at path: $filePath');
      }

      // Check if file is readable
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('File is empty');
      }

      // Default to utility_bill for additional documents
      final response = await _kycService.uploadDocument(
        filePath: filePath,
        docType: DocumentType.utilityBill,
        metadata: {
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      );

      if (response.success && response.data != null) {
        _uploadedDocument = response.data;
        _uploadedFile = PlatformFile(
          path: filePath,
          name: file.path.split('/').last,
          size: await file.length(),
        );
        uploadedDocuments.add(response.data!);
        Get.snackbar('Success', 'Document uploaded successfully');
      } else {
        errorMessage.value = response.error?.message ?? 'Failed to upload document';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Error uploading file: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
      update();
    }
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
      } else {
        errorMessage.value = response.error?.message ?? 'Failed to submit documents';
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
    if (_verificationDocument != null) {
      uploadedDocuments.remove(_verificationDocument);
      _verificationDocument = null;
    }
    _verificationFile = null;
    _selectedVerificationMethod = null;
    update();
  }

  void removeUploadedFile() {
    if (_uploadedDocument != null) {
      uploadedDocuments.remove(_uploadedDocument);
      _uploadedDocument = null;
    }
    _uploadedFile = null;
    update();
  }
}

