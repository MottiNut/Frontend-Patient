enum PatientAction {
  accept('accept'),
  reject('reject');

  const PatientAction(this.value);
  final String value;
}

class PatientResponseRequest {
  final PatientAction action;
  final String? feedback;

  const PatientResponseRequest({
    required this.action,
    this.feedback,
  });
}