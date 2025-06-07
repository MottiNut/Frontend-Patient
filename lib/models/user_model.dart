// lib/models/user_models.dart
class UserCreate {
  final String email;
  final String password;
  final String role; // 'patient' o 'nutritionist'
  final String firstName;
  final String lastName;
  final String birthDate;
  final String phone;
  final double? height;
  final double? weight;
  final int hasMedicalCondition;
  final String? chronicDisease;
  final String? allergies;
  final String? dietaryPreferences;

  UserCreate({
    required this.email,
    required this.password,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.phone,
    this.height,
    this.weight,
    this.hasMedicalCondition = 0,
    this.chronicDisease,
    this.allergies,
    this.dietaryPreferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate,
      'phone': phone,
      'height': height,
      'weight': weight,
      'has_medical_condition': hasMedicalCondition,
      'chronic_disease': chronicDisease,
      'allergies': allergies,
      'dietary_preferences': dietaryPreferences,
    };
  }
}

class UserLogin {
  final String email;
  final String password;

  UserLogin({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class UserResponse {
  final int userId;
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final String birthDate;
  final String phone;
  final double? height;
  final double? weight;
  final int hasMedicalCondition;
  final String? chronicDisease;
  final String? allergies;
  final String? dietaryPreferences;
  final String createdAt;

  UserResponse({
    required this.userId,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.phone,
    this.height,
    this.weight,
    required this.hasMedicalCondition,
    this.chronicDisease,
    this.allergies,
    this.dietaryPreferences,
    required this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      userId: json['user_id'],
      email: json['email'],
      role: json['role'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      birthDate: json['birth_date'],
      phone: json['phone'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      hasMedicalCondition: json['has_medical_condition'],
      chronicDisease: json['chronic_disease'],
      allergies: json['allergies'],
      dietaryPreferences: json['dietary_preferences'],
      createdAt: json['created_at'],
    );
  }
}