import 'package:flutter/material.dart';

class AppColors {
  static const Color lightOrange = Color(0xFFFFCFAC);
  static const Color mediumOrange = Color(0xFFFFAE73);

  static const Color mainOrange = Color(0xFFFF6C00); // color principal
  static const Color darkOrange1 = Color(0xFFCC5700);
  static const Color darkOrange2 = Color(0xFF994100);
  static const Color darkestOrange = Color(0xFF662B00);

  static const Color primary = Color(0xFFFF6C00);
  static const Color secondary = Color(0xFF00CEDC);
  static const Color checkValidation = Color(0xFF0CB00F);

  static const Color errorIcon = Color(0xFFFF006E);

  static const Color whiteBackground = Colors.white;
  static const Color backgroundLigth = Colors.white;
  static const Color textInput = Colors.grey;
  static const Color surface = Color(0xFFE5E8E5);
  static const Color textDark = Colors.black;
}

class AppTextStyles {
  static const TextStyle sectionHeaderPrefix = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w300,
    fontSize: 20,
    height: 1.2,
  );

  static const TextStyle profileGreeting = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w400,
    fontSize: 35,
    height: 1.2,
  );

  static const TextStyle tittle = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w500,
    fontSize: 29,
    height: 0.42,
  );

  static const TextStyle shortDescription = TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.20,
      letterSpacing: 0.32
  );

  static const TextStyle titleAccompaniment = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w300,
    fontSize: 22,
    height: 1.5, // Aumenta el espacio entre líneas
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 25,
    height: 1.2,
    letterSpacing: 2,
  );

  static const TextStyle description = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w400,
    fontSize: 18,
    height: 1.2,
    letterSpacing: 3,
  );

  static const TextStyle navBar = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w500,
    fontSize: 15,
    height: 1.2,
  );

  static const TextStyle mealCardTitle = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.2,
    letterSpacing: 0.02,
  );

  static const TextStyle mealCardSubtitle = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.2,
    letterSpacing: 0.02,
  );

  static const TextStyle titleMeals = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w300,
    fontSize: 30,
    height: 0.50,
  );
}


class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mainOrange,
        primary: AppColors.mainOrange,
        secondary: AppColors.mediumOrange,
      ),
      fontFamily: 'Montserrat',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.mainOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mainOrange,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.mainOrange,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintStyle: TextStyle(color: Colors.grey[500]),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.whiteBackground,
      iconTheme: const IconThemeData(color: AppColors.mainOrange),
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
        space: 1,
      ),
    );
  }
}