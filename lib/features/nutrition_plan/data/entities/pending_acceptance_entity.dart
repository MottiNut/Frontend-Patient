import '../../domain/models/pending_acceptance.dart';

class PendingAcceptanceEntity {
  final int planId;
  final String nutritionistName;
  final String weekStartDate;
  final String goal;
  final int energyRequirement;
  final String? specialRequirements;
  final String? reviewNotes;
  final String? reviewedAt;

  const PendingAcceptanceEntity({
    required this.planId,
    required this.nutritionistName,
    required this.weekStartDate,
    required this.energyRequirement,
    required this.goal,
    this.specialRequirements,
    this.reviewNotes,
    this.reviewedAt,
  });

  factory PendingAcceptanceEntity.fromJson(Map<String, dynamic> json) =>
      PendingAcceptanceEntity(
        planId: json['plan_id'],
        nutritionistName: json['nutritionist_name'],
        weekStartDate: json['week_start_date'],
        goal: json['goal'],
        energyRequirement: json['energy_requirement'],
        specialRequirements: json['special_requirements'],
        reviewNotes: json['review_notes'],
        reviewedAt: json['reviewed_at'],
      );

  Map<String, dynamic> toJson() => {
    'plan_id': planId,
    'nutritionist_name': nutritionistName,
    'week_start_date': weekStartDate,
    'goal': goal,
    'energy_requirement': energyRequirement,
    'special_requirements': specialRequirements,
    'review_notes': reviewNotes,
    'reviewed_at': reviewedAt,
  };

  PendingAcceptance toDomain() => PendingAcceptance(
    planId: planId,
    nutritionistName: nutritionistName,
    weekStartDate: weekStartDate,
    goal: goal,
    energyRequirement: energyRequirement,
    specialRequirements: specialRequirements,
    reviewNotes: reviewNotes,
    reviewedAt: reviewedAt,
  );
}