// widgets/meal_details_modal.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/models/plan_detail.dart';
import 'info_card_widget.dart';

class MealDetailsModal extends StatelessWidget {
  final PlanDetailResponse meal;

  const MealDetailsModal({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle del modal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Título de la comida
              Text(
                meal.meal.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                meal.meal.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Información nutricional
              Row(
                children: [
                  Expanded(
                    child: InfoCardWidget(
                      title: 'Calorías',
                      value: '${meal.meal.calories}',
                      unit: 'kcal',
                      icon: Icons.local_fire_department,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InfoCardWidget(
                      title: 'Tiempo',
                      value: '${meal.meal.prepTimeMinutes}',
                      unit: 'min',
                      icon: Icons.access_time,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Porción
              InfoCardWidget(
                title: 'Porción recomendada',
                value: meal.portionSize,
                unit: '',
                icon: Icons.restaurant,
                color: Colors.orange,
              ),

              if (meal.specialInstructions != null) ...[
                const SizedBox(height: 16),
                InfoCardWidget(
                  title: 'Instrucciones especiales',
                  value: meal.specialInstructions!,
                  unit: '',
                  icon: Icons.info,
                  color: Colors.purple,
                ),
              ],

              // Ingredientes
              if (meal.meal.ingredients != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Ingredientes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    meal.meal.ingredients!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],

              // Instrucciones de preparación
              if (meal.meal.instructions != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Instrucciones de preparación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    meal.meal.instructions!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}