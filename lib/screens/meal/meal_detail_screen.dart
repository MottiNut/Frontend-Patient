import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontendpatient/models/nutrition_plan/daily_plan.dart';
import '../../core/themes/app_theme.dart';
import '../../models/nutrition_plan/daily_plan_response.dart';

class MealDetailScreen extends StatelessWidget {
  final MealData meal;

  const MealDetailScreen({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header naranja
          Container(
            decoration: BoxDecoration(
              color: AppColors.mainOrange,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      meal.mealTypeLabel,
                      style: AppTextStyles.tittle.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            padding: const EdgeInsets.only(top: 10),
                            child: _getMealIcon(meal.mealType),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildBenefitItem(
                                  '${meal.calories} kcal',
                                  Icons.local_fire_department,
                                  isOrangeSection: true,
                                ),
                                const SizedBox(height: 15),
                                _buildBenefitItem(
                                  meal.preparationTime!,
                                  Icons.timer,
                                  isOrangeSection: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Sección blanca
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (meal.name.isNotEmpty) ...[
                      const Text('Nombre:', style: AppTextStyles.subtitle),
                      const SizedBox(height: 8),
                      Text(meal.name, style: AppTextStyles.description),
                      const SizedBox(height: 16),
                    ],
                    if (meal.description!.isNotEmpty) ...[
                      const Text('Descripción:', style: AppTextStyles.subtitle),
                      const SizedBox(height: 8),
                      Text(meal.description!, style: AppTextStyles.description),
                      const SizedBox(height: 16),
                    ],
                    if (meal.ingredients!.isNotEmpty) ...[
                      const Text('Ingredientes:', style: AppTextStyles.subtitle),
                      const SizedBox(height: 8),
                      Text(meal.ingredients!, style: AppTextStyles.description),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text, IconData icon, {bool isOrangeSection = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isOrangeSection ? Colors.white.withOpacity(0.2) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: isOrangeSection ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isOrangeSection ? Colors.white : Colors.orange,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.shortDescription.copyWith(
              color: isOrangeSection ? Colors.white : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return SvgPicture.asset('assets/images/breakfast-icon.svg');
      case 'lunch':
        return SvgPicture.asset('assets/images/lunch-icon.svg');
      case 'dinner':
        return SvgPicture.asset('assets/images/dinner-icon.svg');
      case 'snack_morning':
        return SvgPicture.asset('assets/images/snack-icon.svg');
      case 'snack_afternoon':
        return SvgPicture.asset('assets/images/snack-icon.svg');
      case 'snack_dinner':
        return SvgPicture.asset('assets/images/snack-icon.svg');
      default:
        return Icon(Icons.restaurant, color: AppColors.mainOrange, size: 36);
    }
  }
}
