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