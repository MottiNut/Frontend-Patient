
import 'daily_plan_response.dart';

enum PlanStatus {
  pendingReview('pending_review'),
  approved('approved'),
  rejected('rejected'),
  pendingPatientAcceptance('pending_patient_acceptance'),
  acceptedByPatient('accepted_by_patient'),
  rejectedByPatient('rejected_by_patient');

  const PlanStatus(this.value);
  final String value;

  static PlanStatus fromString(String value) {
    return PlanStatus.values.firstWhere(
          (status) => status.value == value,
      orElse: () => throw Exception('Estado de plan inválido: $value'),
    );
  }
}

enum PatientAction {
  accept('accept'),
  reject('reject');

  const PatientAction(this.value);
  final String value;

  static PatientAction fromString(String value) {
    return PatientAction.values.firstWhere(
          (action) => action.value == value,
      orElse: () => throw Exception('Acción del paciente inválida: $value'),
    );
  }
}

class PendingPatientAcceptance {
  final int planId;
  final String nutritionistName;
  final String weekStartDate;
  final int energyRequirement;
  final String goal;
  final String? specialRequirements;
  final String? reviewNotes;
  final String? reviewedAt;

  PendingPatientAcceptance({
    required this.planId,
    required this.nutritionistName,
    required this.weekStartDate,
    required this.energyRequirement,
    required this.goal,
    this.specialRequirements,
    this.reviewNotes,
    this.reviewedAt,
  });

  factory PendingPatientAcceptance.fromJson(Map<String, dynamic> json) {
    return PendingPatientAcceptance(
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
}

class NutritionPlanResponse {
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

  NutritionPlanResponse({
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

  factory NutritionPlanResponse.fromJson(Map<String, dynamic> json) {
    return NutritionPlanResponse(
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
}


class WeeklyPlanResponse {
  final int planId;
  final String weekStartDate;
  final String weekEndDate;
  final String goal;
  final int energyRequirement;
  final List<DailyPlanResponse> dailyPlans;
  final String? reviewNotes;

  WeeklyPlanResponse({
    required this.planId,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.goal,
    required this.energyRequirement,
    required this.dailyPlans,
    this.reviewNotes,
  });

  factory WeeklyPlanResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyPlanResponse(
      planId: json['planId'],
      weekStartDate: json['weekStartDate'],
      weekEndDate: json['weekEndDate'],
      goal: json['goal'],
      energyRequirement: json['energyRequirement'],
      dailyPlans: (json['dailyPlans'] as List)
          .map((plan) => DailyPlanResponse.fromJson(plan))
          .toList(),
      reviewNotes: json['reviewNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'weekStartDate': weekStartDate,
      'weekEndDate': weekEndDate,
      'goal': goal,
      'energyRequirement': energyRequirement,
      'dailyPlans': dailyPlans.map((plan) => plan.toJson()).toList(),
      'reviewNotes': reviewNotes,
    };
  }
}

// Request DTOs
class PatientPlanResponseRequest {
  final String action;
  final String? feedback;

  PatientPlanResponseRequest({
    required this.action,
    this.feedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'feedback': feedback,
    };
  }
}
