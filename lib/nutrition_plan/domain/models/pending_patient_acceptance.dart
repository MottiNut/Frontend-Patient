class PendingPatientAcceptance {
  final int planId;
  final String nutritionistName;
  final String weekStartDate;
  final int energyRequirement;
  final String goal;
  final String? specialRequirements;
  final String? reviewNotes;
  final DateTime? reviewedAt;

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
}