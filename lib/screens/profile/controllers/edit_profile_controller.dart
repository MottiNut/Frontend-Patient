import 'package:flutter/material.dart';
import 'package:frontendpatient/screens/profile/controllers/profile_controller.dart';
import 'package:provider/provider.dart';
import '../../../models/auth/update_profile.dart';
import '../../../models/user/patient_model.dart';
import '../../../providers/auth_provider.dart';

class EditProfileController extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController chronicDiseaseController;
  late TextEditingController allergiesController;
  late TextEditingController dietaryPreferencesController;
  late TextEditingController emergencyContactController;

  bool _hasMedicalCondition = false;
  String? _selectedGender;
  bool _isLoading = false;

  bool get hasMedicalCondition => _hasMedicalCondition;
  String? get selectedGender => _selectedGender;
  bool get isLoading => _isLoading;

  final List<String> genderOptions = ['Masculino', 'Femenino'];

  void initializeControllers(Patient patient) {
    firstNameController = TextEditingController(text: patient.firstName);
    lastNameController = TextEditingController(text: patient.lastName);
    phoneController = TextEditingController(text: patient.phone ?? '');
    heightController = TextEditingController(text: patient.height?.toString() ?? '');
    weightController = TextEditingController(text: patient.weight?.toString() ?? '');
    chronicDiseaseController = TextEditingController(text: patient.chronicDisease ?? '');
    allergiesController = TextEditingController(text: patient.allergies ?? '');
    dietaryPreferencesController = TextEditingController(text: patient.dietaryPreferences ?? '');
    emergencyContactController = TextEditingController(text: patient.emergencyContact ?? '');

    _hasMedicalCondition = patient.hasMedicalCondition;
    _selectedGender = patient.gender;
  }

  void setMedicalCondition(bool value) {
    _hasMedicalCondition = value;
    notifyListeners();
  }

  void setGender(String? value) {
    _selectedGender = value;
    notifyListeners();
  }

  Future<void> saveProfile(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    _isLoading = true;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final request = UpdatePatientProfileRequest(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        height: heightController.text.trim().isEmpty ? null : double.tryParse(heightController.text.trim()),
        weight: weightController.text.trim().isEmpty ? null : double.tryParse(weightController.text.trim()),
        hasMedicalCondition: _hasMedicalCondition,
        chronicDisease: chronicDiseaseController.text.trim().isEmpty ? null : chronicDiseaseController.text.trim(),
        allergies: allergiesController.text.trim().isEmpty ? null : allergiesController.text.trim(),
        dietaryPreferences: dietaryPreferencesController.text.trim().isEmpty ? null : dietaryPreferencesController.text.trim(),
        emergencyContact: emergencyContactController.text.trim().isEmpty ? null : emergencyContactController.text.trim(),
        gender: _selectedGender,
      );

      final success = await authProvider.updatePatientProfile(request);

      if (success && context.mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar(context, 'Perfil actualizado exitosamente');
      } else if (context.mounted) {
        _showErrorSnackBar(context, authProvider.errorMessage ?? 'Error al actualizar el perfil');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error: $e');
      }
    } finally {
      if (hasListeners) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    heightController.dispose();
    weightController.dispose();
    chronicDiseaseController.dispose();
    allergiesController.dispose();
    dietaryPreferencesController.dispose();
    emergencyContactController.dispose();
    super.dispose();
  }
}