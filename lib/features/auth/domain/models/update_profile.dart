class UpdatePatientProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final double? height;
  final double? weight;
  final bool? hasMedicalCondition;
  final String? chronicDisease;
  final String? allergies;
  final String? dietaryPreferences;
  final String? emergencyContact;
  final String? gender;

  UpdatePatientProfileRequest({
    this.firstName,
    this.lastName,
    this.phone,
    this.height,
    this.weight,
    this.hasMedicalCondition,
    this.chronicDisease,
    this.allergies,
    this.dietaryPreferences,
    this.emergencyContact,
    this.gender,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
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

class UpdateNutritionistProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final int? yearsOfExperience;
  final String? biography;

  UpdateNutritionistProfileRequest({
    this.firstName,
    this.lastName,
    this.phone,
    this.yearsOfExperience,
    this.biography,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'yearsOfExperience': yearsOfExperience,
    'biography': biography,
  };
}