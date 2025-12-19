// Purpose: Registration request model for user signup
// Author: Auto-generated
// Linked Spec Section: FR01

class RegisterRequest {
  final String phone;
  final String fullName;
  final String password;
  final String workStatus;
  final String? fcmToken;
  final String? deviceId;
  final String? deviceType;

  RegisterRequest({
    required this.phone,
    required this.fullName,
    required this.password,
    required this.workStatus,
    this.fcmToken,
    this.deviceId,
    this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'full_name': fullName,
      'password': password,
      'work_status': workStatus,
      if (fcmToken != null) 'fcm_token': fcmToken,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceType != null) 'device_type': deviceType,
    };
  }

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      phone: json['phone'] as String,
      fullName: json['full_name'] as String,
      password: json['password'] as String,
      workStatus: json['work_status'] as String,
      fcmToken: json['fcm_token'] as String?,
      deviceId: json['device_id'] as String?,
      deviceType: json['device_type'] as String?,
    );
  }
}

