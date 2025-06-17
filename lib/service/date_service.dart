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

  /// Genera las fechas de la semana actual de lunes a domingo
  static List<DateItem> getCurrentWeekDates() {
    final now = DateTime.now();
    final mondayOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = mondayOfWeek.add(Duration(days: index));
      return DateItem(
        day: date.day.toString(),
        dayName: _getDayName(date.weekday),
        month: _getMonthName(date.month),
        isToday: _isSameDay(date, now),
        fullDate: date, // Si tu DateItem tiene este campo
      );
    });
  }

  /// Obtiene el nombre del día de la semana
  static String _getDayName(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday - 1];
  }

  /// Obtiene el nombre del mes
  static String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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