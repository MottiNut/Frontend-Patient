// lib/models/nutrition_plan.dart
import 'package:frontendpatient/models/plan_detail.dart';

class NutritionPlan {
  final int planId;
  final int nutritionistsUsersId;
  final int patientsUsersUserId;
  final int medicalRecordsRec;
  final int energyRequirement;
  final String creationDate;
  final String status;
  final List<PlanDetail> details;

  NutritionPlan({
    required this.planId,
    required this.nutritionistsUsersId,
    required this.patientsUsersUserId,
    required this.medicalRecordsRec,
    required this.energyRequirement,
    required this.creationDate,
    required this.status,
    this.details = const [],
  });

  factory NutritionPlan.fromJson(Map<String, dynamic> json) {
    List<PlanDetail> detailsList = [];
    if (json['details'] != null) {
      detailsList = (json['details'] as List)
          .map((detail) => PlanDetail.fromJson(detail))
          .toList();
    }

    return NutritionPlan(
      planId: json['plan_id'] ?? 0,
      nutritionistsUsersId: json['nutritionists_users_id'] ?? 0,
      patientsUsersUserId: json['patients_users_user_id'] ?? 0,
      medicalRecordsRec: json['medical_records_rec'] ?? 0,
      energyRequirement: json['energy_requirement'] ?? 0,
      creationDate: json['creation_date'] ?? '',
      status: json['status'] ?? 'pending',
      details: detailsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'nutritionists_users_id': nutritionistsUsersId,
      'patients_users_user_id': patientsUsersUserId,
      'medical_records_rec': medicalRecordsRec,
      'energy_requirement': energyRequirement,
      'creation_date': creationDate,
      'status': status,
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }

  // Método para obtener calorías totales del plan
  int get totalCalories {
    return details.fold(0, (sum, detail) => sum + detail.meal.calories);
  }

  // Método para obtener detalles por tipo de comida
  List<PlanDetail> getDetailsByMealType(String mealType) {
    return details.where((detail) => detail.mealType == mealType).toList();
  }
}

class NutritionPlanCreate {
  final int nutritionistsUsersId;
  final int patientsUsersUserId;
  final int medicalRecordsRec;
  final int energyRequirement;
  final String status;

  NutritionPlanCreate({
    required this.nutritionistsUsersId,
    required this.patientsUsersUserId,
    required this.medicalRecordsRec,
    required this.energyRequirement,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'nutritionists_users_id': nutritionistsUsersId,
      'patients_users_user_id': patientsUsersUserId,
      'medical_records_rec': medicalRecordsRec,
      'energy_requirement': energyRequirement,
      'status': status,
    };
  }
}