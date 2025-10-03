import 'package:flutter/material.dart';
import 'package:frontendpatient/commons/themes/app_theme.dart';

class ChronicDiseaseScreen extends StatelessWidget {
  final String? selectedDisease;
  final TextEditingController customDiseaseController;
  final Function(String?) onDiseaseChanged;

  const ChronicDiseaseScreen({
    super.key,
    required this.selectedDisease,
    required this.customDiseaseController,
    required this.onDiseaseChanged,
  });

  Widget _buildDiseaseOption(String label, IconData icon) {
    final isSelected = selectedDisease == label;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          onDiseaseChanged(label);
          customDiseaseController.clear();
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  label,
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
    final isCustomSelected = selectedDisease != null &&
        selectedDisease != 'Diabetes' &&
        selectedDisease != 'Hipertensión arterial' &&
        selectedDisease != 'Obesidad o sobrepeso';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Padeces alguna de estas patologías?',
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.mainOrange,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Esto nos ayuda a crear un plan seguro y efectivo para ti',
          style: AppTextStyles.description.copyWith(
            color: Colors.grey[600],
            fontSize: 13.5,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 20),

        _buildDiseaseOption('Diabetes', Icons.bloodtype),
        _buildDiseaseOption('Hipertensión arterial', Icons.favorite),
        _buildDiseaseOption('Obesidad o sobrepeso', Icons.monitor_weight),

        // Opción "Otro" con campo de texto
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isCustomSelected ? AppColors.mediumOrange : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCustomSelected ? AppColors.mediumOrange : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  if (!isCustomSelected) {
                    onDiseaseChanged('');
                    customDiseaseController.text = '';
                  }
                },
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Otra condición médica',
                          style: AppTextStyles.description.copyWith(
                            letterSpacing: 0,
                            fontSize: 15.5,
                            fontWeight: isCustomSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isCustomSelected ? AppColors.whiteBackground : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Campo de texto si selecciona "Otro"
              if (isCustomSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  child: TextFormField(
                    controller: customDiseaseController,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.edit_note,
                        color: Colors.grey.shade400,
                        size: 22,
                      ),
                      labelText: 'Especifica tu condición',
                      labelStyle: AppTextStyles.description.copyWith(
                        color: AppColors.darkOrange1,
                        fontSize: 13,
                        letterSpacing: 0,
                      ),
                      hintText: 'Ej: Colesterol alto, Gastritis, etc.',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.mediumOrange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.mainOrange, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (isCustomSelected && (value == null || value.trim().isEmpty)) {
                        return 'Por favor especifica tu condición médica';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      onDiseaseChanged(value.trim());
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
