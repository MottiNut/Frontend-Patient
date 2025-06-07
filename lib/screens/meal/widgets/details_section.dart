// lib/widgets/meal_detail/details_section.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/models/plan_detail.dart';
import 'package:frontendpatient/screens/meal/widgets/detail_row_widget.dart';
import 'package:frontendpatient/screens/meal/widgets/section_title_widget.dart';

class DetailsSection extends StatelessWidget {
  final PlanDetailResponse mealDetail;

  const DetailsSection({
    super.key,
    required this.mealDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(title: 'Detalles'),
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
                DetailRowWidget(
                  label: 'Día',
                  value: '${mealDetail.dayName} (${mealDetail.dayOfWeek})',
                  icon: Icons.calendar_today,
                ),
                const Divider(height: 24),
                DetailRowWidget(
                  label: 'Porción',
                  value: mealDetail.portionSize,
                  icon: Icons.restaurant,
                ),
                const Divider(height: 24),
                DetailRowWidget(
                  label: 'Categoría',
                  value: mealDetail.meal.ingredients!,
                  icon: Icons.category,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}