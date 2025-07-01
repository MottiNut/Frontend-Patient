import 'package:flutter/material.dart';
import 'package:frontendpatient/models/auth/update_profile.dart';
import 'package:frontendpatient/models/user/patient_model.dart';
import 'package:frontendpatient/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/app_navigation_handler.dart';

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
    _initializeControllers();
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
              _buildHeader(),
              const Divider(),
              _buildFormFields(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
    );
  }

  Widget _buildFormFields() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Nombre y Apellido
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

            // Teléfono
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Altura y Peso
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

            // Género
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

            // Condición médica
            SwitchListTile(
              title: const Text('¿Tiene condición médica?'),
              value: _hasMedicalCondition,
              onChanged: (value) => setState(() => _hasMedicalCondition = value),
              activeColor: Colors.orange,
            ),
            const SizedBox(height: 16),

            // Enfermedad crónica
            TextFormField(
              controller: _chronicDiseaseController,
              decoration: const InputDecoration(
                labelText: 'Enfermedad Crónica',
                prefixIcon: Icon(Icons.local_hospital),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Alergias
            TextFormField(
              controller: _allergiesController,
              decoration: const InputDecoration(
                labelText: 'Alergias',
                prefixIcon: Icon(Icons.warning),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Preferencias dietéticas
            TextFormField(
              controller: _dietaryPreferencesController,
              decoration: const InputDecoration(
                labelText: 'Preferencias Dietéticas',
                prefixIcon: Icon(Icons.restaurant),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Contacto de emergencia
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
    );
  }
}