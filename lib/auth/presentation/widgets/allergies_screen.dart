import 'package:flutter/material.dart';
import 'package:frontendpatient/commons/themes/app_theme.dart';

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lightOrange : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.mainOrange : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          icon,
          color: isSelected ? AppColors.mainOrange : Colors.grey.shade600,
          size: 28,
        ),
        title: Text(
          label,
          style: AppTextStyles.description.copyWith(
            letterSpacing: 0,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.mainOrange : Colors.black87,
          ),
        ),
        trailing: isSelected
            ? Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.mainOrange,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 18,
          ),
        )
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Tienes alergias o intolerancias?',
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.mainOrange,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu seguridad es primero. Evitaremos estos alimentos',
          style: AppTextStyles.description.copyWith(
            color: Colors.grey[600],
            fontSize: 14,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 24),

        _buildAllergyOption('Gluten', Icons.grain),
        _buildAllergyOption('Lactosa', Icons.local_drink),
        _buildAllergyOption('Frutos Secos', Icons.nature),
        _buildAllergyOption('Mariscos', Icons.set_meal),

        // Opción "Otro" con campo de texto
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isCustomSelected ? AppColors.lightOrange : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCustomSelected ? AppColors.mainOrange : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(
                  Icons.more_horiz,
                  color: isCustomSelected ? AppColors.mainOrange : Colors.grey.shade600,
                  size: 28,
                ),
                title: Text(
                  'Otro...',
                  style: AppTextStyles.description.copyWith(
                    letterSpacing: 0,
                    fontSize: 16,
                    fontWeight: isCustomSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isCustomSelected ? AppColors.mainOrange : Colors.black87,
                  ),
                ),
                trailing: isCustomSelected
                    ? Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.mainOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                )
                    : null,
                onTap: () {
                  if (!isCustomSelected) {
                    onAllergyChanged('');
                    customAllergyController.text = '';
                  }
                },
              ),

              // Campo de texto cuando "Otro" está seleccionado
              if (isCustomSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextFormField(
                    controller: customAllergyController,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.edit_note,
                        color: Colors.grey.shade400,
                      ),
                      labelText: 'Especifica tu alergia o intolerancia',
                      labelStyle: AppTextStyles.description.copyWith(
                        color: AppColors.darkOrange1,
                        fontSize: 14,
                        letterSpacing: 0,
                      ),
                      hintText: 'Ej: Huevos, Soja, Chocolate, etc.',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.mediumOrange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.mainOrange, width: 1.5),
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
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: selectedAllergy == 'Ninguna' ? AppColors.lightOrange : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selectedAllergy == 'Ninguna' ? AppColors.mainOrange : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(
              Icons.check_circle_outline,
              color: selectedAllergy == 'Ninguna' ? AppColors.mainOrange : Colors.grey.shade600,
              size: 28,
            ),
            title: Text(
              'Ninguna',
              style: AppTextStyles.description.copyWith(
                letterSpacing: 0,
                fontSize: 16,
                fontWeight: selectedAllergy == 'Ninguna' ? FontWeight.w600 : FontWeight.w500,
                color: selectedAllergy == 'Ninguna' ? AppColors.mainOrange : Colors.black87,
              ),
            ),
            trailing: selectedAllergy == 'Ninguna'
                ? Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.mainOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 18,
              ),
            )
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