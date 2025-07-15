import 'package:frontendpatient/nutrition_plan/domain/models/enums.dart';
import 'package:frontendpatient/nutrition_plan/domain/models/nutrition_plan.dart';

class NutritionPlanDto {
  final int planId;
  final int patientId;
  final String patientName;
  final int nutritionistId;
  final String nutritionistName;
  final String weekStartDate;
  final int energyRequirement;
  final String goal;
  final String? specialRequirements;
  final Map<String, dynamic> planContent;
  final String status;
  final String? reviewNotes;
  final String createdAt;
  final String? reviewedAt;

  NutritionPlanDto({
    required this.planId,
    required this.patientId,
    required this.patientName,
    required this.nutritionistId,
    required this.nutritionistName,
    required this.weekStartDate,
    required this.energyRequirement,
    required this.goal,
    this.specialRequirements,
    required this.planContent,
    required this.status,
    this.reviewNotes,
    required this.createdAt,
    this.reviewedAt,
  });

  factory NutritionPlanDto.fromJson(Map<String, dynamic> json) {
    return NutritionPlanDto(
      planId: json['planId'] as int,
      patientId: json['patientId'] as int,
      patientName: json['patientName'] as String,
      nutritionistId: json['nutritionistId'] as int,
      nutritionistName: json['nutritionistName'] as String,
      weekStartDate: json['weekStartDate'] as String,
      energyRequirement: json['energyRequirement'] as int,
      goal: json['goal'] as String,
      specialRequirements: json['specialRequirements'] as String?,
      planContent: json['planContent'] as Map<String, dynamic>,
      status: json['status'] as String,
      reviewNotes: json['reviewNotes'] as String?,
      createdAt: json['createdAt'] as String,
      reviewedAt: json['reviewedAt'] as String?,
    );
  }

  // Convertir DTO a modelo de dominio
  NutritionPlan toDomain() {
    return NutritionPlan(
      planId: planId,
      patientId: patientId,
      patientName: patientName,
      nutritionistId: nutritionistId,
      nutritionistName: nutritionistName,
      weekStartDate: weekStartDate,
      energyRequirement: energyRequirement,
      goal: goal,
      specialRequirements: specialRequirements,
      planContent: planContent,
      status: PlanStatus.fromString(status),
      reviewNotes: reviewNotes,
      createdAt: DateTime.parse(createdAt),
      reviewedAt: reviewedAt != null ? DateTime.parse(reviewedAt!) : null,
    );
  }
}