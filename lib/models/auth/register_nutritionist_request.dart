class RegisterNutritionistRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String? phone;
  final String licenseNumber;
  final String specialization;
  final String workplace;

  RegisterNutritionistRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    this.phone,
    required this.licenseNumber,
    required this.specialization,
    required this.workplace,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    'birthDate': birthDate.toIso8601String().split('T')[0],
    'phone': phone,
    'licenseNumber': licenseNumber,
    'specialization': specialization,
    'workplace': workplace,
  };
}