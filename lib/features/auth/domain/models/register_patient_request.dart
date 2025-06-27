class RegisterPatientRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String? phone;
  final double? height;
  final double? weight;
  final bool? hasMedicalCondition;
  final String? chronicDisease;
  final String? allergies;
  final String? dietaryPreferences;
  final String? gender;

  RegisterPatientRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    this.phone,
    this.height,
    this.weight,
    this.hasMedicalCondition,
    this.chronicDisease,
    this.allergies,
    this.dietaryPreferences,
    this.gender,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    'birthDate': birthDate.toIso8601String().split('T')[0],
    'phone': phone,
    'height': height,
    'weight': weight,
    'hasMedicalCondition': hasMedicalCondition,
    'chronicDisease': chronicDisease,
    'allergies': allergies,
    'dietaryPreferences': dietaryPreferences,
    'gender': gender,
  };
}