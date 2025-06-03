// models/user_model.dart
enum UserRole {
  patient,
  nutritionist,
}

class User {
  final int? id;
  final String email;
  final String password;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt(),
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.patient,
      ),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? password,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

