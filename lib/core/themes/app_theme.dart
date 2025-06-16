import 'package:flutter/material.dart';

class AppColors {
  static const Color lightOrange = Color(0xFFFFCFAC);
  static const Color mediumOrange = Color(0xFFFFAE73);
  static const Color mainOrange = Color(0xFFFF6C00); // color principal
  static const Color darkOrange1 = Color(0xFFCC5700);
  static const Color darkOrange2 = Color(0xFF994100);
  static const Color darkestOrange = Color(0xFF662B00);

  static const Color whiteBackground = Colors.white;

}

class AppTextStyles {

  static const TextStyle sectionHeaderPrefix = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w300,
    fontSize: 20,
    height: 1.2,
  );

  static const TextStyle profileGreeting = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w400,
    fontSize: 35,
    height: 1.2,
  );

  static const TextStyle tittle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
    fontSize: 29,
    height: 0.42,
  );

  static const TextStyle titleAccompaniment = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w300,
    fontSize: 22,
    height: 1.5, // Aumenta el espacio entre líneas
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.2,
    letterSpacing: 2,
  );

  static const TextStyle description = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w400,
    fontSize: 18,
    height: 1.2,
    letterSpacing: 3,
  );

  static const TextStyle navBar = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
    fontSize: 15,
    height: 1.2,
  );

  static const TextStyle mealCardTitle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.2,
    letterSpacing: 0.02,
  );

  static const TextStyle mealCardSubtitle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.2,
    letterSpacing: 0.02,
  );

  static const TextStyle titleMeals = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w300,
    fontSize: 30,
    height: 0.50,
  );


}