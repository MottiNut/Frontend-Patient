class AuthResponse {
  final String token;
  final int userId;
  final String email;
  final String role;
  final String fullName;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.role,
    required this.fullName,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      userId: json['userId'],
      email: json['email'],
      role: json['role'],
      fullName: json['fullName'],
    );
  }
}