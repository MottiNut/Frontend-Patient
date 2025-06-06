// lib/services/meal_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class MealService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Cambia por tu URL

  // Obtener todas las comidas
  static Future<List<Meal>> getMeals(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meals'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((meal) => Meal.fromJson(meal)).toList();
      } else {
        throw Exception('Error al obtener comidas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear una nueva comida (solo nutricionistas)
  static Future<Map<String, dynamic>> createMeal(
      String token, MealCreate meal) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/meals'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(meal.toJson()),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al crear comida');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}