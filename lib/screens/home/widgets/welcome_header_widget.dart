// lib/widgets/patient/welcome_header_widget.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';

class WelcomeHeaderWidget extends StatelessWidget {
  final String patientName;

  const WelcomeHeaderWidget({
    super.key,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hola! $patientName',
      style: AppTextStyles.saludoPerfil,
    );
  }
}