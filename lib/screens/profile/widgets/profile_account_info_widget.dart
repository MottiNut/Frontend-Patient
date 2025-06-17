import 'package:flutter/material.dart';
import 'package:frontendpatient/screens/profile/widgets/profile_info_card_widget.dart';
import 'package:frontendpatient/screens/profile/widgets/profile_info_row_widget.dart';
import 'package:provider/provider.dart';
import '../../../models/user/user_model.dart';
import '../utils/profile_utils.dart';
import '../controllers/profile_controller.dart';

class AccountInfoCard extends StatelessWidget {
  final User user;

  const AccountInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Información de Cuenta',
      icon: Icons.account_circle,
      color: Colors.blue.shade600,
      children: [
        InfoRow(
          icon: Icons.badge,
          label: 'ID de Usuario',
          value: user.userId.toString(),
        ),
        InfoRow(
          icon: Icons.calendar_today,
          label: 'Fecha de Registro',
          value: ProfileUtils.formatDate(user.createdAt),
        ),
      ],
    );
  }
}
