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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          onAllergyChanged(label);
          customAllergyController.clear();
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
        const SizedBox(height: 6),
        Text(
          'Tu seguridad es primero. Evitaremos estos alimentos',
          style: AppTextStyles.description.copyWith(
            color: Colors.grey[600],
            fontSize: 13.5,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 20),

        _buildAllergyOption('Gluten', Icons.grain),
        _buildAllergyOption('Lactosa', Icons.local_drink),
        _buildAllergyOption('Frutos Secos', Icons.nature),
        _buildAllergyOption('Mariscos', Icons.set_meal),

        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: selectedAllergy == 'Ninguna' ? AppColors.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selectedAllergy == 'Ninguna' ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () {
              onAllergyChanged('Ninguna');
              customAllergyController.clear();
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: selectedAllergy == 'Ninguna' ? AppColors.whiteBackground : Colors.grey.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ninguna',
                      style: AppTextStyles.description.copyWith(
                        letterSpacing: 0,
                        fontSize: 16,
                        fontWeight: selectedAllergy == 'Ninguna' ? FontWeight.w700 : FontWeight.w500,
                        color: selectedAllergy == 'Ninguna' ? AppColors.whiteBackground : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

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
                    onAllergyChanged('');
                    customAllergyController.text = '';
                  }
                },
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [

                      Expanded(
                        child: Text(
                          'Otro tipo de alergia',
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


              if (isCustomSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  child: TextFormField(
                    controller: customAllergyController,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.edit_note,
                        color: Colors.grey.shade400,
                        size: 22,
                      ),
                      labelText: 'Especifica tu alergia o intolerancia',
                      labelStyle: AppTextStyles.description.copyWith(
                        color: AppColors.darkOrange1,
                        fontSize: 13,
                        letterSpacing: 0,
                      ),
                      hintText: 'Ej: Huevos, Soja, Chocolate, etc.',
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
      ],
    );
  }
}