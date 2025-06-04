// screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainOrange,
        elevation: 0,
        title: const Text(
          'NutriApp',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'logout') {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (context .mounted) {
                  Navigator.pushReplacementNamed(context, RouteNames.login);
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final patient = authProvider.currentPatient;

          if (patient == null) {
            return const Center(
              child: Text('Error: No se pudo cargar la información del usuario'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saludo personalizado
                Text(
                  'Hola, ${patient.firstName}! 👋',
                  style: AppTextStyles.saludoPerfil.copyWith(
                    color: AppColors.mainOrange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bienvenido a tu aplicación de nutrición',
                  style: AppTextStyles.acompanamientoTitulo.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Información del usuario
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.lightOrange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.mediumOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.mainOrange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tu Perfil',
                                  style: AppTextStyles.subtitulo.copyWith(
                                    letterSpacing: 0,
                                  ),
                                ),
                                Text(
                                  'Información personal',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Información del usuario
                      _buildInfoRow('Nombre completo', patient.fullName),
                      _buildInfoRow('Email', patient.email),
                      if (patient.phone != null)
                        _buildInfoRow('Teléfono', patient.phone!),
                      if (patient.age != null)
                        _buildInfoRow('Edad', '${patient.age} años'),
                      if (patient.height != null)
                        _buildInfoRow('Altura', '${patient.height} cm'),
                      if (patient.weight != null)
                        _buildInfoRow('Peso', '${patient.weight} kg'),
                      if (patient.chronicDisease != null)
                        _buildInfoRow('Enfermedad Crónica', patient.chronicDisease!),
                      if (patient.allergies != null)
                        _buildInfoRow('Alergias', patient.allergies!),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Próximas funcionalidades
                Text(
                  'Próximamente',
                  style: AppTextStyles.titulo.copyWith(
                    fontSize: 24,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Grid de funcionalidades futuras
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.restaurant_menu,
                      title: 'Plan de Nutrición',
                      description: 'Tu plan personalizado',
                      color: AppColors.mediumOrange,
                    ),
                    _buildFeatureCard(
                      icon: Icons.trending_up,
                      title: 'Progreso',
                      description: 'Seguimiento diario',
                      color: AppColors.darkOrange1,
                    ),
                    _buildFeatureCard(
                      icon: Icons.feedback,
                      title: 'Feedback',
                      description: 'Comunicación directa',
                      color: AppColors.mainOrange,
                    ),
                    _buildFeatureCard(
                      icon: Icons.settings,
                      title: 'Configuración',
                      description: 'Personaliza la app',
                      color: AppColors.darkOrange2,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Mensaje de desarrollo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Esta es la versión inicial de la aplicación. Las funcionalidades adicionales se implementarán próximamente.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}