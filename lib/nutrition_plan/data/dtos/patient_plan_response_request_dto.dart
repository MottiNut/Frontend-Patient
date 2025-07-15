class PatientPlanResponseRequestDto {
  final String action;
  final String? feedback;

  PatientPlanResponseRequestDto({
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