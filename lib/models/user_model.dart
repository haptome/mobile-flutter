// Purpose: User model for ET Digital Ekub
// Author: haptome H.
// Linked Spec Section: FR01-FR03

class UserModel {
  final String id;
  final String phone;
  final String? email;
  final String? fullName;
  final String? workStatus;
  final String? profilePicUrl;
  final int trustScore;
  final String kycStatus;
  final bool isActive;
  final List<String> roles;
  final DateTime createdAt;
  final bool hasPassword;

  UserModel({
    required this.id,
    required this.phone,
    this.email,
    this.fullName,
    this.workStatus,
    this.profilePicUrl,
    required this.trustScore,
    required this.kycStatus,
    required this.isActive,
    required this.roles,
    required this.createdAt,
    required this.hasPassword,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      workStatus: json['work_status'] as String?,
      profilePicUrl: json['profile_pic_url'] as String?,
      trustScore: json['trust_score'] as int,
      kycStatus: json['kyc_status'] as String,
      isActive: json['is_active'] as bool,
      roles: List<String>.from(json['roles'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      hasPassword: json['has_password'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'full_name': fullName,
      'work_status': workStatus,
      'profile_pic_url': profilePicUrl,
      'trust_score': trustScore,
      'kyc_status': kycStatus,
      'is_active': isActive,
      'roles': roles,
      'created_at': createdAt.toIso8601String(),
      'has_password': hasPassword,
    };
  }
}
