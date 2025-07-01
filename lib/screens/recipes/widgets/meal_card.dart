import 'package:flutter/material.dart';
import '../../../models/nutrition_plan/daily_plan_response.dart';// Asegúrate de tener esta clase importada

class MealCard extends StatelessWidget {
  final Meal meal;

  const MealCard({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMealHeader(meal.calories),
            const SizedBox(height: 12),
            if (meal.name.isNotEmpty)
              Text(
                meal.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 8),
            if (meal.description.isNotEmpty)
              Text(
                meal.description,
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 8),
            if (meal.ingredients.isNotEmpty)
              Text(
                'Ingredientes: ${meal.ingredients}',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            const SizedBox(height: 8),
            if (meal.preparationTime.isNotEmpty)
              Text(
                'Tiempo de preparación: ${meal.preparationTime}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealHeader(int calories) {
    return Row(
      children: [
        Icon(
          _getMealIcon(meal.type),
          color: Colors.orange,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal.type,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$calories kcal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'desayuno':
        return Icons.free_breakfast;
      case 'almuerzo':
        return Icons.lunch_dining;
      case 'cena':
        return Icons.dinner_dining;
      case 'media mañana':
      case 'merienda':
      case 'media tarde':
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }
}
