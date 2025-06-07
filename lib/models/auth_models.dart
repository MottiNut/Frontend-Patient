// lib/models/auth_models.dart
class AuthResponse {
  final String token;
  final int userId;
  final String role;
  final String? name;
  final String? message;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.role,
    this.name,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      userId: json['user_id'],
      role: json['role'],
      name: json['name'],
      message: json['message'],
    );
  }
}