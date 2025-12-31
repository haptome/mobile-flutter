// Purpose: Registration request model for user signup
// Author: Auto-generated
// Linked Spec Section: FR01

class RegisterRequest {
  final String phone;
  final String? fullName; // Optional for mobile users
  final String? password; // Optional - mobile users use OTP only
  final String? workStatus; // Optional
  final String? fcmToken;
  final String? deviceId;
  final String? deviceType;

  RegisterRequest({
    required this.phone,
    this.fullName,
    this.password, // Not required for mobile - OTP only
    this.workStatus,
    this.fcmToken,
    this.deviceId,
    this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      if (fullName != null && fullName!.isNotEmpty) 'full_name': fullName,
      if (password != null && password!.isNotEmpty) 'password': password,
      if (workStatus != null && workStatus!.isNotEmpty)
        'work_status': workStatus,
      if (fcmToken != null) 'fcm_token': fcmToken,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceType != null) 'device_type': deviceType,
    };
  }

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      phone: json['phone'] as String,
      fullName: json['full_name'] as String?,
      password: json['password'] as String?,
      workStatus: json['work_status'] as String?,
      fcmToken: json['fcm_token'] as String?,
      deviceId: json['device_id'] as String?,
      deviceType: json['device_type'] as String?,
    );
  }
}
