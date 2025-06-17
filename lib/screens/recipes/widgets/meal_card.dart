import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final String mealType;
  final Map<String, dynamic> mealData;

  const MealCard({
    super.key,
    required this.mealType,
    required this.mealData,
  });

  @override
  Widget build(BuildContext context) {
    final foods = mealData['foods'] as List<dynamic>? ?? [];
    final totalCalories = mealData['total_calories'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMealHeader(totalCalories),
            const SizedBox(height: 16),
            ..._buildFoodList(foods),
          ],
        ),
      ),
    );
  }

  Widget _buildMealHeader(int totalCalories) {
    return Row(
      children: [
        Icon(
          _getMealIcon(mealType),
          color: Colors.orange,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getMealLabel(mealType),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$totalCalories kcal',
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

  List<Widget> _buildFoodList(List<dynamic> foods) {
    return foods.map((food) {
      final name = food['name'] as String? ?? '';
      final quantity = food['quantity'] as String? ?? '';
      final calories = food['calories'] as int? ?? 0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, right: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade300,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (quantity.isNotEmpty)
                    Text(
                      quantity,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '${calories} kcal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snacks':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  String _getMealLabel(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Desayuno';
      case 'lunch':
        return 'Almuerzo';
      case 'dinner':
        return 'Cena';
      case 'snacks':
        return 'Snacks';
      default:
        return 'Comida';
    }
  }
}