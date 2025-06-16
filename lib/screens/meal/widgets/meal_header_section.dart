// lib/widgets/meal_detail/meal_header_section.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';
import 'package:frontendpatient/models/plan_detail.dart';
import 'package:frontendpatient/screens/meal/widgets/meal_icon_widget.dart';

class MealHeaderSection extends StatelessWidget {
  final PlanDetailResponse mealDetail;

  const MealHeaderSection({
    super.key,
    required this.mealDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.mainOrange,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botón de regresar
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: AppColors.whiteBackground,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
            // Label del tipo de comida
            Text(
              mealDetail.mealTypeLabel,
              style: AppTextStyles.titleAccompaniment.copyWith(
                color: AppColors.whiteBackground,
              ),
            ),
            const SizedBox(height: 10),
            // Nombre del platillo
            Text(
              mealDetail.meal.name,
              style: AppTextStyles.tittle.copyWith(
                color: AppColors.whiteBackground,
                height: 1.3
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Imagen del meal
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: MealIconWidget(mealType: mealDetail.mealType),
              ),
            ),
          ],
        ),
      ),
    );
  }
}