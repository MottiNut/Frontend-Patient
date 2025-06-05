// medical_condition_screen.dart
import 'package:flutter/material.dart';

class MedicalConditionScreen extends StatelessWidget {
  final bool hasMedicalCondition;
  final Function(bool) onConditionChanged;

  const MedicalConditionScreen({
    super.key,
    required this.hasMedicalCondition,
    required this.onConditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información médica',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '¿Padeces alguna enfermedad crónica?',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Switch(
                  value: hasMedicalCondition,
                  onChanged: onConditionChanged,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}