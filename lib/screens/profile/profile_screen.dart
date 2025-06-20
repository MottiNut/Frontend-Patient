import 'package:flutter/material.dart';
import 'package:frontendpatient/core/routes/route_names.dart';
import 'package:frontendpatient/models/user/patient_model.dart';
import 'package:frontendpatient/models/user/role.dart';
import 'package:frontendpatient/models/user/user_model.dart';
import 'package:frontendpatient/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/app_navigation_handler.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/custom_app_bar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppNavigationHandler _navigationHandler = AppNavigationHandler();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _refreshProfile() async {
    setState(() => _isRefreshing = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();
    setState(() => _isRefreshing = false);
  }

  void _showEditDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null || user.role != Role.patient) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se puede editar este profile'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final patient = user as Patient;
    showDialog(
      context: context,
      builder: (BuildContext context) => EditPatientProfileDialog(patient: patient),
    );
  }

  void _showLogoutDialog() => showDialog(
    context: context,
    builder: (BuildContext context) {
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
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, RouteNames.login);
              }
            },
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          )
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(),
    body: Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading || _isRefreshing) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          );
        }

        if (authProvider.errorMessage != null) {
          return _buildErrorWidget(authProvider.errorMessage!, authProvider);
        }

        final user = authProvider.currentUser;
        if (user == null) {
          return const Center(
            child: Text('Error: No se pudo cargar la información del usuario'),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 20),
                _buildPersonalInfoCard(user as Patient),
                const SizedBox(height: 16),
                if (user.role == Role.patient) ...[
                  _buildHealthInfoCard(user),
                  const SizedBox(height: 16),
                ],
                _buildAccountInfoCard(user),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    ),
    bottomNavigationBar: CustomBottomNavBar(
      currentIndex: AppNavigationHandler.currentIndex,
      onTap: (index) => AppNavigationHandler.handleNavigation(context, index),
    ),
  );

  Widget _buildErrorWidget(String error, AuthProvider authProvider) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el profile',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              authProvider.clearError();
              _refreshProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          )
        ],
      ),
    ),
  );

  Widget _buildProfileHeader(User user) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.orange.shade400, Colors.orange.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.orange.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: Text(
            '${user.firstName[0]}${user.lastName[0]}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.fullName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.role == Role.patient ? 'Paciente' : 'Nutricionista',
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
        if (user.birthDate != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_calculateAge(user.birthDate!)} años',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _buildPersonalInfoCard(Patient patient) => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              Text(
                'Información Personal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade600,
                ),
              ),
            ],
          ),
          const Divider(),
          _buildInfoRow(Icons.email, 'Email', patient.email),
          if (patient.phone != null)
            _buildInfoRow(Icons.phone, 'Teléfono', patient.phone!),
          if (patient.birthDate != null)
            _buildInfoRow(Icons.cake, 'Fecha de Nacimiento', _formatDate(patient.birthDate!)),
          if (patient.emergencyContact != null)
            _buildInfoRow(Icons.emergency , 'Contacto de emergencia', patient.emergencyContact!),
        ],
      ),
    ),
  );

  Widget _buildHealthInfoCard(Patient patient) => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red.shade400),
              const SizedBox(width: 8),
              Text(
                'Información de Salud',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
          const Divider(),
          if (patient.height != null)
            _buildInfoRow(Icons.height, 'Altura', '${patient.height!.toStringAsFixed(1)} cm'),
          if (patient.weight != null)
            _buildInfoRow(Icons.monitor_weight, 'Peso', '${patient.weight!.toStringAsFixed(1)} kg'),
          if (patient.height != null && patient.weight != null) ...[
            _buildInfoRow(Icons.calculate, 'IMC', '${patient.calculateBMI()?.toStringAsFixed(1) ?? 'N/A'}'),
          ],
          _buildInfoRow(Icons.medical_services, 'Condición Médica', patient.hasMedicalCondition ? 'Sí' : 'No'),
          if (patient.chronicDisease != null && patient.chronicDisease!.isNotEmpty)
            _buildInfoRow(Icons.local_hospital, 'Enfermedad Crónica', patient.chronicDisease!),
          if (patient.allergies != null && patient.allergies!.isNotEmpty)
            _buildInfoRow(Icons.warning, 'Alergias', patient.allergies!),
          if (patient.dietaryPreferences != null && patient.dietaryPreferences!.isNotEmpty)
            _buildInfoRow(Icons.restaurant, 'Preferencias Dietéticas', patient.dietaryPreferences!),
          if (patient.gender != null && patient.gender!.isNotEmpty)
            _buildInfoRow(Icons.person_outline, 'Género', patient.gender!),
        ],
      ),
    ),
  );

  Widget _buildAccountInfoCard(User user) => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                'Información de Cuenta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const Divider(),
          _buildInfoRow(Icons.badge, 'ID de Usuario', user.userId.toString()),
          _buildInfoRow(Icons.calendar_today, 'Fecha de Registro', _formatDate(user.createdAt)),
        ],
      ),
    ),
  );

  Widget _buildInfoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    ),
  );

  Widget _buildActionButtons() => Column(
    children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showEditDialog,
          icon: const Icon(Icons.edit),
          label: const Text('Editar Perfil'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _showLogoutDialog,
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar Sesión'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    ],
  );

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}