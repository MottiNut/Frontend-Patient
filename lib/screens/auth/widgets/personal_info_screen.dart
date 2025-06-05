// personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';
import 'package:frontendpatient/utils/validators.dart';

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
        const SizedBox(height: 10),
        Text(
          'Nombre',
          style: AppTextStyles.subtitulo.copyWith(
            color: AppColors.mainOrange,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: firstNameController,
          decoration: const InputDecoration(
            hintText: 'Ingresa tu nombre',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) => Validators.validateName(value, 'El nombre'),
        ),
        const SizedBox(height: 20),
        Text(
          'Apellido',
          style: AppTextStyles.subtitulo.copyWith(
            color: AppColors.mainOrange,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: lastNameController,
          decoration: const InputDecoration(
            hintText: 'Ingresa tu apellido',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) => Validators.validateName(value, 'El apellido'),
        ),
      ],
    );
  }
}
