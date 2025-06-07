// lib/services/meal_service.dart
import 'dart:convert';
import 'package:frontendpatient/models/meal.dart';
import '../models/api_response_models.dart';
import 'api_service.dart';

class MealService {
  final ApiService _apiService = ApiService();

  /// Obtener todas las comidas
  Future<List<MealResponse>> getMeals() async {
    try {
      final response = await _apiService.get('/meals');
      final List<dynamic> data = json.decode(response.body);

      return data.map((json) => MealResponse.fromJson(json)).toList();
    } catch (e) {
      throw MealException('Error al obtener comidas: $e');
    }
  }

  /// Obtener una comida específica por ID
  Future<MealResponse> getMeal(int mealId) async {
    try {
      final response = await _apiService.get('/meals/$mealId');
      final data = json.decode(response.body);

      return MealResponse.fromJson(data);
    } catch (e) {
      throw MealException('Error al obtener comida: $e');
    }
  }

  /// Crear una nueva comida (solo nutricionistas)
  Future<CreateMealResponse> createMeal(MealCreate mealCreate) async {
    try {
      final response = await _apiService.post(
        '/meals',
        body: mealCreate.toJson(),
      );

      final data = json.decode(response.body);
      return CreateMealResponse.fromJson(data);
    } catch (e) {
      throw MealException('Error al crear comida: $e');
    }
  }

  /// Crear múltiples comidas a la vez (solo nutricionistas)
  Future<BatchMealResponse> createMealsBatch(List<MealCreate> meals) async {
    try {
      final mealsJson = meals.map((meal) => meal.toJson()).toList();

      final response = await _apiService.post(
        '/meals/batch',
        body: {'meals': mealsJson},
      );

      final data = json.decode(response.body);
      return BatchMealResponse.fromJson(data);
    } catch (e) {
      throw MealException('Error al crear comidas en lote: $e');
    }
  }

  /// Buscar comidas por nombre
  Future<List<MealResponse>> searchMeals(String query) async {
    try {
      final allMeals = await getMeals();

      if (query.isEmpty) return allMeals;

      return allMeals.where((meal) {
        return meal.name.toLowerCase().contains(query.toLowerCase()) ||
            (meal.description.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    } catch (e) {
      throw MealException('Error al buscar comidas: $e');
    }
  }

  /// Filtrar comidas por calorías
  Future<List<MealResponse>> filterMealsByCalories({
    int? minCalories,
    int? maxCalories,
  }) async {
    try {
      final allMeals = await getMeals();

      return allMeals.where((meal) {
        if (minCalories != null && meal.calories < minCalories) return false;
        if (maxCalories != null && meal.calories > maxCalories) return false;
        return true;
      }).toList();
    } catch (e) {
      throw MealException('Error al filtrar comidas por calorías: $e');
    }
  }

  /// Filtrar comidas por tiempo de preparación
  Future<List<MealResponse>> filterMealsByPrepTime({
    int? maxPrepTime,
  }) async {
    try {
      final allMeals = await getMeals();

      if (maxPrepTime == null) return allMeals;

      return allMeals.where((meal) {
        return meal.prepTimeMinutes <= maxPrepTime;
      }).toList();
    } catch (e) {
      throw MealException('Error al filtrar comidas por tiempo: $e');
    }
  }

  /// Obtener estadísticas de comidas
  Future<MealStats> getMealStats() async {
    try {
      final meals = await getMeals();

      if (meals.isEmpty) {
        return MealStats(
          totalMeals: 0,
          averageCalories: 0,
          averagePrepTime: 0,
          minCalories: 0,
          maxCalories: 0,
          minPrepTime: 0,
          maxPrepTime: 0,
        );
      }

      final totalCalories = meals.fold<int>(0, (sum, meal) => sum + meal.calories);
      final totalPrepTime = meals.fold<int>(0, (sum, meal) => sum + meal.prepTimeMinutes);

      final calories = meals.map((meal) => meal.calories).toList()..sort();
      final prepTimes = meals.map((meal) => meal.prepTimeMinutes).toList()..sort();

      return MealStats(
        totalMeals: meals.length,
        averageCalories: (totalCalories / meals.length).round(),
        averagePrepTime: (totalPrepTime / meals.length).round(),
        minCalories: calories.first,
        maxCalories: calories.last,
        minPrepTime: prepTimes.first,
        maxPrepTime: prepTimes.last,
      );
    } catch (e) {
      throw MealException('Error al obtener estadísticas: $e');
    }
  }
}

/// Estadísticas de comidas
class MealStats {
  final int totalMeals;
  final int averageCalories;
  final int averagePrepTime;
  final int minCalories;
  final int maxCalories;
  final int minPrepTime;
  final int maxPrepTime;

  MealStats({
    required this.totalMeals,
    required this.averageCalories,
    required this.averagePrepTime,
    required this.minCalories,
    required this.maxCalories,
    required this.minPrepTime,
    required this.maxPrepTime,
  });
}

/// Excepción específica para errores de comidas
class MealException implements Exception {
  final String message;
  MealException(this.message);

  @override
  String toString() => 'MealException: $message';
}