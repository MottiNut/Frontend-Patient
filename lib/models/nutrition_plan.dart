// models/nutrition_plan.dart
import 'package:frontendpatient/models/patient_model.dart';

enum PlanStatus { draft, validated, sent }

class NutritionPlan {
  final int? planId;
  final int nutritionistUserId;
  final Patient patient;
  final int medicalRecordId;
  final int energyRequirement;
  final DateTime creationDate;
  final PlanStatus status;

  NutritionPlan({
    this.planId,
    required this.nutritionistUserId,
    required this.patient,
    required this.medicalRecordId,
    required this.energyRequirement,
    required this.creationDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'plan_id': planId,
      'nutritionists_users_id': nutritionistUserId,
      'patients_users_user_id': patient.id,
      'medical_records_rec': medicalRecordId,
      'energy_requirement': energyRequirement,
      'creation_date': creationDate.toIso8601String(),
      'status': status.name,
    };
  }

  // ✅ CORREGIDO: Ahora usa el Patient que se pasa como parámetro
  factory NutritionPlan.fromMap(Map<String, dynamic> map, Patient patient) {
    return NutritionPlan(
      planId: map['plan_id'],
      nutritionistUserId: map['nutritionists_users_id'],
      patient: patient, // ✅ Usamos el Patient que se pasa como parámetro
      medicalRecordId: map['medical_records_rec'],
      energyRequirement: map['energy_requirement'],
      creationDate: DateTime.parse(map['creation_date']),
      status: PlanStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => PlanStatus.draft,
      ),
    );
  }
}