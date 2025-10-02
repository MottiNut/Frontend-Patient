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

  Map<String, dynamic> toJson() {
    // Crear el mapa base con campos requeridos
    final Map<String, dynamic> json = {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String().split('T')[0], // Formato: YYYY-MM-DD
    };

    // Agregar campos opcionales solo si no son nulos
    if (phone != null && phone!.isNotEmpty) {
      json['phone'] = phone;
    }
    if (height != null) {
      json['height'] = height;
    }
    if (weight != null) {
      json['weight'] = weight;
    }
    if (hasMedicalCondition != null) {
      json['hasMedicalCondition'] = hasMedicalCondition;
    }
    if (chronicDisease != null && chronicDisease!.isNotEmpty) {
      json['chronicDisease'] = chronicDisease;
    }
    if (allergies != null && allergies!.isNotEmpty) {
      json['allergies'] = allergies;
    }
    if (dietaryPreferences != null && dietaryPreferences!.isNotEmpty) {
      json['dietaryPreferences'] = dietaryPreferences;
    }
    if (gender != null && gender!.isNotEmpty) {
      json['gender'] = gender;
    }

    return json;
  }

  @override
  String toString() {
    return 'RegisterPatientRequest('
        'email: $email, '
        'firstName: $firstName, '
        'lastName: $lastName, '
        'birthDate: ${birthDate.toIso8601String().split('T')[0]})';
  }
}