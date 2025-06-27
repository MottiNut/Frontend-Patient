import 'package:frontendpatient/features/auth/data/value_objects/role.dart';
import 'package:frontendpatient/features/auth/data/entities/user.dart';

class Nutritionist extends User {
  final String licenseNumber;
  final String specialization;
  final String workplace;
  final int? yearsOfExperience;
  final String? biography;

  Nutritionist({
    required super.userId,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.birthDate,
    super.phone,
    required super.createdAt,
    required this.licenseNumber,
    required this.specialization,
    required this.workplace,
    this.yearsOfExperience,
    this.biography,
  }) : super(role: Role.nutritionist);

  bool get isExperienced => yearsOfExperience != null && yearsOfExperience! >= 5;

  factory Nutritionist.fromJson(Map<String, dynamic> json) {
    return Nutritionist(
      userId: json['userId'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      phone: json['phone'],
      createdAt: DateTime.parse(json['createdAt']),
      licenseNumber: json['licenseNumber'],
      specialization: json['specialization'],
      workplace: json['workplace'],
      yearsOfExperience: json['yearsOfExperience'],
      biography: json['biography'],
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
      'licenseNumber': licenseNumber,
      'specialization': specialization,
      'workplace': workplace,
      'yearsOfExperience': yearsOfExperience,
      'biography': biography,
    };
  }

  Nutritionist copyWith({
    int? yearsOfExperience,
    String? biography,
    String? firstName,
    String? lastName,
    String? phone,
  }) {
    return Nutritionist(
      userId: userId,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      licenseNumber: licenseNumber,
      specialization: specialization,
      workplace: workplace,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      biography: biography ?? this.biography,
    );
  }
}