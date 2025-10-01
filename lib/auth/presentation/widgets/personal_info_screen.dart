import 'package:flutter/material.dart';
import 'package:frontendpatient/commons/themes/app_theme.dart';
import '../../../commons/utils/validators.dart';

class PersonalInfoScreen extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const PersonalInfoScreen({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Nombre'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: firstNameController,
          hint: 'Ingresa tu nombre',
          validator: (value) => Validators.validateName(value, 'El nombre'),
          icon: Icons.person,
        ),
        const SizedBox(height: 20),
        _buildLabel('Apellido'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: lastNameController,
          hint: 'Ingresa tu apellido',
          validator: (value) => Validators.validateName(value, 'El apellido'),
          icon: Icons.badge,
        ),
      ],
    );
  }


  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.subtitle.copyWith(
        color: AppColors.mainOrange,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.grey.shade400,
        ),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppColors.mainOrange,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
