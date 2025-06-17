import 'package:flutter/material.dart';
import 'package:frontendpatient/screens/profile/widgets/profile_info_row_widget.dart';
import 'package:provider/provider.dart';
import '../../../models/user/user_model.dart';
import '../utils/profile_utils.dart';
import '../controllers/profile_controller.dart';

class PersonalInfoCard extends StatelessWidget {
  final User user;

  const PersonalInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Información Personal',
      icon: Icons.person,
      color: Colors.orange.shade600,
      children: [
        InfoRow(icon: Icons.email, label: 'Email', value: user.email),
        if (user.phone != null)
          InfoRow(icon: Icons.phone, label: 'Teléfono', value: user.phone!),
        if (user.birthDate != null)
          InfoRow(
            icon: Icons.cake,
            label: 'Fecha de Nacimiento',
            value: ProfileUtils.formatDate(user.birthDate!),
          ),
      ],
    );
  }
}
class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}
