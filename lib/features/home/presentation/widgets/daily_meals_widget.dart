import 'package:flutter/material.dart';
import 'package:frontendpatient/features/nutrition_plan/domain/models/daily_plan.dart';
import 'package:frontendpatient/features/nutrition_plan/domain/models/meal.dart';
import '../../../../core/themes/app_theme.dart';

class DailyMealsWidget extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final DailyPlan? todayPlan; // Cambiado de DailyPlanResponse a DailyPlan
  final VoidCallback onRetry;

  const DailyMealsWidget({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.todayPlan,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingWidget();
    }

    if (errorMessage != null) {
      return _buildErrorWidget();
    }

    if (todayPlan == null) {
      return _buildNoDataWidget();
    }

    return _buildMealsContent();
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Cargando tu plan de comidas...',
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar las comidas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Ocurrió un error inesperado',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.no_meals_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay datos disponibles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade400,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 16),
        _buildMealsList(),
        const SizedBox(height: 16),
        _buildNutritionalSummary(),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Comidas de Hoy',
          style: AppTextStyles.tittle,
        ),
        Text(
          todayPlan!.dayName,
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.mainOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildMealsList() {
    return Column(
      children: todayPlan!.meals.map((meal) => _buildMealCard(meal)).toList(),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Container(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildMealIcon(meal.type),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getMealTypeLabel(meal.type),
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.mainOrange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meal.name,
                          style: AppTextStyles.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${meal.calories} kcal',
                              style: AppTextStyles.shortDescription,
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.timer,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              meal.preparationTime,
                              style: AppTextStyles.shortDescription,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealIcon(String mealType) {
    IconData iconData;
    Color iconColor = AppColors.mainOrange;

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        iconData = Icons.wb_sunny;
        break;
      case 'lunch':
        iconData = Icons.restaurant;
        break;
      case 'dinner':
        iconData = Icons.dinner_dining;
        break;
      case 'snack_morning':
      case 'snack_afternoon':
      case 'snack_dinner':
        iconData = Icons.local_cafe;
        break;
      default:
        iconData = Icons.restaurant_menu;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildNutritionalSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mainOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mainOrange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen Nutricional',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionalItem(
                'Calorías',
                '${todayPlan!.totalCalories}',
                'kcal',
                Icons.local_fire_department,
              ),
              _buildNutritionalItem(
                'Proteínas',
                '${todayPlan!.macronutrients['protein']?.toStringAsFixed(1) ?? '0'}',
                'g',
                Icons.fitness_center,
              ),
              _buildNutritionalItem(
                'Carbohidratos',
                '${todayPlan!.macronutrients['carbs']?.toStringAsFixed(1) ?? '0'}',
                'g',
                Icons.grain,
              ),
              _buildNutritionalItem(
                'Grasas',
                '${todayPlan!.macronutrients['fats']?.toStringAsFixed(1) ?? '0'}',
                'g',
                Icons.opacity,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionalItem(
      String label,
      String value,
      String unit,
      IconData icon,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.mainOrange,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.subtitle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: AppTextStyles.shortDescription,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.shortDescription,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getMealTypeLabel(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Desayuno';
      case 'lunch':
        return 'Almuerzo';
      case 'dinner':
        return 'Cena';
      case 'snack_morning':
        return 'Snack Mañana';
      case 'snack_afternoon':
        return 'Snack Tarde';
      case 'snack_dinner':
        return 'Snack Noche';
      default:
        return mealType;
    }
  }
}