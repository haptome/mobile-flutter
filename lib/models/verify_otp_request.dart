// Purpose: Verify OTP request model
// Author: Auto-generated

class VerifyOtpRequest {
  final String phone;
  final String otp;
  final String? fcmToken;
  final String? deviceId;
  final String? deviceType;

  VerifyOtpRequest({
    required this.phone,
    required this.otp,
    this.fcmToken,
    this.deviceId,
    this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
      if (fcmToken != null) 'fcm_token': fcmToken,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceType != null) 'device_type': deviceType,
    };
  }

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) {
    return VerifyOtpRequest(
      phone: json['phone'] as String,
      otp: json['otp'] as String,
      fcmToken: json['fcm_token'] as String?,
      deviceId: json['device_id'] as String?,
      deviceType: json['device_type'] as String?,
    );
  }
}

