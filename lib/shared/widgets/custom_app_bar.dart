import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/routes/route_names.dart';
import '../../providers/auth_provider.dart';
import 'app_navigation_handler.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;

  const CustomAppBar({
    super.key,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false, // Quita el botón de back automático
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo izquierdo
          SizedBox(
            height: 40,
            width: 40,
            child: SvgPicture.asset(
              'assets/images/vector.svg',
              fit: BoxFit.contain,
            ),
          ),

          // Perfil central con contenedor rectangular
          GestureDetector(
            onTap: () => _showProfileMenu(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/perfil.jpg',
                height: 40,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Icono de notificaciones derecho
          GestureDetector(
            onTap: onNotificationPressed ?? () {
              // Comportamiento por defecto si no se proporciona callback
              debugPrint('Notificaciones presionadas');
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: Colors.orange[600],
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostrar menú de perfil
  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador del modal
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Opciones del menú
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.blue),
              title: const Text('Ver Perfil'),
              onTap: () {
                Navigator.pop(context);
                AppNavigationHandler.handleNavigation(context, 3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _handleLogout(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Manejar cierre de sesión
  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
