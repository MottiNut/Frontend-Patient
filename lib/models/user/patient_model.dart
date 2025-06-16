import 'package:frontendpatient/models/user/role.dart';
import 'package:frontendpatient/models/user/user_model.dart';

class Patient extends User {
  final double? height;
  final double? weight;
  final bool hasMedicalCondition;
  final String? chronicDisease;
  final String? allergies;
  final String? dietaryPreferences;
  final String? emergencyContact;
  final String? gender;

  Patient({
    required super.userId,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.birthDate,
    super.phone,
    required super.createdAt,
    this.height,
    this.weight,
    this.hasMedicalCondition = false,
    this.chronicDisease,
    this.allergies,
    this.dietaryPreferences,
    this.emergencyContact,
    this.gender,
  }) : super(role: Role.patient);

  double? calculateBMI() {
    if (height == null || weight == null || height! <= 0) {
      return null;
    }
    return weight! / ((height! / 100) * (height! / 100));
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      userId: json['userId'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      phone: json['phone'],
      createdAt: DateTime.parse(json['createdAt']),
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      hasMedicalCondition: json['hasMedicalCondition'] ?? false,
      chronicDisease: json['chronicDisease'],
      allergies: json['allergies'],
      dietaryPreferences: json['dietaryPreferences'],
      emergencyContact: json['emergencyContact'],
      gender: json['gender'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate?.toIso8601String(),
      'phone': phone,
      'role': role.value,
      'createdAt': createdAt.toIso8601String(),
      'height': height,
      'weight': weight,
      'hasMedicalCondition': hasMedicalCondition,
      'chronicDisease': chronicDisease,
      'allergies': allergies,
      'dietaryPreferences': dietaryPreferences,
      'emergencyContact': emergencyContact,
      'gender': gender,
    };
  }

  Patient copyWith({
    double? height,
    double? weight,
    bool? hasMedicalCondition,
    String? chronicDisease,
    String? allergies,
    String? dietaryPreferences,
    String? emergencyContact,
    String? gender,
    String? firstName,
    String? lastName,
    String? phone,
  }) {
    return Patient(
      userId: userId,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      hasMedicalCondition: hasMedicalCondition ?? this.hasMedicalCondition,
      chronicDisease: chronicDisease ?? this.chronicDisease,
      allergies: allergies ?? this.allergies,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      gender: gender ?? this.gender,
    );
  }
}