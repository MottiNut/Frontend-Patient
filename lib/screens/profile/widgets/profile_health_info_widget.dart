import 'package:flutter/material.dart';
import 'package:frontendpatient/screens/profile/widgets/profile_info_card_widget.dart';
import 'package:frontendpatient/screens/profile/widgets/profile_info_row_widget.dart';
import 'package:provider/provider.dart';
import '../../../models/user/patient_model.dart';
import '../utils/profile_utils.dart';
import '../controllers/profile_controller.dart';

class HealthInfoCard extends StatelessWidget {
  final Patient patient;

  const HealthInfoCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Información de Salud',
      icon: Icons.favorite,
      color: Colors.red.shade400,
      children: [
        if (patient.height != null)
          InfoRow(
            icon: Icons.height,
            label: 'Altura',
            value: '${patient.height!.toStringAsFixed(1)} cm',
          ),
        if (patient.weight != null)
          InfoRow(
            icon: Icons.monitor_weight,
            label: 'Peso',
            value: '${patient.weight!.toStringAsFixed(1)} kg',
          ),
        if (patient.height != null && patient.weight != null)
          InfoRow(
            icon: Icons.calculate,
            label: 'IMC',
            value: '${patient.calculateBMI()?.toStringAsFixed(1) ?? 'N/A'}',
          ),
        InfoRow(
          icon: Icons.medical_services,
          label: 'Condición Médica',
          value: patient.hasMedicalCondition ? 'Sí' : 'No',
        ),
        if (patient.chronicDisease != null && patient.chronicDisease!.isNotEmpty)
          InfoRow(
            icon: Icons.local_hospital,
            label: 'Enfermedad Crónica',
            value: patient.chronicDisease!,
          ),
        if (patient.allergies != null && patient.allergies!.isNotEmpty)
          InfoRow(
            icon: Icons.warning,
            label: 'Alergias',
            value: patient.allergies!,
          ),
        if (patient.dietaryPreferences != null && patient.dietaryPreferences!.isNotEmpty)
          InfoRow(
            icon: Icons.restaurant,
            label: 'Preferencias Dietéticas',
            value: patient.dietaryPreferences!,
          ),
        if (patient.gender != null && patient.gender!.isNotEmpty)
          InfoRow(
            icon: Icons.person_outline,
            label: 'Género',
            value: patient.gender!,
          ),
      ],
    );
  }
}