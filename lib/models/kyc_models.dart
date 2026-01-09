// Purpose: KYC models for document upload and submission
// Author: haptome H.
// Linked Spec Section: FR02-FR03

enum DocumentType {
  nationalId('national_id'),
  passport('passport'),
  driversLicense('drivers_license'),
  utilityBill('utility_bill'),
  bankStatement('bank_statement');

  final String value;
  const DocumentType(this.value);

  static DocumentType? fromString(String? value) {
    if (value == null) return null;
    return DocumentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DocumentType.nationalId,
    );
  }
}

class UploadDocumentRequest {
  final DocumentType docType;
  final Map<String, dynamic>? metadata;

  UploadDocumentRequest({
    required this.docType,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'doc_type': docType.value,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class SubmitKycRequest {
  final List<String> documentIds;

  SubmitKycRequest({
    required this.documentIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'document_ids': documentIds,
    };
  }
}

class KycDocument {
  final String id;
  final String docType;
  final String fileName;
  final String? fileUrl;
  final String status;
  final DateTime? uploadedAt;
  final Map<String, dynamic>? metadata;

  KycDocument({
    required this.id,
    required this.docType,
    required this.fileName,
    this.fileUrl,
    required this.status,
    this.uploadedAt,
    this.metadata,
  });

  factory KycDocument.fromJson(Map<String, dynamic> json) {
    // Backend returns created_at, not uploaded_at
    // Also handle uploaded_at for backward compatibility
    final uploadedAtStr = json['uploaded_at'] as String? ??
        json['created_at'] as String?;
    
    return KycDocument(
      id: json['id'] as String? ?? json['document_id'] as String? ?? '',
      docType: json['doc_type'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      fileUrl: json['file_url'] as String?,
      status: json['status'] as String? ?? 'uploaded',
      uploadedAt: uploadedAtStr != null
          ? DateTime.parse(uploadedAtStr)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class KycStatus {
  final String status;
  final List<KycDocument> documents;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  KycStatus({
    required this.status,
    required this.documents,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
  });

  factory KycStatus.fromJson(Map<String, dynamic> json) {
    return KycStatus(
      status: json['status'] as String,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((doc) => KycDocument.fromJson(doc as Map<String, dynamic>))
              .toList() ??
          [],
      rejectionReason: json['rejection_reason'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  bool get isVerified => status == 'verified';
  bool get isPending => status == 'pending' || status == 'submitted';
  bool get isRejected => status == 'rejected';
}

