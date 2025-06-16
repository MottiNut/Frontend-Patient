class MealData {
  final String mealType;
  final String mealTypeLabel;
  final String name; // Este será el nombre combinado de los alimentos
  final String? description;
  final int? calories;
  final List<FoodItem>? foods; // Agregar lista de alimentos
  final Map<String, dynamic>? nutritionalInfo;

  MealData({
    required this.mealType,
    required this.mealTypeLabel,
    required this.name,
    this.description,
    this.calories,
    this.foods,
    this.nutritionalInfo,
  });

  factory MealData.fromJson(String mealType, Map<String, dynamic> json) {
    // Extraer los alimentos del array "foods"
    List<FoodItem> foodsList = [];
    String combinedName = 'Comida sin nombre';
    int totalCalories = 0;

    if (json['foods'] != null && json['foods'] is List) {
      foodsList = (json['foods'] as List)
          .map((food) => FoodItem.fromJson(food))
          .toList();

      // Crear nombre combinado de los primeros alimentos
      if (foodsList.isNotEmpty) {
        if (foodsList.length == 1) {
          combinedName = foodsList.first.name;
        } else if (foodsList.length == 2) {
          combinedName = '${foodsList[0].name} + ${foodsList[1].name}';
        } else {
          combinedName = '${foodsList[0].name} + ${foodsList[1].name} y más';
        }
      }
    }

    // Obtener calorías totales
    if (json['total_calories'] != null) {
      totalCalories = json['total_calories'] as int;
    }

    return MealData(
      mealType: mealType,
      mealTypeLabel: _getMealTypeLabel(mealType),
      name: combinedName,
      description: json['description'],
      calories: totalCalories,
      foods: foodsList,
      nutritionalInfo: json['nutritionalInfo'],
    );
  }

  static String _getMealTypeLabel(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return 'Desayuno';
      case 'lunch':
        return 'Almuerzo';
      case 'dinner':
        return 'Cena';
      case 'snacks':
        return 'Snack';
      default:
        return 'Comida';
    }
  }
}

class FoodItem {
  final String name;
  final String quantity;
  final int calories;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.calories,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? 'Alimento sin nombre',
      quantity: json['quantity'] ?? '',
      calories: json['calories'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'calories': calories,
    };
  }
}