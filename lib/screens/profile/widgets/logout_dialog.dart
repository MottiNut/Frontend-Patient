import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/profile_controller.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cerrar Sesión'),
      content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final controller = Provider.of<ProfileController>(context, listen: false);
            await controller.logout(context);
          },
          child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
        )
      ],
    );
  }
}