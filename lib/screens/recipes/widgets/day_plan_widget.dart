import 'package:flutter/material.dart';
import '../../../models/nutrition_plan/daily_plan_response.dart';
import 'macronutrients_card.dart';
import 'meal_card.dart';

class DayPlanWidget extends StatelessWidget {
  final DailyPlanResponse dailyPlan;

  const DayPlanWidget({
    super.key,
    required this.dailyPlan,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayHeader(),
          const SizedBox(height: 16),
          MacronutrientsCard(macronutrients: dailyPlan.macronutrients),
          const SizedBox(height: 16),
          ..._buildMealCards(),
        ],
      ),
    );
  }

  Widget _buildDayHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dailyPlan.dayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _formatDate(dailyPlan.date),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '${dailyPlan.totalCalories} kcal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMealCards() {
    return dailyPlan.meals.entries.map((entry) {
      final mealType = entry.key;
      final mealData = entry.value as Map<String, dynamic>;

      return MealCard(
        mealType: mealType,
        mealData: mealData,
      );
    }).toList();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const months = [
        'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
      ];
      return '${date.day} de ${months[date.month - 1]}';
    } catch (e) {
      return dateString;
    }
  }
}