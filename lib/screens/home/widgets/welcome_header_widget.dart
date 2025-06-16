// lib/widgets/patient/welcome_header_widget.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';

class WelcomeHeaderWidget extends StatelessWidget {
  final String patientName;
  final String patientLastName;

  const WelcomeHeaderWidget({
    super.key,
    required this.patientName,
    required this.patientLastName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola!',
          style: AppTextStyles.sectionHeaderPrefix.copyWith(color: Colors.black),
        ),
        Text(
          '$patientName $patientLastName',
          style: AppTextStyles.profileGreeting.copyWith(color: Colors.black),
        ),
      ],
    );
  }
}