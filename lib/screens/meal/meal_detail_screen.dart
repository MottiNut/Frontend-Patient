// lib/screens/meal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/models/plan_detail.dart';
import 'package:frontendpatient/screens/meal/widgets/description_section.dart';
import 'package:frontendpatient/screens/meal/widgets/details_section.dart';
import 'package:frontendpatient/screens/meal/widgets/instructions_section.dart';
import 'package:frontendpatient/screens/meal/widgets/meal_header_section.dart';
import 'package:frontendpatient/screens/meal/widgets/nutrition_section.dart';

class MealDetailScreen extends StatelessWidget {
  final PlanDetailResponse mealDetail;

  const MealDetailScreen({
    super.key,
    required this.mealDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con fondo naranja
              MealHeaderSection(mealDetail: mealDetail),

              // Contenido con fondo blanco
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información Nutricional
                    NutritionSection(mealDetail: mealDetail),

                    const SizedBox(height: 24),
                    // Detalles
                    DetailsSection(mealDetail: mealDetail),

                    // Descripción (condicional)
                    if (mealDetail.meal.description.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      DescriptionSection(mealDetail: mealDetail),
                    ],

                    // Instrucciones Especiales (condicional)
                    if (mealDetail.specialInstructions != null) ...[
                      const SizedBox(height: 24),
                      InstructionsSection(mealDetail: mealDetail),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}