// lib/widgets/meal_detail/nutrition_section.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';
import 'package:frontendpatient/models/plan_detail.dart';
import 'package:frontendpatient/screens/meal/widgets/nutrition_item_widget.dart';
import 'package:frontendpatient/screens/meal/widgets/section_title_widget.dart';

class NutritionSection extends StatelessWidget {
  final PlanDetailResponse mealDetail;

  const NutritionSection({
    super.key,
    required this.mealDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(title: 'Información Nutricional'),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: NutritionItemWidget(
                        label: 'Calorías',
                        value: '${mealDetail.meal.calories}',
                        unit: 'kcal',
                        icon: Icons.local_fire_department,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: NutritionItemWidget(
                        label: 'Proteínas',
                        value: '${mealDetail.meal.prepTimeMinutes}',
                        unit: 'g',
                        icon: Icons.fitness_center,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: NutritionItemWidget(
                        label: 'Carbohidratos',
                        value: '${mealDetail.meal.calories}',
                        unit: 'g',
                        icon: Icons.grain,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: NutritionItemWidget(
                        label: 'Grasas',
                        value: '${mealDetail.meal.prepTimeMinutes}',
                        unit: 'g',
                        icon: Icons.opacity,
                        color: Colors.yellow.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}