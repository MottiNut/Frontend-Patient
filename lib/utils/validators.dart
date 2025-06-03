// utils/validators.dart
class Validators {
  // Validador de email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es requerido';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido';
    }

    return null;
  }

  // Validador de contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  // Validador de nombre
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.trim().length < 2) {
      return '$fieldName debe tener al menos 2 caracteres';
    }

    return null;
  }

  // Validador de teléfono (opcional)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Es opcional
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{8,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Ingresa un número de teléfono válido';
    }

    return null;
  }

  // Validador de confirmación de contraseña
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  // Validador de edad (basado en fecha de nacimiento)
  static String? validateBirthDate(DateTime? birthDate) {
    if (birthDate == null) {
      return null; // Es opcional
    }

    final now = DateTime.now();
    final age = now.year - birthDate.year;

    if (birthDate.isAfter(now)) {
      return 'La fecha de nacimiento no puede ser futura';
    }

    if (age < 10) {
      return 'Debes tener al menos 10 años';
    }

    if (age > 120) {
      return 'Ingresa una fecha de nacimiento válida';
    }

    return null;
  }

  // Validador de peso
  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Es opcional
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Ingresa un peso válido';
    }

    if (weight < 20 || weight > 300) {
      return 'Ingresa un peso entre 20 y 300 kg';
    }

    return null;
  }

  // Validador de altura
  static String? validateHeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Es opcional
    }

    final height = double.tryParse(value);
    if (height == null) {
      return 'Ingresa una altura válida';
    }

    if (height < 50 || height > 250) {
      return 'Ingresa una altura entre 50 y 250 cm';
    }

    return null;
  }
}