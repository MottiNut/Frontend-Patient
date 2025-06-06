//import 'package:frontendpatient/models/user_model.dart';
//
//class Patient {
//  final User user;
//  final String firstName;
//  final String lastName;
//  final DateTime? birthDate;
//  final String? phone;
//  final double? height;
//  final double? weight;
//  final bool hasMedicalCondition;
//  final String? chronicDisease;
//  final String? allergies;
//  final String? dietaryPreferences;
//
//  Patient({
//    required this.user,
//    required this.firstName,
//    required this.lastName,
//    this.birthDate,
//    this.phone,
//    this.height,
//    this.weight,
//    required this.hasMedicalCondition,
//    this.chronicDisease,
//    this.allergies,
//    this.dietaryPreferences,
//  });
//
//  int? get id => user.id;
//  String get email => user.email;
//  String get password => user.password;
//  UserRole get role => user.role;
//  DateTime get createdAt => user.createdAt;
//  DateTime? get updatedAt => user.updatedAt;
//
//  String get fullName => '$firstName $lastName';
//
//  int? get age {
//    if (birthDate == null) return null;
//    final now = DateTime.now();
//    int age = now.year - birthDate!.year;
//    if (now.month < birthDate!.month ||
//        (now.month == birthDate!.month && now.day < birthDate!.day)) {
//      age--;
//    }
//    return age;
//  }
//
//  Map<String, dynamic> toMap() {
//    final userMap = user.toMap();
//    userMap.addAll({
//      'first_name': firstName,
//      'last_name': lastName,
//      'birth_date': birthDate?.toIso8601String(),
//      'phone': phone,
//      'height': height,
//      'weight': weight,
//      'has_medical_condition': hasMedicalCondition ? 1 : 0, // CORREGIDO: convertir bool a int
//      'chronic_disease': chronicDisease,
//      'allergies': allergies,
//      'dietary_preferences': dietaryPreferences,
//    });
//    return userMap;
//  }
//
//  factory Patient.fromMap(Map<String, dynamic> map) {
//    final user = User.fromMap(map);
//
//    DateTime? birth;
//    if (map['birth_date'] != null) {
//      if (map['birth_date'] is int) {
//        birth = DateTime.fromMillisecondsSinceEpoch(map['birth_date'] * 1000);
//      } else if (map['birth_date'] is String) {
//        birth = DateTime.tryParse(map['birth_date']);
//      }
//    }
//
//    return Patient(
//      user: user,
//      firstName: map['first_name'] ?? '',
//      lastName: map['last_name'] ?? '',
//      birthDate: birth,
//      phone: map['phone']?.toString(),
//      height: map['height'] != null ? (map['height'] as num).toDouble() : null,
//      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
//      hasMedicalCondition: map['has_medical_condition'] == true ||
//          map['has_medical_condition'] == 1,
//      chronicDisease: map['chronic_disease'],
//      allergies: map['allergies'],
//      dietaryPreferences: map['dietary_preferences'],
//    );
//  }
//
//  factory Patient.create({
//    int? id,
//    required String email,
//    required String password,
//    required String firstName,
//    required String lastName,
//    DateTime? birthDate,
//    String? phone,
//    double? height,
//    double? weight,
//    required bool hasMedicalCondition,
//    String? chronicDisease,
//    String? allergies,
//    String? dietaryPreferences,
//  }) {
//    final user = User(
//      id: id,
//      email: email,
//      password: password,
//      role: UserRole.patient,
//      createdAt: DateTime.now(),
//    );
//
//    return Patient(
//      user: user,
//      firstName: firstName,
//      lastName: lastName,
//      birthDate: birthDate,
//      phone: phone,
//      height: height,
//      weight: weight,
//      hasMedicalCondition: hasMedicalCondition,
//      chronicDisease: chronicDisease,
//      allergies: allergies,
//      dietaryPreferences: dietaryPreferences,
//    );
//  }
//
//  Patient copyWith({
//    User? user,
//    String? firstName,
//    String? lastName,
//    DateTime? birthDate,
//    String? phone,
//    double? height,
//    double? weight,
//    bool? hasMedicalCondition,
//    String? chronicDisease,
//    String? allergies,
//    String? dietaryPreferences,
//  }) {
//    return Patient(
//      user: user ?? this.user,
//      firstName: firstName ?? this.firstName,
//      lastName: lastName ?? this.lastName,
//      birthDate: birthDate ?? this.birthDate,
//      phone: phone ?? this.phone,
//      height: height ?? this.height,
//      weight: weight ?? this.weight,
//      hasMedicalCondition: hasMedicalCondition ?? this.hasMedicalCondition,
//      chronicDisease: chronicDisease ?? this.chronicDisease,
//      allergies: allergies ?? this.allergies,
//      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
//    );
//  }
//
//  Patient copyWithAll({
//    int? id,
//    String? email,
//    String? password,
//    DateTime? createdAt,
//    DateTime? updatedAt,
//    String? firstName,
//    String? lastName,
//    DateTime? birthDate,
//    String? phone,
//    double? height,
//    double? weight,
//    bool? hasMedicalCondition,
//    String? chronicDisease,
//    String? allergies,
//    String? dietaryPreferences,
//  }) {
//    final updatedUser = user.copyWith(
//      id: id,
//      email: email,
//      password: password,
//      createdAt: createdAt,
//      updatedAt: updatedAt,
//    );
//
//    return Patient(
//      user: updatedUser,
//      firstName: firstName ?? this.firstName,
//      lastName: lastName ?? this.lastName,
//      birthDate: birthDate ?? this.birthDate,
//      phone: phone ?? this.phone,
//      height: height ?? this.height,
//      weight: weight ?? this.weight,
//      hasMedicalCondition: hasMedicalCondition ?? this.hasMedicalCondition,
//      chronicDisease: chronicDisease ?? this.chronicDisease,
//      allergies: allergies ?? this.allergies,
//      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
//    );
//  }
//}