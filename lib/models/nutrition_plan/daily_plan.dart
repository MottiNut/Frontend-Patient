class MealData {
  final String mealType;
  final String mealTypeLabel;
  final String name;
  final String? description;
  final int? calories;
  final String? ingredients;
  final String? preparationTime;

  MealData({
    required this.mealType,
    required this.mealTypeLabel,
    required this.name,
    this.description,
    this.calories,
    this.ingredients,
    this.preparationTime,
  });

}
class MealTypeMapper {
  static String toKey(String type) {
    switch (type.toLowerCase()) {
      case 'desayuno':
        return 'breakfast';
      case 'media mañana':
        return 'snack_morning';
      case 'almuerzo':
        return 'lunch';
      case 'merienda':
        return 'snack_afternoon';
      case 'cena':
        return 'dinner';
      case 'cena tardia':
        return 'snack_evening';
      default:
        return _normalize(type);
    }
  }

  static String toLabel(String key) {
    switch (key) {
      case 'breakfast':
        return 'Desayuno';
      case 'snack_morning':
        return 'Media Mañana';
      case 'lunch':
        return 'Almuerzo';
      case 'snack_afternoon':
        return 'Merienda';
      case 'dinner':
        return 'Cena';
      case 'snack_dinner':
        return 'Cena Tardía';
      default:
        return _capitalizeWords(key.replaceAll('_', ' '));
    }
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
  }

  static String _capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

