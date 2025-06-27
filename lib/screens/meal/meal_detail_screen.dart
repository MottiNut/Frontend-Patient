import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontendpatient/models/nutrition_plan/daily_plan.dart';
import '../../core/themes/app_theme.dart';

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
          // Header con imagen de fondo
          _buildHeaderSection(context),
          // Sección de información
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      height: 500, // Altura fija para mostrar más de la imagen de fondo
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/food-background.png'),
          fit: BoxFit.cover, // Esto asegura que la imagen cubra todo el contenedor
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Padding normal para el contenido
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(context),
              const SizedBox(height: 4),
              _buildMealTitle(),
              _buildMealSummary(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/vector-retrocession.svg',
            height: 30,
            width: 30,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildMealTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meal.mealTypeLabel,
          style: AppTextStyles.titleAccompaniment.copyWith(color: AppColors.whiteBackground),
        ),
        if (meal.name.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            meal.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: AppTextStyles.tittle.copyWith(
              color: AppColors.whiteBackground,
              height: 1.3, // Añade espacio entre líneas
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMealSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 200, // Altura fija para el Stack
        child: Stack(
          clipBehavior: Clip.none, // Permite que los elementos se salgan del Stack
          children: [
            // Ícono posicionado
            Positioned(
              left: -20, // Más a la izquierda
              bottom: -25, // Más abajo
              child: Container(
                width: 180,
                height: 180,
                padding: const EdgeInsets.only(top: 10),
                child: _getMealIcon(meal.mealType),
              ),
            ),
            // Información nutricional posicionada
            Positioned(
              right: -80, // Ahora funcionará correctamente
              top: 20,
              child: SizedBox(
                width: 180, // Ancho fijo para la información
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
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoSection() {
    return Expanded(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.transparent, // Completamente transparente
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMealDescription(),
              _buildMealIngredients(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMealDescription() {
    if (meal.description == null || meal.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Descripción:', style: AppTextStyles.subtitle),
        const SizedBox(height: 8),
        Text(meal.description!, style: AppTextStyles.description),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMealIngredients() {
    if (meal.ingredients == null || meal.ingredients!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Separar los ingredientes por coma y limpiar espacios
    List<String> ingredientsList = meal.ingredients!
        .split(',')
        .map((ingredient) => ingredient.trim())
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ingredientes:', style: AppTextStyles.subtitle),
        const SizedBox(height: 8),
        ...ingredientsList.map((ingredient) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6.0, right: 8.0),
                width: 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: AppColors.mainOrange,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  ingredient,
                  style: AppTextStyles.description,
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 16),
      ],
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