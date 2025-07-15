import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MacronutrientsCard extends StatelessWidget {
  final Map<String, num> macronutrients;

  const MacronutrientsCard({
    super.key,
    required this.macronutrients,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.chartPie,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Macronutrientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem(
                  'Proteínas',
                  '${macronutrients['proteins']?.toStringAsFixed(1) ?? '0'}g',
                  Colors.red.shade400,
                  FontAwesomeIcons.dumbbell,
                ),
                _buildMacroItem(
                  'Carbohidratos',
                  '${macronutrients['carbohydrates']?.toStringAsFixed(1) ?? '0'}g',
                  Colors.blue.shade400,
                  FontAwesomeIcons.breadSlice,
                ),
                _buildMacroItem(
                  'Grasas',
                  '${macronutrients['fats']?.toStringAsFixed(1) ?? '0'}g',
                  Colors.amber.shade600,
                  FontAwesomeIcons.droplet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: FaIcon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}