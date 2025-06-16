
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/themes/app_theme.dart';
import '../../models/nutrition_plan/daily_plan.dart';

class MealDetailScreen extends StatelessWidget {
  final MealData mealDetail;

  const MealDetailScreen({
    super.key,
    required this.mealDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Sección naranja con curva hacia abajo
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
                    // Back button
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Meal title
                    Text(
                      mealDetail.mealTypeLabel,
                      style: AppTextStyles.tittle.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    // Meal icon and calories info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24), // margen horizontal general
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Ícono de comida
                          Container(
                            width: 150,
                            height: 150,
                            padding: const EdgeInsets.only(top: 10),
                            child: _getMealIcon(mealDetail.mealType),
                          ),
                          const SizedBox(width: 24), // más espacio entre ícono y datos
                          // Datos de calorías y alimentos
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildBenefitItem(
                                  '${mealDetail.calories ?? 0} kcal',
                                  Icons.local_fire_department,
                                  isOrangeSection: true,
                                ),
                                const SizedBox(height: 15),
                                _buildBenefitItem(
                                  '${mealDetail.foods?.length ?? 0} alimentos',
                                  Icons.restaurant_menu,
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
          // Sección blanca con contenido
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Alimentos:',
                      style: AppTextStyles.subtitle
                    ),
                    const SizedBox(height: 16),
                    // Lista de alimentos
                    if (mealDetail.foods != null && mealDetail.foods!.isNotEmpty)
                      ...mealDetail.foods!.map((food) => _buildFoodItem(food))
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'No hay información de alimentos disponible',
                          style: AppTextStyles.description,
                        ),
                      ),
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

  Widget _buildFoodItem(FoodItem food) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primera fila: nombre + calorías
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.restaurant,
                color: Colors.orange.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  food.name,
                  style: AppTextStyles.description
                ),
              ),
              Text(
                '${food.calories} kcal',
                style: AppTextStyles.description
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Segunda línea: cantidad
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              food.quantity,
              style: AppTextStyles.description
            ),
          ),
        ],
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