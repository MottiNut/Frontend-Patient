// widgets/day_plan_widget.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/models/plan_detail.dart';
import 'meal_type_section_widget.dart';

class DayPlanWidget extends StatelessWidget {
  final String dayName;
  final List<PlanDetailResponse> meals;

  const DayPlanWidget({
    super.key,
    required this.dayName,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay comidas programadas para $dayName',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Organizar las comidas por tipo
    final mealsByType = <String, List<PlanDetailResponse>>{};
    for (final meal in meals) {
      final type = meal.mealType;
      if (!mealsByType.containsKey(type)) {
        mealsByType[type] = [];
      }
      mealsByType[type]!.add(meal);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del día
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.orange[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${meals.length} comidas programadas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calorías totales del día
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_calculateDailyCalories(meals)} kcal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lista de comidas organizadas por tipo
          ...mealsByType.entries.map((entry) {
            return MealTypeSectionWidget(
              mealType: entry.key,
              meals: entry.value,
            );
          }).toList(),
        ],
      ),
    );
  }

  int _calculateDailyCalories(List<PlanDetailResponse> meals) {
    return meals.fold(0, (total, meal) => total + meal.meal.calories);
  }
}