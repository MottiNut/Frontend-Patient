import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../../commons/themes/app_theme.dart';
import '../../../commons/widgets/requestSnacbar/snackBar_manager.dart';
import '../providers/auth_provider.dart';
import '../../../commons/routes/route_names.dart';
import '../terms and conditions/politica_privacidad_screen.dart';
import '../terms and conditions/terminos_condiciones_screen.dart';
import 'package:flutter/gestures.dart';
import '../../../commons/services/secure_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storageService = SecureStorageService();

  bool _obscurePassword = true;
  bool isLoginSelected = true;
  bool _rememberMe = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // ⬅️ NUEVO: Cargar email guardado si existe
  Future<void> _loadSavedCredentials() async {
    try {
      final rememberMe = await _storageService.getRememberMe();
      final savedEmail = await _storageService.getSavedEmail();

      if (rememberMe && savedEmail != null) {
        setState(() {
          _rememberMe = true;
          _emailController.text = savedEmail;
        });
        debugPrint('✅ Credenciales cargadas: $savedEmail');
      }
    } catch (e) {
      debugPrint('⚠️ Error cargando credenciales: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty && password.isEmpty) {
      SnackBarManager.showError(
        context,
        "Por favor, ingresa tu usuario y contraseña.",
      );
      return;
    }

    if (email.isEmpty) {
      SnackBarManager.showError(context, "Por favor, ingresa tu usuario.");
      return;
    }

    if (password.isEmpty) {
      SnackBarManager.showError(context, "Por favor, ingresa tu contraseña.");
      return;
    }

    if (!_isValidEmail(email)) {
      SnackBarManager.showError(
        context,
        "Por favor, ingresa un correo electrónico válido.",
      );
      return;
    }

    if (password.length < 6) {
      SnackBarManager.showError(
        context,
        "La contraseña debe tener al menos 6 caracteres.",
      );
      return;
    }

    final result = await authProvider.login(email, password);

    if (!mounted) return;

    if (result['success'] == true && result['requiresVerification'] != true) {
      await _saveLoginPreferences(email);
      Navigator.pushReplacementNamed(context, RouteNames.home);
      return;
    }

    if (result['requiresVerification'] == true) {
      SnackBarManager.showError(
        context,
        "Tu correo no ha sido verificado. Te enviaremos un código de verificación.",
      );

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.pushNamed(context, RouteNames.codeVerification);
      }
      return;
    }

    final errorMsg = authProvider.errorMessage;

    if (errorMsg != null) {
      if (errorMsg.contains('401') ||
          errorMsg.contains('credenciales') ||
          errorMsg.contains('incorrecta') ||
          errorMsg.contains('inválida') ||
          errorMsg.contains('no autorizado')) {
        SnackBarManager.showError(
          context,
          "Usuario o contraseña incorrectos. Verifica tus credenciales.",
        );
      } else if (errorMsg.contains('verificación') ||
          errorMsg.contains('verificar') ||
          errorMsg.contains('no verificado')) {
        SnackBarManager.showError(
          context,
          "Tu correo no ha sido verificado. Redirigiendo a verificación...",
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.pushNamed(context, RouteNames.codeVerification);
        }
      } else if (errorMsg.contains('conexión') ||
          errorMsg.contains('network') ||
          errorMsg.contains('timeout')) {
        SnackBarManager.showError(
          context,
          "Error de conexión. Verifica tu internet e intenta nuevamente.",
        );
      } else if (errorMsg.contains('404')) {
        SnackBarManager.showError(
          context,
          "Usuario no encontrado. Verifica tus credenciales.",
        );
      } else {
        SnackBarManager.showError(
          context,
          "Error al iniciar sesión. Por favor, intenta nuevamente.",
        );
      }
    } else {
      SnackBarManager.showError(
        context,
        "Usuario o contraseña incorrectos. Verifica tus credenciales.",
      );
    }
  }

  Future<void> _saveLoginPreferences(String email) async {
    try {
      if (_rememberMe) {
        await _storageService.saveRememberMe(true);
        await _storageService.saveSavedEmail(email);
        debugPrint('✅ Credenciales guardadas para: $email');
      } else {
        await _storageService.clearSavedEmail();
        debugPrint('✅ Credenciales eliminadas');
      }
    } catch (e) {
      debugPrint('⚠️ Error guardando preferencias: $e');
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      SvgPicture.asset(
                        'assets/images/logo.svg',
                        width: 80,
                        height: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'MottiNut',
                        style: AppTextStyles.tittle.copyWith(
                          color: AppColors.mainOrange,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLoginSelected = true;
                          });
                          Navigator.pushNamed(context, RouteNames.login).then((
                              _,
                              ) {
                            setState(() {
                              isLoginSelected = true;
                            });
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontWeight:
                                isLoginSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color:
                                isLoginSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 1.5,
                              width: 100,
                              color:
                              isLoginSelected
                                  ? AppColors.mainOrange
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 0.9,
                        color: Colors.grey.shade400,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLoginSelected = false;
                          });
                          Navigator.pushNamed(
                            context,
                            RouteNames.register,
                          ).then((_) {
                            setState(() {
                              isLoginSelected = true;
                            });
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Registrar',
                              style: TextStyle(
                                fontWeight:
                                !isLoginSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color:
                                !isLoginSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 2,
                              width: 100,
                              color:
                              !isLoginSelected
                                  ? AppColors.mainOrange
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  _buildInputFields(),

                  _buildRememberMeCheckbox(),

                  const SizedBox(height: 30),

                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                          authProvider.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainOrange,
                            disabledBackgroundColor: AppColors.mainOrange
                                .withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child:
                          authProvider.isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                              strokeWidth: 2.5,
                            ),
                          )
                              : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Colors.grey, thickness: 0.2),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'o',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Colors.grey, thickness: 0.2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  _buildSocialButtonsRow(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _buildTermsAndConditions(context),
          ),
        ),
      ),
    );
  }


  Widget _buildRememberMeCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              activeColor: AppColors.mainOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: MaterialStateBorderSide.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return BorderSide(color: AppColors.mainOrange, width: 2);
                }
                return BorderSide(color: Colors.grey.shade400, width: 2);
              }),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _rememberMe = !_rememberMe;
              });
            },
            child: Text(
              'Recordar credenciales',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInputFields() {
    return Column(
      children: [
        const SizedBox(height: 15),
        _buildEmailField(),
        const SizedBox(height: 18),
        _buildPasswordField(),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface.withOpacity(0.3),
        labelText: 'Usuario',
        labelStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 17,
          letterSpacing: -0.4,
          fontWeight: FontWeight.w300,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/images/user_icon.svg',
            width: 20,
            height: 20,
            color: AppColors.primary.withOpacity(0.8),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.grey, width: 0.6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface.withOpacity(0.3),
        labelText: 'Contraseña',
        labelStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 17,
          letterSpacing: -0.4,
          fontWeight: FontWeight.w300,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/images/candado_icon.svg',
            height: 20,
            width: 20,
            color: AppColors.primary.withOpacity(0.8),
          ),
        ),
        suffixIcon: IconButton(
          icon:
          _obscurePassword
              ? SvgPicture.asset(
            'assets/images/eye_icon.svg',
            height: 18,
            width: 18,
            color: Colors.grey.shade500,
          )
              : Icon(
            Icons.visibility_off,
            color: AppColors.textInput.withOpacity(0.8),
            size: 25,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.grey, width: 0.6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSocialButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          'assets/images/logo_google_login.png',
          'Google',
          _loginWithGoogle,
        ),
        const SizedBox(width: 35),
        _buildSocialButton(
          'assets/images/apple_logo.png',
          'Apple',
          _loginWithApple,
        ),
      ],
    );
  }

  Widget _buildSocialButton(
      String assetPath,
      String provider,
      VoidCallback onPressed,
      ) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Image.asset(
          assetPath,
          height: 27,
          width: 27,
          color: AppColors.primary,
          errorBuilder: (context, error, stackTrace) {
            if (provider == 'Google') {
              return Icon(Icons.login, color: AppColors.primary, size: 27);
            } else {
              return Icon(Icons.apple, color: AppColors.primary, size: 27);
            }
          },
        ),
      ),
    );
  }

  void _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        debugPrint('Google account selected: ${googleUser.email}');
        await _googleSignIn.signOut();

        if (mounted) {
          SnackBarManager.showError(
            context,
            'Login con Google próximamente disponible. El backend aún no está implementado.',
          );
        }
      } else {
        debugPrint('Google sign-in cancelled by user');
      }
    } catch (error) {
      debugPrint('Error Google login: $error');

      if (mounted) {
        SnackBarManager.showError(
          context,
          'Se produjo un error al iniciar sesión con Google. Inténtalo nuevamente.',
        );
      }
    }
  }

  void _loginWithApple() async {
    if (mounted) {
      SnackBarManager.showError(
        context,
        'Login con Apple próximamente disponible. El backend aún no está implementado.',
      );
    }
  }

  Widget _buildTermsAndConditions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'Al continuar, aceptas los \n',
          style: TextStyle(
            color: AppColors.textInput,
            fontWeight: FontWeight.w300,
            fontSize: 11,
            letterSpacing: 0.5,
            height: 1.3,
          ),
          children: [
            TextSpan(
              text: 'Términos y Condiciones',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                letterSpacing: 0.5,
              ),
              recognizer:
              TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const TerminosCondicionesScreen(),
                    ),
                  );
                },
            ),
            TextSpan(
              text: ' y ',
              style: TextStyle(
                color: AppColors.textInput,
                fontWeight: FontWeight.w400,
                fontSize: 11,
              ),
            ),
            TextSpan(
              text: 'Política de privacidad',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
              recognizer:
              TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const PoliticaPrivacidadScreen(),
                    ),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}