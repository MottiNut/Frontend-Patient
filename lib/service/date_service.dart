// lib/services/date_service.dart

class DateService {
  static DateTime get today => DateTime.now();

  /// Genera una lista de fechas consecutivas empezando desde hoy
  static List<DateItem> getWeekDates({int days = 7, DateTime? startDate}) {
    final start = startDate ?? today;
    final List<DateItem> dates = [];

    for (int i = 0; i < days; i++) {
      final date = start.add(Duration(days: i));
      dates.add(DateItem(
        day: date.day.toString(),
        dayName: _getDayName(date.weekday),
        month: _getMonthName(date.month),
        fullDate: date,
        isToday: _isSameDay(date, today),
      ));
    }

    return dates;
  }

  /// Verifica si dos fechas son el mismo día
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Obtiene el nombre del día de la semana
  static String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Lun';
      case DateTime.tuesday: return 'Mar';
      case DateTime.wednesday: return 'Mié';
      case DateTime.thursday: return 'Jue';
      case DateTime.friday: return 'Vie';
      case DateTime.saturday: return 'Sáb';
      case DateTime.sunday: return 'Dom';
      default: return '';
    }
  }

  /// Obtiene el nombre del mes
  static String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Ene';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Abr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Ago';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dic';
      default: return '';
    }
  }
}

/// Modelo para los elementos de fecha
class DateItem {
  final String day;
  final String dayName;
  final String month;
  final DateTime fullDate;
  final bool isToday;

  const DateItem({
    required this.day,
    required this.dayName,
    required this.month,
    required this.fullDate,
    required this.isToday,
  });
}