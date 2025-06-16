// lib/widgets/patient/date_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';
import 'package:frontendpatient/service/date_service.dart';

class DateSelectorWidget extends StatefulWidget {
  final Function(DateItem) onDateSelected;
  final int daysToShow;
  final int? selectedIndex;

  const DateSelectorWidget({
    super.key,
    required this.onDateSelected,
    this.daysToShow = 6,
    this.selectedIndex,
  });

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  late List<DateItem> dates;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadDates();
  }

  void _loadDates() {
    dates = DateService.getWeekDates(days: widget.daysToShow);

    // Si se pasó un índice seleccionado por parámetro, úsalo
    if (widget.selectedIndex != null &&
        widget.selectedIndex! >= 0 &&
        widget.selectedIndex! < dates.length) {
      selectedIndex = widget.selectedIndex!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDateSelected(dates[selectedIndex!]);
      });
      return;
    }

    // Si no, busca el día actual
    final todayIndex = dates.indexWhere((date) => date.isToday);
    if (todayIndex != -1) {
      selectedIndex = todayIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDateSelected(dates[todayIndex]);
      });
    }
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

        // Lista horizontal de fechas
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = index == selectedIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    widget.onDateSelected(date);
                  },
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
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.darkestOrange
                                : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Día del mes dentro de un círculo pequeño
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.mainOrange
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            date.day,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
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
