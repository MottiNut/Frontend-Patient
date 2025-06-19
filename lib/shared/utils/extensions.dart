// lib/models/extensions.dart

extension DateTimeExtensions on DateTime {
  /// Obtiene el lunes de la semana actual
  DateTime get startOfWeek {
    final daysToSubtract = weekday - 1; // weekday: 1 = Monday, 7 = Sunday
    return subtract(Duration(days: daysToSubtract));
  }

  /// Convierte a formato YYYY-MM-DD
  String get dateString {
    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }

  /// Obtiene el día de la semana como número (1-7)
  int get dayOfWeekNumber => weekday;

}

extension StringExtensions on String {
  /// Convierte string de fecha a DateTime
  DateTime? get toDateTime {
    try {
      return DateTime.parse(this);
    } catch (e) {
      return null;
    }
  }

  /// Capitaliza la primera letra
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}