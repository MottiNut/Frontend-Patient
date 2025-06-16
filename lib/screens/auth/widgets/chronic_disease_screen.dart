// chronic_disease_screen.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';

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

  Widget _buildHealthOption(String label, IconData icon) {
    final isSelected = selectedDisease == label;
    return Card(
      color: isSelected ? AppColors.lightOrange : null,
      child: ListTile(
        leading: Icon(icon, color: AppColors.mainOrange),
        title: Text(
          label,
          style: AppTextStyles.description.copyWith(
            letterSpacing: 0,
            fontSize: 16,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check, color: AppColors.mainOrange)
            : null,
        onTap: () {
          onDiseaseChanged(label);
          customDiseaseController.clear();
        },
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '¿Qué condición deseas manejar con tu alimentación?',
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.mainOrange,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Esto nos ayuda a crear un plan seguro y efectivo para ti',
          style: AppTextStyles.description.copyWith(
            color: Colors.grey[600],
            fontSize: 14,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildHealthOption('Diabetes', Icons.bloodtype),
        _buildHealthOption('Hipertensión arterial', Icons.favorite),
        _buildHealthOption('Obesidad o sobrepeso', Icons.monitor_weight),

        // Opción "Otro" con campo de texto
        Card(
          color: isCustomSelected ? AppColors.lightOrange : null,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.more_horiz, color: AppColors.mainOrange),
                title: Text(
                  'Otro...',
                  style: AppTextStyles.description.copyWith(
                    letterSpacing: 0,
                    fontSize: 16,
                  ),
                ),
                trailing: isCustomSelected
                    ? const Icon(Icons.check, color: AppColors.mainOrange)
                    : null,
                onTap: () {
                  if (!isCustomSelected) {
                    onDiseaseChanged('');
                    customDiseaseController.text = '';
                  }
                },
              ),
              // Mostrar campo de texto si "Otro" está seleccionado
              if (isCustomSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextFormField(
                    controller: customDiseaseController,
                    style: AppTextStyles.description.copyWith(
                      fontSize: 16,
                      letterSpacing: 0,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Especifica tu condición',
                      labelStyle: AppTextStyles.description.copyWith(
                        color: AppColors.darkOrange1,
                        fontSize: 14,
                        letterSpacing: 0,
                      ),
                      hintText: 'Ej: Colesterol alto, Gastritis, etc.',
                      hintStyle: AppTextStyles.description.copyWith(
                        color: Colors.grey[500],
                        fontSize: 14,
                        letterSpacing: 0,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.mediumOrange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.mainOrange, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.mediumOrange),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
