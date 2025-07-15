enum Role {
  patient('patient'),
  nutritionist('nutritionist');

  const Role(this.value);
  final String value;

  static Role fromString(String value) {
    for (Role role in Role.values) {
      if (role.value == value) return role;
    }
    throw ArgumentError('Rol inválido: $value');
  }

  bool get isPatient => this == Role.patient;
  bool get isNutritionist => this == Role.nutritionist;

  @override
  String toString() => value;
}