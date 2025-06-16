// credentials_screen.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';
import 'package:frontendpatient/utils/validators.dart';

class CredentialsScreen extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController repeatPasswordController;

  const CredentialsScreen({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.repeatPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correo electrónico',
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.mainOrange,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Example@gmail.com',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 24),
        Text(
          'Contraseña',
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.mainOrange,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Ingresa tu contraseña',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: Validators.validatePassword,
        ),
        const SizedBox(height: 24),
        Text(
          'Repertir Contraseña',
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.mainOrange,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: repeatPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Ingresa nuevamente tu contraseña',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) => Validators.validateConfirmPassword(
            value,
            passwordController.text,
          ),
        ),
      ],
    );
  }
}