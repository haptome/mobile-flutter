// Purpose: Login request model
// Author: Auto-generated

class LoginRequest {
  final String phone;
  final String? password;
  final String? otp;
  final String? fcmToken;
  final String? deviceId;
  final String? deviceType;

  LoginRequest({
    required this.phone,
    this.password,
    this.otp,
    this.fcmToken,
    this.deviceId,
    this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      if (password != null) 'password': password,
      if (otp != null) 'otp': otp,
      if (fcmToken != null) 'fcm_token': fcmToken,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceType != null) 'device_type': deviceType,
    };
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      phone: json['phone'] as String,
      password: json['password'] as String?,
      otp: json['otp'] as String?,
      fcmToken: json['fcm_token'] as String?,
      deviceId: json['device_id'] as String?,
      deviceType: json['device_type'] as String?,
    );
  }
}

