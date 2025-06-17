import 'package:flutter/material.dart';
import 'package:frontendpatient/core/routes/route_names.dart';
import 'package:frontendpatient/models/auth/update_profile.dart';
import 'package:frontendpatient/models/user/patient_model.dart';
import 'package:frontendpatient/models/user/role.dart';
import 'package:frontendpatient/models/user/user_model.dart';
import 'package:frontendpatient/providers/auth_provider.dart';
import 'package:frontendpatient/widgets/app_navigation_handler.dart';
import 'package:frontendpatient/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppNavigationHandler _navigationHandler = AppNavigationHandler();
  bool _isRefreshing = false;

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
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Mi Perfil'),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshProfile,
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _showEditDialog,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'logout') _showLogoutDialog();
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Cerrar sesión')
                ],
              ),
            )
          ],
        )
      ],
    ),
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
                _buildPersonalInfoCard(user),
                const SizedBox(height: 16),
                if (user.role == Role.patient) ...[
                  _buildHealthInfoCard(user as Patient),
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
      currentIndex: AppNavigationHandler.currentIndex, // Usar el handler
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

  Widget _buildPersonalInfoCard(User user) => Card(
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
          _buildInfoRow(Icons.email, 'Email', user.email),
          if (user.phone != null)
            _buildInfoRow(Icons.phone, 'Teléfono', user.phone!),
          if (user.birthDate != null)
            _buildInfoRow(Icons.cake, 'Fecha de Nacimiento', _formatDate(user.birthDate!)),
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

class EditPatientProfileDialog extends StatefulWidget {
  final Patient patient;

  const EditPatientProfileDialog({super.key, required this.patient});

  @override
  State<EditPatientProfileDialog> createState() => _EditPatientProfileDialogState();
}

class _EditPatientProfileDialogState extends State<EditPatientProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _chronicDiseaseController;
  late TextEditingController _allergiesController;
  late TextEditingController _dietaryPreferencesController;
  late TextEditingController _emergencyContactController;

  bool _hasMedicalCondition = false;
  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _genderOptions = ['Masculino', 'Femenino'];

  @override
  void initState() {
    super.initState();
    AppNavigationHandler.setCurrentIndex(3); // Establecer índice correcto
  }


  void _initializeControllers() {
    _firstNameController = TextEditingController(text: widget.patient.firstName);
    _lastNameController = TextEditingController(text: widget.patient.lastName);
    _phoneController = TextEditingController(text: widget.patient.phone ?? '');
    _heightController = TextEditingController(text: widget.patient.height?.toString() ?? '');
    _weightController = TextEditingController(text: widget.patient.weight?.toString() ?? '');
    _chronicDiseaseController = TextEditingController(text: widget.patient.chronicDisease ?? '');
    _allergiesController = TextEditingController(text: widget.patient.allergies ?? '');
    _dietaryPreferencesController = TextEditingController(text: widget.patient.dietaryPreferences ?? '');
    _emergencyContactController = TextEditingController(text: widget.patient.emergencyContact ?? '');

    _hasMedicalCondition = widget.patient.hasMedicalCondition;
    _selectedGender = widget.patient.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _chronicDiseaseController.dispose();
    _allergiesController.dispose();
    _dietaryPreferencesController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final request = UpdatePatientProfileRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        height: _heightController.text.trim().isEmpty ? null : double.tryParse(_heightController.text.trim()),
        weight: _weightController.text.trim().isEmpty ? null : double.tryParse(_weightController.text.trim()),
        hasMedicalCondition: _hasMedicalCondition,
        chronicDisease: _chronicDiseaseController.text.trim().isEmpty ? null : _chronicDiseaseController.text.trim(),
        allergies: _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
        dietaryPreferences: _dietaryPreferencesController.text.trim().isEmpty ? null : _dietaryPreferencesController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty ? null : _emergencyContactController.text.trim(),
        gender: _selectedGender,
      );

      final success = await authProvider.updatePatientProfile(request);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Error al actualizar el profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editar Perfil',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.orange.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) => value?.trim().isEmpty == true ? 'Campo requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Apellido',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) => value?.trim().isEmpty == true ? 'Campo requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              decoration: const InputDecoration(
                                labelText: 'Altura (cm)',
                                prefixIcon: Icon(Icons.height),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.trim().isNotEmpty == true) {
                                  final height = double.tryParse(value!);
                                  if (height == null || height <= 0 || height > 300) {
                                    return 'Altura inválida';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              decoration: const InputDecoration(
                                labelText: 'Peso (kg)',
                                prefixIcon: Icon(Icons.monitor_weight),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.trim().isNotEmpty == true) {
                                  final weight = double.tryParse(value!);
                                  if (weight == null || weight <= 0 || weight > 500) {
                                    return 'Peso inválido';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Género',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: _genderOptions.map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedGender = value),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('¿Tiene condición médica?'),
                        value: _hasMedicalCondition,
                        onChanged: (value) => setState(() => _hasMedicalCondition = value),
                        activeColor: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _chronicDiseaseController,
                        decoration: const InputDecoration(
                          labelText: 'Enfermedad Crónica',
                          prefixIcon: Icon(Icons.local_hospital),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _allergiesController,
                        decoration: const InputDecoration(
                          labelText: 'Alergias',
                          prefixIcon: Icon(Icons.warning),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dietaryPreferencesController,
                        decoration: const InputDecoration(
                          labelText: 'Preferencias Dietéticas',
                          prefixIcon: Icon(Icons.restaurant),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emergencyContactController,
                        decoration: const InputDecoration(
                          labelText: 'Contacto de Emergencia',
                          prefixIcon: Icon(Icons.emergency),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}