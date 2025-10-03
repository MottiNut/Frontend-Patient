import 'package:flutter/material.dart';
import 'package:frontendpatient/commons/themes/app_theme.dart';

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
        Text(
          '¿Padeces algún tipo de enfermedad?',
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.mainOrange,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Es fundamental contestar de manera sincera ya que a base de eso se arma tu plan nutricional',
          style: AppTextStyles.description.copyWith(
            color: Colors.grey[600],
            fontSize: 13.5,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),


        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionCard('SI', hasMedicalCondition, () {
              onConditionChanged(true);
            }),
            const SizedBox(width: 9),
            _buildOptionCard('NO', !hasMedicalCondition, () {
              onConditionChanged(false);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionCard(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.description.copyWith(
                  letterSpacing: 0,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.whiteBackground : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
