import 'package:flutter/material.dart';
import 'package:frontendpatient/commons/themes/app_theme.dart';
import '../../../commons/utils/validators.dart';

class CredentialsScreen extends StatefulWidget {
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
  State<CredentialsScreen> createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Correo electrónico'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: widget.emailController,
          hint: 'Example@gmail.com',
          validator: Validators.validateEmail,
          icon: Icons.email,
          obscureText: false,
        ),
        const SizedBox(height: 20),
        _buildLabel('Contraseña'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: widget.passwordController,
          hint: 'Ingresa tu contraseña',
          validator: Validators.validatePassword,
          icon: Icons.lock,
          obscureText: _obscurePassword,
          toggleObscure: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildLabel('Repetir Contraseña'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: widget.repeatPasswordController,
          hint: 'Reingresa tu contraseña',
          validator: (value) => Validators.validateConfirmPassword(
            value,
            widget.passwordController.text,
          ),
          icon: Icons.lock,
          obscureText: _obscureRepeatPassword,
          toggleObscure: () {
            setState(() {
              _obscureRepeatPassword = !_obscureRepeatPassword;
            });
          },
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
    bool obscureText = false,
    VoidCallback? toggleObscure,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        suffixIcon: toggleObscure != null
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade500,
          ),
          onPressed: toggleObscure,
        )
            : null,
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
          borderSide: BorderSide(color: AppColors.mainOrange, width: 1.4),
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
