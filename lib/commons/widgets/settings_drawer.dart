import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../routes/route_names.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey.shade100,
        child: Column(
          children: [
            // Header con perfil del usuario
            _buildDrawerHeader(),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección: Soporte
                    _buildSectionHeader('Soporte', Icons.help_outline),
                    const SizedBox(height: 8),
                    _buildSettingsCard([
                      _buildSettingItem(
                        icon: Icons.quiz_outlined,
                        title: 'Ayuda y preguntas frecuentes',
                        subtitle: 'Centro de ayuda',
                        onTap: () => _navigateToHelp(),
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        icon: Icons.contact_support_outlined,
                        title: 'Contactar soporte',
                        subtitle: 'Asistencia técnica',
                        onTap: () => _navigateToSupport(),
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        icon: Icons.star_outline,
                        title: 'Calificar la aplicación',
                        subtitle: 'Valorar en la tienda',
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Sección: Acerca de
                    _buildSectionHeader('Acerca de', Icons.info),
                    const SizedBox(height: 8),
                    _buildSettingsCard([
                      _buildSettingItem(
                        icon: Icons.info_outlined,
                        title: 'Sobre la aplicación',
                        subtitle: 'Versión 1.0.0',
                        onTap: () => _navigateToAbout(),
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        icon: Icons.description_outlined,
                        title: 'Términos y condiciones',
                        subtitle: 'Política de uso',
                        onTap: () => _navigateToTerms(),
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Política de privacidad',
                        subtitle: 'Protección de datos',
                        onTap: () => _navigateToPrivacyPolicy(),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Botón de Cerrar Sesión
                    _buildLogoutButton(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final userName = user != null ? '${user.firstName} ${user.lastName}' : 'Usuario';
        final userEmail = user?.email ?? 'sin email';
        final userInitial = user?.firstName?.isNotEmpty == true
            ? user!.firstName[0].toUpperCase()
            : 'U';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          decoration: BoxDecoration(
            color: Colors.orange[600],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange[600]!,
                Colors.orange[400]!,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nombre
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),

              // Email
              Text(
                userEmail,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange[600]!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.orange[600],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing ?? Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.1),
      indent: 60,
      endIndent: 20,
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _showLogoutDialog(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.logout,
            color: Colors.red,
            size: 20,
          ),
        ),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: const Text(
          'Salir de la aplicación',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Cerrar el drawer
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  // Métodos de navegación
  void _navigateToHelp() {
    Navigator.of(context).pop(); // Cerrar drawer
    // Implementar navegación a pantalla de ayuda
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de ayuda próximamente')),
    );
  }

  void _navigateToSupport() {
    Navigator.of(context).pop(); // Cerrar drawer
    // Implementar navegación a soporte
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de soporte próximamente')),
    );
  }

  void _navigateToAbout() {
    Navigator.of(context).pop(); // Cerrar drawer
    // Implementar navegación a about
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Acerca de la aplicación próximamente')),
    );
  }

  void _navigateToTerms() {
    Navigator.of(context).pop(); // Cerrar drawer
    // Implementar navegación a términos y condiciones
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Términos y condiciones próximamente')),
    );
  }

  void _navigateToPrivacyPolicy() {
    Navigator.of(context).pop(); // Cerrar drawer
    // Implementar navegación a política de privacidad
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Política de privacidad próximamente')),
    );
  }

  void _performLogout() async {
    try {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.login,
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}