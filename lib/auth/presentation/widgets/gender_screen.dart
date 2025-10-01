import 'package:flutter/material.dart';
import 'package:frontendpatient/commons/themes/app_theme.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.mainOrange : Colors.grey.shade100,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          elevation: isSelected ? 4 : 0,
        ),
        onPressed: () => onGenderSelected(genderValue),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade700,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                genderLabel,
                style: AppTextStyles.description.copyWith(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
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
