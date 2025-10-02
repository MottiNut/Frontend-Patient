class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final String? userId;
  final String? email;
  final Map<String, dynamic>? user;
  final VerificationStatus1? verificationStatus;

  AuthResponse({
    required this.success,
    this.message,
    this.token,
    this.userId,
    this.email,
    this.user,
    this.verificationStatus,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final bool isSuccess = json['success'] ?? (json['token'] != null);

    Map<String, dynamic>? userData;
    if (json['user'] != null) {
      userData = Map<String, dynamic>.from(json['user']);
    } else if (json['token'] != null) {
      userData = {
        'userId': json['userId'],
        'email': json['email'],
        'role': json['role'],
        'fullName': json['fullName'],
        'emailVerified': json['emailVerified'] ?? false,
        'phoneVerified': json['phoneVerified'] ?? false,
        'fullyVerified': json['fullyVerified'] ?? false,
        'requiresVerification': json['requiresVerification'] ?? false,
      };
    }

    return AuthResponse(
      success: isSuccess,
      message: json['message'],
      token: json['token'],
      userId: json['userId']?.toString(),
      email: json['email'],
      user: userData,
      verificationStatus: json['verificationStatus'] != null
          ? VerificationStatus1.fromMap(
          Map<String, dynamic>.from(json['verificationStatus']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'userId': userId,
      'email': email,
      'user': user,
      'verificationStatus': verificationStatus == null ? null : {
        'emailVerified': verificationStatus!.emailVerified,
        'phoneVerified': verificationStatus!.phoneVerified,
        'fullyVerified': verificationStatus!.fullyVerified,
        'requiresVerification': verificationStatus!.requiresVerification,
      },
    };
  }

}

class VerificationStatus1 {
  final bool emailVerified;
  final bool phoneVerified;
  final bool fullyVerified;
  final bool requiresVerification;

  VerificationStatus1({
    required this.emailVerified,
    required this.phoneVerified,
    required this.fullyVerified,
    required this.requiresVerification,
  });

  factory VerificationStatus1.fromMap(Map<String, dynamic> map) {
    return VerificationStatus1(
      emailVerified: map['emailVerified'] ?? false,
      phoneVerified: map['phoneVerified'] ?? false,
      fullyVerified: map['fullyVerified'] ?? false,
      requiresVerification: map['requiresVerification'] ?? false,
    );
  }
}