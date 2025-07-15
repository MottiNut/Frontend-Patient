import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';

class GenderScreen extends StatelessWidget {
  final String? selectedGender;
  final Function(String) onGenderSelected;

  const GenderScreen({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  Widget _buildGenderOption(String genderLabel, String genderValue, IconData icon) {
    final isSelected = selectedGender == genderValue;
    return Card(
      color: isSelected ? AppColors.lightOrange : null,
      child: ListTile(
        leading: Icon(icon, color: AppColors.mainOrange),
        title: Text(
          genderLabel,
          style: AppTextStyles.description.copyWith(
            letterSpacing: 0,
            fontSize: 16,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check, color: AppColors.mainOrange)
            : null,
        onTap: () {
          onGenderSelected(genderValue);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '¿Cuál es tu género?',
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.mainOrange,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Esto nos ayuda a personalizar mejor tu plan nutricional.',
          style: AppTextStyles.description.copyWith(
            color: Colors.grey[600],
            fontSize: 14,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildGenderOption('Hombre', 'Masculino', Icons.male),
        _buildGenderOption('Mujer', 'Femenino', Icons.female),
      ],
    );
  }
}
