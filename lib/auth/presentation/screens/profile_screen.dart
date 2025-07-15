import 'package:flutter/material.dart';
import 'package:frontendpatient/commons/routes/route_names.dart';
import 'package:frontendpatient/auth/domain/models/patient.dart';
import 'package:frontendpatient/auth/domain/models/role.dart';
import 'package:frontendpatient/auth/domain/models/user.dart';
import 'package:frontendpatient/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../commons/widgets/custom_app_bar.dart';
import '../../../commons/widgets/settings_drawer.dart';
import 'edit_profile_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Removido _loadStats() ya que estaba vacío
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
          content: Text('Error: No se puede editar este perfil'),
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

  ImageProvider? _getProfileImage(User user) {
    if (user is Patient && user.profileImageBase64 != null && user.profileImageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(user.profileImageBase64!);
        return MemoryImage(bytes);
      } catch (e) {
        print('Error decodificando imagen base64: $e');
        return null;
      }
    }
    return null;
  }

  void _showImageOptions() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isUpdatingImage) return;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 60,
      );

      if (image != null) {
        final imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();

        // Verificar tamaño (5MB máximo)
        if (bytes.length > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La imagen es demasiado grande. Por favor, selecciona una imagen más pequeña.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        await _updateProfileImage(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfileImage(File imageFile) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.updatePatientProfileImage(imageFile);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar imagen: ${authProvider.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey.shade100,
    appBar: const CustomAppBar(),
    drawer: SizedBox(
      width: MediaQuery.of(context).size.width * 0.85, // 85% del ancho de la pantalla
      child: const SettingsDrawer(),
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

        final patient = user as Patient;

        return RefreshIndicator(
          onRefresh: _refreshProfile,
          color: Colors.orange,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header del perfil
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.orange,
                        Colors.orange.withOpacity(0.8),
                        Colors.orange.shade300,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // FOTO DE PERFIL
                      Stack(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: _buildProfileImage(user),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: _showImageOptions,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          if (authProvider.isUpdatingImage)
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Nombre
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Paciente',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Botón de editar en el header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildHeaderButton(
                          icon: Icons.edit,
                          label: 'Editar',
                          onPressed: _showEditDialog,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // CONTENIDO DEL PERFIL
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonalInfoSection(patient),
                      const SizedBox(height: 12),
                      _buildHealthInfoSection(patient),
                      const SizedBox(height: 12),
                      _buildAccountInfoSection(user),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(User user) {
    final imageProvider = _getProfileImage(user);

    if (imageProvider != null) {
      return Image(
        image: imageProvider,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar(user);
        },
      );
    }

    return _buildDefaultAvatar(user);
  }

  Widget _buildDefaultAvatar(User user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.7),
            Colors.orange,
          ],
        ),
      ),
      child: Center(
        child: Text(
          '${user.firstName[0]}${user.lastName[0]}',
          style: const TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(Patient patient) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Información Personal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.email_outlined, 'Email', patient.email),
          if (patient.phone != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.phone_outlined, 'Teléfono', patient.phone!),
          ],
          if (patient.birthDate != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.cake_outlined, 'Fecha de Nacimiento', _formatDate(patient.birthDate!)),
          ],
          if (patient.gender != null && patient.gender!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person_outline, 'Género', patient.gender!),
          ],
          if (patient.emergencyContact != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.emergency_outlined, 'Contacto de emergencia', patient.emergencyContact!),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthInfoSection(Patient patient) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Información de Salud',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (patient.height != null) ...[
            _buildInfoRow(Icons.height_outlined, 'Altura', '${patient.height!.toStringAsFixed(1)} cm'),
            const SizedBox(height: 16),
          ],
          if (patient.weight != null) ...[
            _buildInfoRow(Icons.monitor_weight_outlined, 'Peso', '${patient.weight!.toStringAsFixed(1)} kg'),
            const SizedBox(height: 16),
          ],
          if (patient.height != null && patient.weight != null) ...[
            _buildInfoRow(Icons.calculate_outlined, 'IMC', '${patient.calculateBMI()?.toStringAsFixed(1) ?? 'N/A'}'),
            const SizedBox(height: 16),
          ],
          _buildInfoRow(Icons.medical_services_outlined, 'Condición Médica', patient.hasMedicalCondition ? 'Sí' : 'No'),
          if (patient.chronicDisease != null && patient.chronicDisease!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.local_hospital_outlined, 'Enfermedad Crónica', patient.chronicDisease!),
          ],
          if (patient.allergies != null && patient.allergies!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.warning_outlined, 'Alergias', patient.allergies!),
          ],
          if (patient.dietaryPreferences != null && patient.dietaryPreferences!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.restaurant_outlined, 'Preferencias Dietéticas', patient.dietaryPreferences!),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_circle_outlined,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Información de Cuenta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.badge_outlined, 'ID de Usuario', user.userId.toString()),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today_outlined, 'Fecha de Registro', _formatDate(user.createdAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? textColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.orange, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
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
  }

  Widget _buildErrorWidget(String error, AuthProvider authProvider) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el perfil',
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}