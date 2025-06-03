// models/patient_model.dart
import 'package:frontendpatient/models/user_model.dart';

class Patient {
  final User user;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String? phone;
  final double? height;
  final double? weight;
  final String? medicalConditions;
  final String? allergies;
  final String? dietaryPreferences;

  Patient({
    required this.user,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.phone,
    this.height,
    this.weight,
    this.medicalConditions,
    this.allergies,
    this.dietaryPreferences,
  });

  // Getters para acceder fácilmente a propiedades del usuario
  int? get id => user.id;
  String get email => user.email;
  String get password => user.password;
  UserRole get role => user.role;
  DateTime get createdAt => user.createdAt;
  DateTime? get updatedAt => user.updatedAt;

  String get fullName => '$firstName $lastName';

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toMap() {
    final userMap = user.toMap();
    userMap.addAll({
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate?.toIso8601String(),
      'phone': phone,
      'height': height,
      'weight': weight,
      'medical_conditions': medicalConditions,
      'allergies': allergies,
      'dietary_preferences': dietaryPreferences,
    });
    return userMap;
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    final user = User.fromMap(map);
    return Patient(
      user: user,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      birthDate: map['birth_date'] != null
          ? DateTime.parse(map['birth_date'])
          : null,
      phone: map['phone'],
      height: map['height']?.toDouble(),
      weight: map['weight']?.toDouble(),
      medicalConditions: map['medical_conditions'],
      allergies: map['allergies'],
      dietaryPreferences: map['dietary_preferences'],
    );
  }

  // Constructor de conveniencia
  factory Patient.create({
    int? id,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    DateTime? birthDate,
    String? phone,
    double? height,
    double? weight,
    String? medicalConditions,
    String? allergies,
    String? dietaryPreferences,
  }) {
    final user = User(
      id: id,
      email: email,
      password: password,
      role: UserRole.patient,
      createdAt: DateTime.now(),
    );

    return Patient(
      user: user,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      phone: phone,
      height: height,
      weight: weight,
      medicalConditions: medicalConditions,
      allergies: allergies,
      dietaryPreferences: dietaryPreferences,
    );
  }

  Patient copyWith({
    User? user,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? phone,
    double? height,
    double? weight,
    String? medicalConditions,
    String? allergies,
    String? dietaryPreferences,
  }) {
    return Patient(
      user: user ?? this.user,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
    );
  }

  // Método para actualizar tanto datos de usuario como de paciente
  Patient copyWithAll({
    int? id,
    String? email,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? phone,
    double? height,
    double? weight,
    String? medicalConditions,
    String? allergies,
    String? dietaryPreferences,
  }) {
    final updatedUser = user.copyWith(
      id: id,
      email: email,
      password: password,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    return Patient(
      user: updatedUser,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
    );
  }
}