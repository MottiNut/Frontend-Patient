// lib/widgets/patient/date_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';
import 'package:frontendpatient/services/date_service.dart';

class DateSelectorWidget extends StatefulWidget {
  final int daysToShow;
  final bool isReadOnly;

  const DateSelectorWidget({
    super.key,
    this.daysToShow = 7,
    this.isReadOnly = false,
  });

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  late List<DateItem> dates;
  int? todayIndex;

  @override
  void initState() {
    super.initState();
    _loadDates();
  }

  void _loadDates() {
    // Generar fechas de lunes a domingo de la semana actual
    dates = _generateCurrentWeekDates();

    // Buscar el índice del día actual
    todayIndex = dates.indexWhere((date) => date.isToday);
  }

  /// Genera las fechas de la semana actual de lunes a domingo
  List<DateItem> _generateCurrentWeekDates() {
    final now = DateTime.now();
    final mondayOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = mondayOfWeek.add(Duration(days: index));
      return DateItem(
        day: date.day.toString(),
        dayName: _getDayName(date.weekday),
        month: _getMonthName(date.month),
        isToday: _isSameDay(date, now),
        fullDate: date,
      );
    });
  }

  String _getDayName(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = dates.isNotEmpty ? dates.first.month : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mes una sola vez
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            currentMonth,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Lista horizontal de fechas (solo informativa)
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isToday = date.isToday;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.whiteBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Día de la semana (ej: LUN)
                      Text(
                        date.dayName.substring(0, 3).toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? AppColors.darkestOrange
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Día del mes dentro de un círculo
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.mainOrange
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: isToday
                              ? Border.all(color: AppColors.darkestOrange, width: 2)
                              : null,
                        ),
                        child: Text(
                          date.day,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isToday ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),

                      // Indicador adicional para "HOY"
                      if (isToday) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.darkestOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'HOY',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}