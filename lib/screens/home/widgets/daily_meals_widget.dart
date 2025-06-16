// lib/screens/patient_home/widgets/daily_meals_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';
import '../../../models/nutrition_plan/daily_plan.dart';
import '../../../models/nutrition_plan/daily_plan_response.dart';
import '../meal_screen.dart';

class DailyMealsWidget extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final DailyPlanResponse? todayPlan;
  final VoidCallback onRetry;

  const DailyMealsWidget({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.todayPlan,
    required this.onRetry,
  });

  // ✅ Método para convertir el Map de meals a una lista de MealData
  List<MealData> _getMealsFromPlan(DailyPlanResponse plan) {
    final List<MealData> meals = [];

    plan.meals.forEach((mealType, mealData) {
      if (mealData is Map<String, dynamic>) {
        meals.add(MealData.fromJson(mealType, mealData));
      }
    });

    // Ordenar las comidas según el tipo
    meals.sort((a, b) {
      const order = {
        'breakfast': 1,
        'snack_morning': 2,
        'lunch': 3,
        'snack_afternoon': 4,
        'dinner': 5,
        'snacks': 6,
        'snack_evening': 7,
      };
      return (order[a.mealType] ?? 99).compareTo(order[b.mealType] ?? 99);
    });

    return meals;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto "Hoy,"
        Text(
          'Hoy,',
          style: AppTextStyles.sectionHeaderPrefix.copyWith(color: Colors.black),
        ),
        const SizedBox(height: 12),
        // Texto "Comidas del Día"
        const Text(
          'Comidas del Día',
          style: AppTextStyles.titleMeals,
        ),

        const SizedBox(height: 12),

        // Contenido
        if (isLoading)
          _buildLoadingState()
        else if (errorMessage != null)
          _buildErrorState(context)
        else if (todayPlan == null || todayPlan!.meals.isEmpty)
            _buildEmptyState()
          else
            _buildMealsContent(context),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando comidas del día...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar las comidas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Ocurrió un error inesperado',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.no_meals,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay comidas programadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contacta con tu nutricionista para obtener tu plan alimentario',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsContent(BuildContext context) {
    final meals = _getMealsFromPlan(todayPlan!);

    return Column(
      children: [
        const SizedBox(height: 16),

        // Lista de comidas con nuevo estilo
        ...meals.map((meal) => _buildMealCard(context, meal)),
      ],
    );
  }


  //Card de comidas
  Widget _buildMealCard(BuildContext context, MealData meal) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MealScreen()),
        );
      },
      child: SizedBox(
        height: 140,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Card alineada a la izquierda con margen a la derecha
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: screenWidth * 0.85, // Ocupa el 83% del ancho
                height: 130,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.mediumOrange,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 0,
                      offset: const Offset(0, 5), // Solo hacia abajo
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Ícono de comida
                    Container(
                      width: 90,
                      height: 90,
                      padding: const EdgeInsets.all(8),
                      child: _getMealIcon(meal.mealType),
                    ),
                    const SizedBox(width: 12),
                    // Línea vertical separadora
                    Container(
                      width: 2,
                      height: 60,
                      color: Colors.white,
                    ),

                    const SizedBox(width: 12),

                    // Información
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            meal.mealTypeLabel,
                            style: AppTextStyles.mealCardTitle.copyWith(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (meal.calories != null)
                            Text(
                              '${meal.calories} kcal',
                              style: AppTextStyles.mealCardSubtitle.copyWith(color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botón circular a la derecha, fuera de la card
            Positioned(
              right: -11,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  'assets/images/right-food-button.svg',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return SvgPicture.asset(
          'assets/images/breakfast-icon.svg',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => Icon(Icons.breakfast_dining, color: _getMealColor(mealType), size: 24),
        );
      case 'lunch':
        return SvgPicture.asset(
          'assets/images/lunch-icon.svg',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => Icon(Icons.lunch_dining, color: _getMealColor(mealType), size: 24),
        );
      case 'dinner':
        return SvgPicture.asset(
          'assets/images/dinner-icon.svg',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => Icon(Icons.dinner_dining, color: _getMealColor(mealType), size: 24),
        );
      case 'snacks':
        return SvgPicture.asset(
          'assets/images/snack-icon.svg',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => Icon(Icons.fastfood, color: _getMealColor(mealType), size: 24),
        );
      default:
        return Icon(Icons.restaurant, color: _getMealColor(mealType), size: 24);
    }
  }

  Color _getMealColor(String mealType) {
    // Usar AppColors.mainOrange si está disponible, si no usar Colors.orange
    try {
      return AppColors.mainOrange;
    } catch (e) {
      return Colors.orange;
    }
  }
}