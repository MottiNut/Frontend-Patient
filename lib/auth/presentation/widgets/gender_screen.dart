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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => onGenderSelected(genderValue),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.whiteBackground : Colors.grey.shade600,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  genderLabel,
                  style: AppTextStyles.description.copyWith(
                    letterSpacing: 0,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.whiteBackground : Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
            ],
          ),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Esto nos ayuda a personalizar mejor tu plan nutricional.',
          style: AppTextStyles.description.copyWith(
            color: Colors.grey[600],
            fontSize: 13.5,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _buildGenderOption('Hombre', 'Masculino', Icons.male),
        _buildGenderOption('Mujer', 'Femenino', Icons.female),
      ],
    );
  }
}
