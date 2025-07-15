import 'package:frontendpatient/nutrition_plan/domain/models/pending_patient_acceptance.dart';

class PendingPatientAcceptanceDto {
  final int planId;
  final String nutritionistName;
  final String weekStartDate;
  final int energyRequirement;
  final String goal;
  final String? specialRequirements;
  final String? reviewNotes;
  final String? reviewedAt;

  PendingPatientAcceptanceDto({
    required this.planId,
    required this.nutritionistName,
    required this.weekStartDate,
    required this.energyRequirement,
    required this.goal,
    this.specialRequirements,
    this.reviewNotes,
    this.reviewedAt,
  });

  factory PendingPatientAcceptanceDto.fromJson(Map<String, dynamic> json) {
    return PendingPatientAcceptanceDto(
      planId: json['planId'],
      nutritionistName: json['nutritionistName'],
      weekStartDate: json['weekStartDate'],
      energyRequirement: json['energyRequirement'],
      goal: json['goal'],
      specialRequirements: json['specialRequirements'],
      reviewNotes: json['reviewNotes'],
      reviewedAt: json['reviewedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'nutritionistName': nutritionistName,
      'weekStartDate': weekStartDate,
      'energyRequirement': energyRequirement,
      'goal': goal,
      'specialRequirements': specialRequirements,
      'reviewNotes': reviewNotes,
      'reviewedAt': reviewedAt,
    };
  }

  // Convertir DTO a modelo de dominio
  PendingPatientAcceptance toDomain() {
    return PendingPatientAcceptance(
      planId: planId,
      nutritionistName: nutritionistName,
      weekStartDate: weekStartDate,
      energyRequirement: energyRequirement,
      goal: goal,
      specialRequirements: specialRequirements,
      reviewNotes: reviewNotes,
      reviewedAt: reviewedAt != null ? DateTime.parse(reviewedAt!) : null,
    );
  }
}