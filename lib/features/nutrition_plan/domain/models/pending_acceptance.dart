class PendingAcceptance {
  final int planId;
  final String nutritionistName;
  final String weekStartDate;
  final String goal;
  final int energyRequirement;
  final String? specialRequirements;
  final String? reviewNotes;
  final String? reviewedAt;

  const PendingAcceptance({
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