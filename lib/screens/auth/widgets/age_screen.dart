// age_screen.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';

class AgeScreen extends StatefulWidget {
  final TextEditingController ageController;

  const AgeScreen({
    super.key,
    required this.ageController,
  });

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  final List<int> ages = [27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100];
  int? selectedAge;

  @override
  void initState() {
    super.initState();
    // Inicializar con el valor del controller si existe
    if (widget.ageController.text.isNotEmpty) {
      final currentAge = int.tryParse(widget.ageController.text);
      if (currentAge != null && ages.contains(currentAge)) {
        selectedAge = currentAge;
      }
    }
  }

  void _selectAge(int age) {
    setState(() {
      selectedAge = age;
      // Actualizar el TextEditingController con la edad seleccionada
      widget.ageController.text = age.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '¿Cuál es tu edad?',
          style: AppTextStyles.subtitulo.copyWith(
            color: AppColors.mainOrange,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'El tipo de nutrición varia según tu edad',
          style: AppTextStyles.descripcion.copyWith(
            color: Colors.grey[600],
            fontSize: 14,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 200),
        // Lista horizontal de edades
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ages.length,
            itemBuilder: (context, index) {
              final age = ages[index];
              final isSelected = age == selectedAge;
              return GestureDetector(
                onTap: () => _selectAge(age),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.orange : Colors.grey[200],
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$age',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Años',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}