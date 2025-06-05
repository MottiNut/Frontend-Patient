import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';
import 'package:frontendpatient/screens/auth/widgets/age_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/allergies_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/birth_date_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/chronic_disease_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/credentials_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/height_weight_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/medical_condition_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/personal_info_screen.dart';

import 'package:provider/provider.dart';
import 'package:frontendpatient/utils/validators.dart';
import 'package:frontendpatient/providers/auth_provider.dart';

class RegisterFlow extends StatefulWidget {
  const RegisterFlow({super.key});

  @override
  State<RegisterFlow> createState() => _RegisterFlowState();
}

class _RegisterFlowState extends State<RegisterFlow> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;

  // Controladores para los campos de texto
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _chronicDiseaseController = TextEditingController();
  final _allergiesController = TextEditingController();

  // Datos del formulario
  final Map<String, dynamic> formData = {
    'firstName': '',
    'lastName': '',
    'email': '',
    'password': '',
    'repeatPassword': '',
    'birthDate': null,
    'age': '',
    'weight': '',
    'height': '',
    'hasMedicalCondition': false,
    'chronicDisease': '',
    'allergies': '',
  };

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _chronicDiseaseController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  bool _validateCurrentPage() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      return true;
    }
    return false;
  }

  void _nextPage() {
    if (_validateCurrentPage()) {
      if (_currentPage < 7) {
        setState(() => _currentPage++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _finishRegistration();
      }
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishRegistration() async {
    if (_validateCurrentPage()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        // Preparar los datos
        final birthDate = formData['birthDate'] as DateTime?;
        final weight = _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null;
        final height = _heightController.text.isNotEmpty
            ? double.tryParse(_heightController.text)
            : null;

        // CORRECCIÓN: Obtener chronicDisease correctamente
        String? chronicDisease;
        if (formData['hasMedicalCondition'] == true) {
          // Si es una opción predefinida, usar el valor de formData
          if (formData['chronicDisease'] == 'Diabetes' ||
              formData['chronicDisease'] == 'Hipertensión arterial' ||
              formData['chronicDisease'] == 'Obesidad o sobrepeso') {
            chronicDisease = formData['chronicDisease'];
          }
          // Si es "Otro" (campo de texto), usar el valor del controlador
          else if (_chronicDiseaseController.text.trim().isNotEmpty) {
            chronicDisease = _chronicDiseaseController.text.trim();
          }
        }

        // Obtener alergias correctamente
        String? allergies;
        if (formData['allergies'] == 'Gluten' ||
            formData['allergies'] == 'Lactosa' ||
            formData['allergies'] == 'Frutos Secos' ||
            formData['allergies'] == 'Mariscos') {
          allergies = formData['allergies'];
        }
        // Si es "Otro" (campo de texto), usar el valor del controlador
        else if (_allergiesController.text.trim().isNotEmpty) {
          allergies = _allergiesController.text.trim();
        }
        // Si seleccionó "Ninguna", enviamos null
        else if (formData['allergies'] == 'Ninguna') {
          allergies = null;
        }

        // Llamar al servicio de registro
        final success = await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          hasMedicalCondition: formData['hasMedicalCondition'] ?? false,
          chronicDisease: chronicDisease,
          birthDate: birthDate,
          height: height,
          weight: weight,
          allergies: allergies,
        );

        if (success) {
          // Mostrar mensaje de éxito
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Registro completado exitosamente!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // Navegar de vuelta al login después de un breve delay
            await Future.delayed(const Duration(seconds: 1));
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
        } else {
          // Mostrar error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.error ?? 'Error al registrar usuario'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        // Manejar errores inesperados
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error inesperado: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: LinearProgressIndicator(
        value: (_currentPage + 1) / 8,
        backgroundColor: Colors.grey[300],
        color: AppColors.mainOrange,
        minHeight: 6,
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return PersonalInfoScreen(
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
        );
      case 1:
        return CredentialsScreen(
          emailController: _emailController,
          passwordController: _passwordController,
          repeatPasswordController: _repeatPasswordController,
        );
      case 2:
        return BirthDateScreen(
          selectedDate: formData['birthDate'],
          onDateChanged: (date) => setState(() => formData['birthDate'] = date),
        );
      case 3:
        return AgeScreen(ageController: _ageController);
      case 4:
        return HeightWeightScreen(
          initialHeight: _heightController.text.isNotEmpty
              ? double.tryParse(_heightController.text)! / 100
              : null,
          initialWeight: _weightController.text.isNotEmpty
              ? int.tryParse(_weightController.text)
              : null,
          onValuesChanged: (height, weight) {
            setState(() {
              _heightController.text = (height * 100).toInt().toString();
              _weightController.text = weight.toString();
              formData['height'] = (height * 100).toInt().toString();
              formData['weight'] = weight.toString();
            });
          },
        );
      case 5:
        return MedicalConditionScreen(
          hasMedicalCondition: formData['hasMedicalCondition'],
          onConditionChanged: (value) => setState(() => formData['hasMedicalCondition'] = value),
        );
      case 6:
        return ChronicDiseaseScreen(
          selectedDisease: formData['chronicDisease'],
          customDiseaseController: _chronicDiseaseController,
          onDiseaseChanged: (disease) => setState(() => formData['chronicDisease'] = disease),
        );
      case 7:
        return AllergiesScreen(
          selectedAllergy: formData['allergies'],
          customAllergyController: _allergiesController,
          onAllergyChanged: (allergy) => setState(() => formData['allergies'] = allergy),
        );
      default:
        return const Text('Registro finalizado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 8,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: SingleChildScrollView(
                          child: _buildPage(index),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        TextButton.icon(
                          onPressed: authProvider.isLoading ? null : _prevPage,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Atrás'),
                        )
                      else
                        const SizedBox(),
                      ElevatedButton.icon(
                        onPressed: authProvider.isLoading ? null : _nextPage,
                        icon: authProvider.isLoading && _currentPage == 7
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Icon(_currentPage == 7 ? Icons.check : Icons.arrow_forward),
                        label: Text(_currentPage == 7 ? 'Finalizar' : 'Siguiente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainOrange,
                          foregroundColor: AppColors.whiteBackground,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                // Mostrar error si existe
                if (authProvider.error != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authProvider.error!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => authProvider.clearError(),
                          icon: Icon(Icons.close, color: Colors.red.shade600, size: 18),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}