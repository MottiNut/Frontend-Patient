import 'dart:core';

class ProfileUtils {
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static String? validateHeight(String? value) {
    if (value?.trim().isNotEmpty == true) {
      final height = double.tryParse(value!);
      if (height == null || height <= 0 || height > 300) {
        return 'Altura inválida';
      }
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value?.trim().isNotEmpty == true) {
      final weight = double.tryParse(value!);
      if (weight == null || weight <= 0 || weight > 500) {
        return 'Peso inválido';
      }
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    return value?.trim().isEmpty == true ? '$fieldName es requerido' : null;
  }
}