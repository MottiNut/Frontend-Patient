import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';
import 'package:frontendpatient/screens/auth/widgets/age_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/allergies_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/birth_date_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/chronic_disease_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/credentials_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/gender_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/height_weight_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/medical_condition_screen.dart';
import 'package:frontendpatient/screens/auth/widgets/personal_info_screen.dart';
import 'package:provider/provider.dart';
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
  final _genderController = TextEditingController();
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
  void initState() {
    super.initState();
    // Agregar listeners para actualizar el estado cuando cambien los campos
    _firstNameController.addListener(_updateFormState);
    _lastNameController.addListener(_updateFormState);
    _emailController.addListener(_updateFormState);
    _passwordController.addListener(_updateFormState);
    _repeatPasswordController.addListener(_updateFormState);
    _ageController.addListener(_updateFormState);
    _weightController.addListener(_updateFormState);
    _heightController.addListener(_updateFormState);
    _chronicDiseaseController.addListener(_updateFormState);
    _allergiesController.addListener(_updateFormState);
  }

  void _updateFormState() {
    setState(() {
      // Solo actualizar el estado para refrescar los colores
    });
  }

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

  // Función para verificar si la página actual está completa
  bool _isCurrentPageComplete() {
    switch (_currentPage) {
      case 0: // PersonalInfoScreen
        return _firstNameController.text.trim().isNotEmpty &&
            _lastNameController.text.trim().isNotEmpty;

      case 1: // CredentialsScreen
        return _emailController.text.trim().isNotEmpty &&
            _passwordController.text.trim().isNotEmpty &&
            _repeatPasswordController.text.trim().isNotEmpty &&
            _passwordController.text == _repeatPasswordController.text;

      case 2:
        return formData['gender'] != null && formData['gender'].toString().trim().isNotEmpty;

      case 3: // BirthDateScreen
        return formData['birthDate'] != null;

      case 4: // AgeScreen
        return _ageController.text.trim().isNotEmpty;

      case 5: // HeightWeightScreen
        return _heightController.text.trim().isNotEmpty &&
            _weightController.text.trim().isNotEmpty;

      case 6: // MedicalConditionScreen
        return true; // Esta página siempre es válida (tiene valor por defecto)

      case 7: // ChronicDiseaseScreen
        if (formData['hasMedicalCondition'] == true) {
          // Si tiene condición médica, debe seleccionar algo
          return formData['chronicDisease'] != null && formData['chronicDisease'] != '' ||
              _chronicDiseaseController.text.trim().isNotEmpty;
        }
        return true; // Si no tiene condición médica, es válido

      case 8: // AllergiesScreen
        return formData['allergies'] != null && formData['allergies'] != '' ||
            _allergiesController.text.trim().isNotEmpty;

      default:
        return false;
    }
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
      if (_currentPage < 8) {
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
    print('🚀 Iniciando registro...');
    print('📄 Página actual: $_currentPage');

    if (_validateCurrentPage()) {
      print('✅ Validación de página actual exitosa');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('🔗 AuthProvider obtenido');

      try {
        // Preparar los datos
        final birthDate = formData['birthDate'] as DateTime?;
        final weight = _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null;
        final height = _heightController.text.isNotEmpty
            ? double.tryParse(_heightController.text)
            : null;

        print('📅 Fecha de nacimiento: $birthDate');
        print('⚖️ Peso: $weight');
        print('📏 Altura: $height');

        // Obtener chronicDisease correctamente
        String? chronicDisease;
        if (formData['hasMedicalCondition'] == true) {
          if (formData['chronicDisease'] == 'Diabetes' ||
              formData['chronicDisease'] == 'Hipertensión arterial' ||
              formData['chronicDisease'] == 'Obesidad o sobrepeso') {
            chronicDisease = formData['chronicDisease'];
          }
          else if (_chronicDiseaseController.text.trim().isNotEmpty) {
            chronicDisease = _chronicDiseaseController.text.trim();
          }
        }

        final gender = formData['gender'] as String?;

        // Obtener alergias correctamente
        String? allergies;
        if (formData['allergies'] == 'Gluten' ||
            formData['allergies'] == 'Lactosa' ||
            formData['allergies'] == 'Frutos Secos' ||
            formData['allergies'] == 'Mariscos') {
          allergies = formData['allergies'];
        }
        else if (_allergiesController.text.trim().isNotEmpty) {
          allergies = _allergiesController.text.trim();
        }
        else if (formData['allergies'] == 'Ninguna') {
          allergies = null;
        }

        final bool hasMedicalConditionBool = formData['hasMedicalCondition'] == true;

        print('🏥 Tiene condición médica: $hasMedicalConditionBool');
        print('💊 Enfermedad crónica: $chronicDisease');
        print('🥜 Alergias: $allergies');
        print('👤 Género: $gender');

        // Log de todos los datos que se van a enviar
        print('📝 Datos del registro:');
        print('  - Email: ${_emailController.text.trim()}');
        print('  - Nombre: ${_firstNameController.text.trim()}');
        print('  - Apellido: ${_lastNameController.text.trim()}');
        print('  - Fecha nacimiento: $birthDate');
        print('  - Altura: $height');
        print('  - Peso: $weight');
        print('  - Género: $gender');
        print('  - Condición médica: $hasMedicalConditionBool');
        print('  - Enfermedad crónica: $chronicDisease');
        print('  - Alergias: $allergies');

        print('🌐 Llamando al método registerPatient...');

        final success = await authProvider.registerPatient(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          birthDate: birthDate!,
          phone: '',
          height: height,
          weight: weight,
          hasMedicalCondition: hasMedicalConditionBool,
          chronicDisease: chronicDisease,
          allergies: allergies,
          gender: gender,
          dietaryPreferences: null,
        );

        print('📊 Resultado del registro: $success');

        if (success) {
          print('🎉 Registro exitoso!');
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
          print('❌ Error en el registro');
          print('💬 Mensaje de error: ${authProvider.errorMessage}');

          // Mostrar error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.errorMessage ?? 'Error al registrar usuario'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        print('💥 Error inesperado en _finishRegistration: $e');
        print('📍 Stack trace: ${StackTrace.current}');

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
    } else {
      print('❌ Validación de página falló');
    }
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Botón de retroceso con SVG - siempre visible
          GestureDetector(
            onTap: _currentPage > 0 ? _prevPage : () {
              // Si estamos en la primera página, regresar a la pantalla anterior (login)
              Navigator.of(context).pop();
            },
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 16),
              child: SvgPicture.asset(
                'assets/images/vector-retrocession.svg',
                width: 32,
                height: 32,
              ),
            ),
          ),

          // Barra de progreso
          Expanded(
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / 9,
              backgroundColor: Colors.grey[300],
              color: AppColors.mainOrange,
              minHeight: 6,
            ),
          ),
        ],
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
        return GenderScreen(
          selectedGender: formData['gender'],
          onGenderSelected: (value) => setState(() => formData['gender'] = value),
        );
      case 3:
        return BirthDateScreen(
          selectedDate: formData['birthDate'],
          onDateChanged: (date) => setState(() => formData['birthDate'] = date),
        );
      case 4:
        return AgeScreen(ageController: _ageController);
      case 5:
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
      case 6:
        return MedicalConditionScreen(
          hasMedicalCondition: formData['hasMedicalCondition'],
          onConditionChanged: (value) => setState(() => formData['hasMedicalCondition'] = value),
        );
      case 7:
        return ChronicDiseaseScreen(
          selectedDisease: formData['chronicDisease'],
          customDiseaseController: _chronicDiseaseController,
          onDiseaseChanged: (disease) => setState(() => formData['chronicDisease'] = disease),
        );
      case 8:
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
    // Determinar los colores del botón según si la página está completa
    final bool isPageComplete = _isCurrentPageComplete();
    final Color buttonColor = isPageComplete ? AppColors.mainOrange : const Color(0xFFE5E4E3);
    final Color iconColor = isPageComplete ? AppColors.whiteBackground : const Color(0xFFB2B0B0);

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
                      itemCount: 9,
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
                    mainAxisAlignment: MainAxisAlignment.end, // Cambiar a end para solo mostrar botón de siguiente
                    children: [
                      GestureDetector(
                        onTap: authProvider.isLoading ? null : (isPageComplete ? _nextPage : null),
                        child: Container(
                          width: 73,
                          height: 73,
                          decoration: BoxDecoration(
                            color: buttonColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: authProvider.isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Icon(
                              _currentPage == 8 ? Icons.check : Icons.arrow_forward,
                              color: iconColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Mostrar error si existe
                if (authProvider.errorMessage != null)
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
                            authProvider.errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            authProvider.clearError();
                          },
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