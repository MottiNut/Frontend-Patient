// allergies_screen.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';

class AllergiesScreen extends StatelessWidget {
  final String? selectedAllergy;
  final TextEditingController customAllergyController;
  final Function(String?) onAllergyChanged;

  const AllergiesScreen({
    super.key,
    required this.selectedAllergy,
    required this.customAllergyController,
    required this.onAllergyChanged,
  });

  Widget _buildAllergyOption(String label, IconData icon) {
    final isSelected = selectedAllergy == label;
    return Card(
      color: isSelected ? AppColors.lightOrange : null,
      child: ListTile(
        leading: Icon(icon, color: AppColors.mainOrange),
        title: Text(
          label,
          style: AppTextStyles.descripcion.copyWith(
            letterSpacing: 0,
            fontSize: 16,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check, color: AppColors.mainOrange)
            : null,
        onTap: () {
          onAllergyChanged(label);
          customAllergyController.clear();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustomSelected = selectedAllergy != null &&
        selectedAllergy != 'Gluten' &&
        selectedAllergy != 'Lactosa' &&
        selectedAllergy != 'Frutos Secos' &&
        selectedAllergy != 'Mariscos' &&
        selectedAllergy != 'Ninguna';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Text(
          '¿Tienes alergias o intolerancias?',
          style: AppTextStyles.subtitulo.copyWith(
            color: AppColors.mainOrange,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Tu seguridad es primero. Evitaremos estos alimentos',
          style: AppTextStyles.descripcion.copyWith(
            color: Colors.grey[600],
            fontSize: 14,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildAllergyOption('Gluten', Icons.grain),
        _buildAllergyOption('Lactosa', Icons.local_drink),
        _buildAllergyOption('Frutos Secos', Icons.nature),
        _buildAllergyOption('Mariscos', Icons.set_meal),

        // Opción "Otro" con campo de texto
        Card(
          color: isCustomSelected ? AppColors.lightOrange : null,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.more_horiz, color: AppColors.mainOrange),
                title: Text(
                  'Otro...',
                  style: AppTextStyles.descripcion.copyWith(
                    letterSpacing: 0,
                    fontSize: 16,
                  ),
                ),
                trailing: isCustomSelected
                    ? const Icon(Icons.check, color: AppColors.mainOrange)
                    : null,
                onTap: () {
                  if (!isCustomSelected) {
                    onAllergyChanged('');
                    customAllergyController.text = '';
                  }
                },
              ),
              // Mostrar campo de texto si "Otro" está seleccionado
              if (isCustomSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextFormField(
                    controller: customAllergyController,
                    style: AppTextStyles.descripcion.copyWith(
                      fontSize: 16,
                      letterSpacing: 0,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Especifica tu alergia o intolerancia',
                      labelStyle: AppTextStyles.descripcion.copyWith(
                        color: AppColors.darkOrange1,
                        fontSize: 14,
                        letterSpacing: 0,
                      ),
                      hintText: 'Ej: Huevos, Soja, Chocolate, etc.',
                      hintStyle: AppTextStyles.descripcion.copyWith(
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
                        return 'Por favor especifica tu alergia o intolerancia';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      onAllergyChanged(value.trim());
                    },
                  ),
                ),
            ],
          ),
        ),

        // Opción "Ninguna"
        Card(
          color: selectedAllergy == 'Ninguna' ? AppColors.lightOrange : null,
          child: ListTile(
            leading: const Icon(Icons.check_circle_outline, color: AppColors.mainOrange),
            title: Text(
              'Ninguna',
              style: AppTextStyles.descripcion.copyWith(
                letterSpacing: 0,
                fontSize: 16,
              ),
            ),
            trailing: selectedAllergy == 'Ninguna'
                ? const Icon(Icons.check, color: AppColors.mainOrange)
                : null,
            onTap: () {
              onAllergyChanged('Ninguna');
              customAllergyController.clear();
            },
          ),
        ),
      ],
    );
  }
}