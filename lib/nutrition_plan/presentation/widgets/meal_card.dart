import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontendpatient/nutrition_plan/domain/models/meal.dart';

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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMealHeader(meal.calories),
            const SizedBox(height: 16),
            if (meal.name.isNotEmpty) ...[
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.utensils,
                    color: Colors.orange.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (meal.description.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FaIcon(
                    FontAwesomeIcons.alignLeft,
                    color: Colors.grey[600],
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meal.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (meal.ingredients.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FaIcon(
                    FontAwesomeIcons.list,
                    color: Colors.green.shade600,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ingredientes: ${meal.ingredients}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (meal.preparationTime.isNotEmpty) ...[
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.clock,
                    color: Colors.blue.shade600,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tiempo de preparación: ${meal.preparationTime}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMealHeader(int calories) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getMealColor(meal.type).withOpacity(0.1),
            _getMealColor(meal.type).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getMealColor(meal.type).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getMealColor(meal.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              _getMealIcon(meal.type),
              color: _getMealColor(meal.type),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.type,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getMealColor(meal.type),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.fire,
                      color: Colors.orange.shade600,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$calories kcal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'desayuno':
        return FontAwesomeIcons.mugHot;
      case 'almuerzo':
        return FontAwesomeIcons.bowlFood;
      case 'cena':
        return FontAwesomeIcons.plateWheat;
      case 'media mañana':
      case 'merienda':
      case 'media tarde':
      case 'snack':
        return FontAwesomeIcons.cookie;
      default:
        return FontAwesomeIcons.utensils;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'desayuno':
        return Colors.orange.shade600;
      case 'almuerzo':
        return Colors.green.shade600;
      case 'cena':
        return Colors.indigo.shade600;
      case 'media mañana':
      case 'merienda':
      case 'media tarde':
      case 'snack':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}