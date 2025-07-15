import 'package:frontendpatient/nutrition_plan/domain/models/enums.dart';

class NutritionPlan {
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
  final PlanStatus status;
  final String? reviewNotes;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  NutritionPlan({
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

  bool get isPendingAcceptance => status == PlanStatus.pendingPatientAcceptance;
  bool get isAccepted => status == PlanStatus.acceptedByPatient;
  bool get isRejected => status == PlanStatus.rejectedByPatient;
}