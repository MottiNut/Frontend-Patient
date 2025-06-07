// lib/widgets/patient/date_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/service/date_service.dart';

class DateSelectorWidget extends StatefulWidget {
  final Function(DateItem) onDateSelected;
  final int daysToShow;

  const DateSelectorWidget({
    super.key,
    required this.onDateSelected,
    this.daysToShow = 6,
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

    // Encontrar y seleccionar automáticamente el día actual
    final todayIndex = dates.indexWhere((date) => date.isToday);
    if (todayIndex != -1) {
      selectedIndex = todayIndex;
      // Notificar la selección inicial del día actual
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDateSelected(dates[todayIndex]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.orange[700]
                          : date.isToday
                          ? Colors.orange[300]
                          : Colors.orange[200],
                      borderRadius: BorderRadius.circular(16),
                      border: date.isToday && !isSelected
                          ? Border.all(color: Colors.orange[700]!, width: 2)
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      date.day,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : date.isToday
                            ? Colors.orange[800]
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.dayName,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.orange[700]
                          : date.isToday
                          ? Colors.orange[700]
                          : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  if (date.isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange[700] : Colors.orange[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
