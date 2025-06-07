// lib/widgets/meal_detail/meal_icon_widget.dart
import 'package:flutter/material.dart';

class MealIconWidget extends StatelessWidget {
  final String mealType;

  const MealIconWidget({
    super.key,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    switch (mealType) {
      case 'breakfast':
        return Image.asset(
          'assets/images/breakfast-icon.png',
          width: 50,
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.breakfast_dining, color: Colors.red, size: 24);
          },
        );
      case 'lunch':
        return const Icon(Icons.lunch_dining, size: 24);
      case 'dinner':
        return const Icon(Icons.dinner_dining, color: Colors.red, size: 24);
      case 'snack_morning':
      case 'snack_afternoon':
      case 'snack_evening':
        return Image.asset(
          'assets/images/breakfast-icon.png',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.breakfast_dining, color: Colors.red, size: 24);
          },
        );
      default:
        return const Icon(Icons.restaurant, color: Colors.red, size: 24);
    }
  }
}