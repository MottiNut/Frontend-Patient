import 'package:frontendpatient/features/auth/data/entities/nutritionist.dart';
import 'package:frontendpatient/features/auth/data/entities/patient.dart';
import 'package:frontendpatient/features/auth/data/value_objects/role.dart';

abstract class User {
  final int userId;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String? phone;
  final Role role;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.phone,
    required this.role,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson();

  factory User.fromJson(Map<String, dynamic> json) {
    final role = Role.fromString(json['role']);

    switch (role) {
      case Role.patient:
        return Patient.fromJson(json);
      case Role.nutritionist:
        return Nutritionist.fromJson(json);
    }
  }
}