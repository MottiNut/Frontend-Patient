import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';
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

  Widget _buildHealthOption(String label, IconData icon) {
    final isSelected = formData['chronicDisease'] == label;
    return Card(
      color: isSelected ? AppColors.lightOrange : null,
      child: ListTile(
        leading: Icon(icon, color: AppColors.mainOrange),
        title: Text(
          label,
          style: AppTextStyles.descripcion.copyWith(
            letterSpacing: 0,
            fontSize: 16,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check, color: AppColors.mainOrange)
            : null,
        onTap: () {
          setState(() {
            formData['chronicDisease'] = label;
            // Limpiar el campo de texto cuando se selecciona una opción predefinida
            _chronicDiseaseController.clear();
          });
        },
      ),
    );
  }

  // Método para manejar las opciones de alergias
  Widget _buildAllergyOption(String label, IconData icon) {
    final isSelected = formData['allergies'] == label;
    return Card(
      color: isSelected ? AppColors.lightOrange : null,
      child: ListTile(
        leading: Icon(icon, color: AppColors.mainOrange),
        title: Text(
          label,
          style: AppTextStyles.descripcion.copyWith(
            letterSpacing: 0,
            fontSize: 16,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check, color: AppColors.mainOrange)
            : null,
        onTap: () {
          setState(() {
            formData['allergies'] = label;
            // Limpiar el campo de texto cuando se selecciona una opción predefinida
            _allergiesController.clear();
          });
        },
      ),
    );
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

  Widget _buildTextField(
      String label,
      String key,
      TextEditingController controller, {
        bool obscure = false,
        TextInputType type = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
      onSaved: (value) => formData[key] = value ?? '',
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información personal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Nombre',
              'firstName',
              _firstNameController,
              validator: (value) => Validators.validateName(value, 'El nombre'),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Apellido',
              'lastName',
              _lastNameController,
              validator: (value) => Validators.validateName(value, 'El apellido'),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Credenciales de acceso',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Correo electrónico',
              'email',
              _emailController,
              type: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Contraseña',
              'password',
              _passwordController,
              obscure: true,
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Repetir contraseña',
              'repeatPassword',
              _repeatPasswordController,
              obscure: true,
              validator: (value) => Validators.validateConfirmPassword(
                  value,
                  _passwordController.text
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fecha de nacimiento',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Fecha de nacimiento',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => formData['birthDate'] = picked);
                }
              },
              readOnly: true,
              controller: TextEditingController(
                text: formData['birthDate']?.toString().split(' ').first ?? '',
              ),
              validator: (value) => Validators.validateBirthDate(formData['birthDate']),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edad',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Edad (años)',
              'age',
              _ageController,
              type: TextInputType.number,
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos físicos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Peso (kg)',
              'weight',
              _weightController,
              type: TextInputType.number,
              validator: Validators.validateWeight,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Altura (cm)',
              'height',
              _heightController,
              type: TextInputType.number,
              validator: Validators.validateHeight,
            ),
          ],
        );
      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información médica',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '¿Padeces alguna enfermedad crónica?',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Switch(
                      value: formData['hasMedicalCondition'],
                      onChanged: (val) => setState(() => formData['hasMedicalCondition'] = val),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 6:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(
              '¿Qué condición deseas manejar con tu alimentación?',
              style: AppTextStyles.subtitulo.copyWith(
                color: AppColors.mainOrange,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Esto nos ayuda a crear un plan seguro y efectivo para ti',
              style: AppTextStyles.descripcion.copyWith(
                color: Colors.grey[600],
                fontSize: 14,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildHealthOption('Diabetes', Icons.bloodtype),
            _buildHealthOption('Hipertensión arterial', Icons.favorite),
            _buildHealthOption('Obesidad o sobrepeso', Icons.monitor_weight),

            // Opción "Otro" con campo de texto
            Card(
              color: formData['chronicDisease'] != null &&
                  formData['chronicDisease'] != 'Diabetes' &&
                  formData['chronicDisease'] != 'Hipertensión arterial' &&
                  formData['chronicDisease'] != 'Obesidad o sobrepeso'
                  ? AppColors.lightOrange : null,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.more_horiz, color: AppColors.mainOrange),
                    title: Text(
                      'Otro...',
                      style: AppTextStyles.descripcion.copyWith(
                        letterSpacing: 0,
                        fontSize: 16,
                      ),
                    ),
                    trailing: formData['chronicDisease'] != null &&
                        formData['chronicDisease'] != 'Diabetes' &&
                        formData['chronicDisease'] != 'Hipertensión arterial' &&
                        formData['chronicDisease'] != 'Obesidad o sobrepeso'
                        ? const Icon(Icons.check, color: AppColors.mainOrange)
                        : null,
                    onTap: () {
                      setState(() {
                        if (formData['chronicDisease'] == null ||
                            formData['chronicDisease'] == 'Diabetes' ||
                            formData['chronicDisease'] == 'Hipertensión arterial' ||
                            formData['chronicDisease'] == 'Obesidad o sobrepeso') {
                          formData['chronicDisease'] = '';
                          _chronicDiseaseController.text = '';
                        }
                      });
                    },
                  ),
                  // Mostrar campo de texto si "Otro" está seleccionado
                  if (formData['chronicDisease'] != null &&
                      formData['chronicDisease'] != 'Diabetes' &&
                      formData['chronicDisease'] != 'Hipertensión arterial' &&
                      formData['chronicDisease'] != 'Obesidad o sobrepeso')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _chronicDiseaseController,
                        style: AppTextStyles.descripcion.copyWith(
                          fontSize: 16,
                          letterSpacing: 0,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Especifica tu condición',
                          labelStyle: AppTextStyles.descripcion.copyWith(
                            color: AppColors.darkOrange1,
                            fontSize: 14,
                            letterSpacing: 0,
                          ),
                          hintText: 'Ej: Colesterol alto, Gastritis, etc.',
                          hintStyle: AppTextStyles.descripcion.copyWith(
                            color: Colors.grey[500],
                            fontSize: 14,
                            letterSpacing: 0,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.mediumOrange),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.mainOrange, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.mediumOrange),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (formData['chronicDisease'] != null &&
                              formData['chronicDisease'] != 'Diabetes' &&
                              formData['chronicDisease'] != 'Hipertensión arterial' &&
                              formData['chronicDisease'] != 'Obesidad o sobrepeso' &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Por favor especifica tu condición médica';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          formData['chronicDisease'] = value.trim();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      case 7:
      case 7:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(
              '¿Tienes alergias o intolerancias?',
              style: AppTextStyles.subtitulo.copyWith(
                color: AppColors.mainOrange,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tu seguridad es primero. Evitaremos estos alimentos',
              style: AppTextStyles.descripcion.copyWith(
                color: Colors.grey[600],
                fontSize: 14,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildAllergyOption('Gluten', Icons.grain),
            _buildAllergyOption('Lactosa', Icons.local_drink),
            _buildAllergyOption('Frutos Secos', Icons.nature),
            _buildAllergyOption('Mariscos', Icons.set_meal),

            // Opción "Otro" con campo de texto
            Card(
              color: formData['allergies'] != null &&
                  formData['allergies'] != 'Gluten' &&
                  formData['allergies'] != 'Lactosa' &&
                  formData['allergies'] != 'Frutos Secos' &&
                  formData['allergies'] != 'Mariscos' &&
                  formData['allergies'] != 'Ninguna'
                  ? AppColors.lightOrange : null,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.more_horiz, color: AppColors.mainOrange),
                    title: Text(
                      'Otro...',
                      style: AppTextStyles.descripcion.copyWith(
                        letterSpacing: 0,
                        fontSize: 16,
                      ),
                    ),
                    trailing: formData['allergies'] != null &&
                        formData['allergies'] != 'Gluten' &&
                        formData['allergies'] != 'Lactosa' &&
                        formData['allergies'] != 'Frutos Secos' &&
                        formData['allergies'] != 'Mariscos' &&
                        formData['allergies'] != 'Ninguna'
                        ? const Icon(Icons.check, color: AppColors.mainOrange)
                        : null,
                    onTap: () {
                      setState(() {
                        if (formData['allergies'] == null ||
                            formData['allergies'] == 'Gluten' ||
                            formData['allergies'] == 'Lactosa' ||
                            formData['allergies'] == 'Frutos Secos' ||
                            formData['allergies'] == 'Mariscos' ||
                            formData['allergies'] == 'Ninguna') {
                          formData['allergies'] = '';
                          _allergiesController.text = '';
                        }
                      });
                    },
                  ),
                  // Mostrar campo de texto si "Otro" está seleccionado
                  if (formData['allergies'] != null &&
                      formData['allergies'] != 'Gluten' &&
                      formData['allergies'] != 'Lactosa' &&
                      formData['allergies'] != 'Frutos Secos' &&
                      formData['allergies'] != 'Mariscos' &&
                      formData['allergies'] != 'Ninguna')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _allergiesController,
                        style: AppTextStyles.descripcion.copyWith(
                          fontSize: 16,
                          letterSpacing: 0,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Especifica tu alergia o intolerancia',
                          labelStyle: AppTextStyles.descripcion.copyWith(
                            color: AppColors.darkOrange1,
                            fontSize: 14,
                            letterSpacing: 0,
                          ),
                          hintText: 'Ej: Huevos, Soja, Chocolate, etc.',
                          hintStyle: AppTextStyles.descripcion.copyWith(
                            color: Colors.grey[500],
                            fontSize: 14,
                            letterSpacing: 0,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.mediumOrange),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.mainOrange, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.mediumOrange),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (formData['allergies'] != null &&
                              formData['allergies'] != 'Gluten' &&
                              formData['allergies'] != 'Lactosa' &&
                              formData['allergies'] != 'Frutos Secos' &&
                              formData['allergies'] != 'Mariscos' &&
                              formData['allergies'] != 'Ninguna' &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Por favor especifica tu alergia o intolerancia';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          formData['allergies'] = value.trim();
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Opción "Ninguna"
            Card(
              color: formData['allergies'] == 'Ninguna' ? AppColors.lightOrange : null,
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline, color: AppColors.mainOrange),
                title: Text(
                  'Ninguna',
                  style: AppTextStyles.descripcion.copyWith(
                    letterSpacing: 0,
                    fontSize: 16,
                  ),
                ),
                trailing: formData['allergies'] == 'Ninguna'
                    ? const Icon(Icons.check, color: AppColors.mainOrange)
                    : null,
                onTap: () {
                  setState(() {
                    formData['allergies'] = 'Ninguna';
                    _allergiesController.clear();
                  });
                },
              ),
            ),
          ],
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
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
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