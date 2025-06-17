import 'package:flutter/material.dart';

class MacronutrientsCard extends StatelessWidget {
  final Map<String, num> macronutrients;

  const MacronutrientsCard({
    super.key,
    required this.macronutrients,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Macronutrientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem(
                  'Proteínas',
                  '${macronutrients['proteins']?.toStringAsFixed(1) ?? '0'}g',
                  Colors.red.shade300,
                  Icons.fitness_center,
                ),
                _buildMacroItem(
                  'Carbohidratos',
                  '${macronutrients['carbohydrates']?.toStringAsFixed(1) ?? '0'}g',
                  Colors.blue.shade300,
                  Icons.grain,
                ),
                _buildMacroItem(
                  'Grasas',
                  '${macronutrients['fats']?.toStringAsFixed(1) ?? '0'}g',
                  Colors.yellow.shade600,
                  Icons.opacity,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}