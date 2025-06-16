enum MealType {
  breakfast,
  snackMorning,
  lunch,
  snackAfternoon,
  dinner,
  snackEvening;

  String get value {
    switch (this) {
      case MealType.breakfast:
        return 'breakfast';
      case MealType.snackMorning:
        return 'snack_morning';
      case MealType.lunch:
        return 'lunch';
      case MealType.snackAfternoon:
        return 'snack_afternoon';
      case MealType.dinner:
        return 'dinner';
      case MealType.snackEvening:
        return 'snack_evening';
    }
  }

  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Desayuno';
      case MealType.snackMorning:
        return 'Snack Mañana';
      case MealType.lunch:
        return 'Almuerzo';
      case MealType.snackAfternoon:
        return 'Snack Tarde';
      case MealType.dinner:
        return 'Cena';
      case MealType.snackEvening:
        return 'Snack Noche';
    }
  }

  static MealType fromString(String value) {
    switch (value) {
      case 'breakfast':
        return MealType.breakfast;
      case 'snack_morning':
        return MealType.snackMorning;
      case 'lunch':
        return MealType.lunch;
      case 'snack_afternoon':
        return MealType.snackAfternoon;
      case 'dinner':
        return MealType.dinner;
      case 'snack_evening':
        return MealType.snackEvening;
      default:
        throw ArgumentError('Invalid meal type: $value');
    }
  }
}

enum PlanStatus {
  active,
  completed,
  cancelled;

  String get value {
    switch (this) {
      case PlanStatus.active:
        return 'active';
      case PlanStatus.completed:
        return 'completed';
      case PlanStatus.cancelled:
        return 'cancelled';
    }
  }

  static PlanStatus fromString(String value) {
    switch (value) {
      case 'active':
        return PlanStatus.active;
      case 'completed':
        return PlanStatus.completed;
      case 'cancelled':
        return PlanStatus.cancelled;
      default:
        throw ArgumentError('Invalid plan status: $value');
    }
  }
}

enum DayOfWeek {
  monday(1, 'Lunes'),
  tuesday(2, 'Martes'),
  wednesday(3, 'Miércoles'),
  thursday(4, 'Jueves'),
  friday(5, 'Viernes'),
  saturday(6, 'Sábado'),
  sunday(7, 'Domingo');

  const DayOfWeek(this.number, this.name);

  final int number;
  final String name;

  static DayOfWeek fromNumber(int number) {
    switch (number) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      case 7:
        return DayOfWeek.sunday;
      default:
        throw ArgumentError('Invalid day number: $number');
    }
  }

  static DayOfWeek getCurrentDay() {
    final today = DateTime.now();
    final weekday = today.weekday; // 1 = Monday, 7 = Sunday
    return fromNumber(weekday);
  }
}