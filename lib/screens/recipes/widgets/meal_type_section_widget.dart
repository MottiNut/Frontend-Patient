// widgets/meal_type_section_widget.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/models/plan_detail.dart';
import 'package:frontendpatient/utils/meal_type_utils.dart';
import 'meal_card_widget.dart';

class MealTypeSectionWidget extends StatelessWidget {
  final String mealType;
  final List<PlanDetailResponse> meals;

  const MealTypeSectionWidget({
    super.key,
    required this.mealType,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    String mealTypeLabel = MealTypeUtils.getMealTypeLabel(mealType);
    IconData mealIcon = MealTypeUtils.getMealTypeIcon(mealType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del tipo de comida
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(
                mealIcon,
                color: Colors.orange[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                mealTypeLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Cards de las comidas
        ...meals.map((meal) => MealCardWidget(meal: meal)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }
}