import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontendpatient/commons/themes/app_theme.dart';
import 'package:frontendpatient/auth/presentation/widgets/allergies_screen.dart';
import 'package:frontendpatient/auth/presentation/widgets/birth_date_screen.dart';
import 'package:frontendpatient/auth/presentation/widgets/chronic_disease_screen.dart';
import 'package:frontendpatient/auth/presentation/widgets/credentials_screen.dart';
import 'package:frontendpatient/auth/presentation/widgets/gender_screen.dart';
import 'package:frontendpatient/auth/presentation/widgets/height_weight_screen.dart';
import 'package:frontendpatient/auth/presentation/widgets/medical_condition_screen.dart';
import 'package:frontendpatient/auth/presentation/widgets/personal_info_screen.dart';
import 'package:frontendpatient/commons/routes/route_names.dart';
import 'package:provider/provider.dart';
import 'package:frontendpatient/auth/presentation/providers/auth_provider.dart';

import '../../../commons/services/secure_storage_service.dart';
import '../../../commons/widgets/requestSnacbar/snackBar_manager.dart';

class RegisterFlow extends StatefulWidget {
  const RegisterFlow({super.key});

  @override
  State<RegisterFlow> createState() => _RegisterFlowState();
}

class _RegisterFlowState extends State<RegisterFlow> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;
  bool _isRegistering = false;

  final _storageService = SecureStorageService();

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
    'gender': null,
  };

  @override
  void initState() {
    super.initState();
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
    if (mounted) setState(() {});
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
    _pageController.dispose();
    super.dispose();
  }

  bool _isCurrentPageComplete() {
    switch (_currentPage) {
      case 0:
        return _firstNameController.text.trim().isNotEmpty &&
            _lastNameController.text.trim().isNotEmpty;
      case 1:
        return _emailController.text.trim().isNotEmpty &&
            _passwordController.text.trim().isNotEmpty &&
            _repeatPasswordController.text.trim().isNotEmpty &&
            _passwordController.text == _repeatPasswordController.text;
      case 2:
        return formData['gender'] != null && formData['gender'].toString().trim().isNotEmpty;
      case 3:
        return formData['birthDate'] != null;
      case 4:
        return _heightController.text.trim().isNotEmpty &&
            _weightController.text.trim().isNotEmpty;
      case 5:
        return true;
      case 6:
        if (formData['hasMedicalCondition'] == true) {
          return formData['chronicDisease'] != null && formData['chronicDisease'] != '' ||
              _chronicDiseaseController.text.trim().isNotEmpty;
        }
        return true;
      case 7:
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
    } else {
      // Si está en la primera página, volver al login
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
    }
  }

  // Manejar el botón de retroceso del sistema
  Future<bool> _onWillPop() async {
    if (_isRegistering) {
      // No permitir retroceso mientras se está registrando
      return false;
    }

    if (_currentPage > 0) {
      // Si no está en la primera página, retroceder una página
      _prevPage();
      return false; // No salir de la pantalla
    } else {
      // Si está en la primera página, volver al login
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
      return false; // No usar el pop por defecto
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainOrange),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Creando cuenta...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _finishRegistration() async {
    if (!_validateCurrentPage() || _isRegistering) {
      debugPrint('❌ Validación falló o ya está registrando');
      return;
    }

    setState(() => _isRegistering = true);
    _showLoadingDialog();

    try {
      final birthDate = formData['birthDate'] as DateTime?;
      if (birthDate == null) throw Exception('Fecha de nacimiento requerida');

      final weight = _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null;

      final height = _heightController.text.isNotEmpty
          ? double.tryParse(_heightController.text)
          : null;

      String? chronicDisease;
      if (formData['hasMedicalCondition'] == true) {
        final allowedDiseases = ['Diabetes', 'Hipertensión arterial', 'Obesidad o sobrepeso'];
        chronicDisease = allowedDiseases.contains(formData['chronicDisease'])
            ? formData['chronicDisease']
            : (_chronicDiseaseController.text.trim().isNotEmpty
            ? _chronicDiseaseController.text.trim()
            : null);
      }

      final gender = formData['gender'] as String?;
      final allowedAllergies = ['Gluten', 'Lactosa', 'Frutos Secos', 'Mariscos'];
      String? allergies;
      if (formData['allergies'] == 'Ninguna') {
        allergies = null;
      } else {
        allergies = allowedAllergies.contains(formData['allergies'])
            ? formData['allergies']
            : (_allergiesController.text.trim().isNotEmpty
            ? _allergiesController.text.trim()
            : null);
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.registerPatient(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: birthDate,
        phone: null,
        height: height,
        weight: weight,
        hasMedicalCondition: formData['hasMedicalCondition'] == true,
        chronicDisease: chronicDisease,
        allergies: allergies,
        gender: gender,
        dietaryPreferences: null,
      );

      if (mounted) Navigator.of(context).pop();

      if (success && authProvider.isVerificationPending) {

        try {
          await _storageService.saveSavedEmail(_emailController.text.trim());
          await _storageService.saveRememberMe(true);
          debugPrint('✅ Email guardado para próximo login');
        } catch (e) {
          debugPrint('⚠️ Error guardando email (no crítico): $e');
        }

        if (mounted) {
          SnackBarManager.showSuccess(
              context,
              'Registro exitoso. Se ha enviado un código de verificación a ${_emailController.text.trim()}'
          );
        }

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RouteNames.codeVerification,
            arguments: {
              'email': _emailController.text.trim(),
              'phone': null,
              'verificationMethod': VerificationMethod.email,
            },
          );
        }
      } else if (!success) {
        if (mounted) {
          SnackBarManager.showError(
              context,
              authProvider.errorMessage ?? 'Error al registrar usuario. Por favor, intenta nuevamente.'
          );
        }
      }
    } catch (e) {
      debugPrint('💥 Error inesperado: $e');

      if (mounted) {
        Navigator.of(context).pop();
        SnackBarManager.showError(
            context,
            'Error inesperado: ${e.toString()}. Por favor, intenta nuevamente.'
        );
      }
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  Widget _buildProgressBar() {
    final totalSteps = 8;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Botón de retroceso
          GestureDetector(
            onTap: _isRegistering ? null : _prevPage,
            child: Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 16),
              child: SvgPicture.asset(
                'assets/images/vector-retrocession.svg',
                width: 28,
                height: 28,
                colorFilter: _isRegistering
                    ? ColorFilter.mode(Colors.grey.shade400, BlendMode.srcIn)
                    : null,
              ),
            ),
          ),

          // Barra de progreso
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / totalSteps,
                backgroundColor: Colors.grey[300],
                color: AppColors.mainOrange,
                minHeight: 8,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Contador al final
          Text(
            '${_currentPage + 1} de $totalSteps',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
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
    final bool isPageComplete = _isCurrentPageComplete();
    final Color buttonColor = isPageComplete ? AppColors.primary : const Color(0xFFE5E4E3);
    final Color iconColor = isPageComplete ? AppColors.whiteBackground : const Color(0xFFB2B0B0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
              _buildNextButton(isPageComplete, buttonColor, iconColor),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(
      bool isPageComplete,
      Color buttonColor,
      Color iconColor,
      ) {

    if (_currentPage == 7) {
      return SafeArea(
        top: false,
        left: false,
        right: false,
        minimum: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isRegistering || !isPageComplete ? null : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              disabledBackgroundColor: const Color(0xFFE5E4E3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
              elevation: 0,
            ),
            child: _isRegistering
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
                strokeWidth: 2.5,
              ),
            )
                : Text(
              'Registrar cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: iconColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      );
    }


    return SafeArea(
      top: false,
      left: false,
      right: false,
      minimum: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: _isRegistering || !isPageComplete ? null : _nextPage,
          child: Container(
            width: 57,
            height: 57,
            decoration: BoxDecoration(
              color: buttonColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.arrow_forward_ios,
                color: iconColor,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}