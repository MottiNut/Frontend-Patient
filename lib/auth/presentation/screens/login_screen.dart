
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../../commons/themes/app_theme.dart';
import '../../../commons/widgets/requestSnacbar/snackBar_manager.dart';
import '../providers/auth_provider.dart';
import '../../../commons/utils/validators.dart';
import '../../../commons/routes/route_names.dart';
import '../terms and conditions/politica_privacidad_screen.dart';
import '../terms and conditions/terminos_condiciones_screen.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool isLoginSelected = true;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo + Nombre
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
                        fontWeight: FontWeight.bold
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
                        Navigator.pushNamed(context, RouteNames.login).then((_) {
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
                              fontWeight: isLoginSelected ? FontWeight.bold : FontWeight.w500,
                              color: isLoginSelected ? AppColors.primary : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 1.5,
                            width: 100,
                            color: isLoginSelected ? AppColors.mainOrange : Colors.transparent,
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
                        Navigator.pushNamed(context, RouteNames.register).then((_) {
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
                              fontWeight: !isLoginSelected ? FontWeight.bold : FontWeight.w500,
                              color: !isLoginSelected ? AppColors.primary : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 100,
                            color: !isLoginSelected ? AppColors.mainOrange : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                _buildInputFields(),

                SizedBox(height: 30),

                // Errores y Botón
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Column(
                      children: [
                        // Mostrar error si existe
                        if (authProvider.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authProvider.errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  color: Colors.red[700],
                                  onPressed: () {
                                    authProvider.clearError();
                                  },
                                ),
                              ],
                            ),
                          ),


                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                              strokeWidth: 2,
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
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 0.2,
                        ),
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
                        child: Divider(
                          color: Colors.grey,
                          thickness: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8),
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

    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        SizedBox(height: 15),
        _buildEmailField(),
        SizedBox(height: 18),
        _buildPasswordField(),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: Validators.validateEmail,
      style: TextStyle(
        color: AppColors.textDark,
        fontSize: 16,
      ),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.errorIcon, width: 1.6),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.errorIcon, width: 1.6),
        ),
        errorStyle: TextStyle(
          color: AppColors.errorIcon,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: Validators.validatePassword,
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
          icon: _obscurePassword
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
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.errorIcon, width: 1.6),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.errorIcon, width: 1.6),
        ),
        errorStyle: TextStyle(
          color: AppColors.errorIcon,
          fontSize: 12,
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
        SizedBox(width: 35),
        _buildSocialButton(
          'assets/images/apple_logo.png',
          'Apple',
          _loginWithApple,
        ),
      ],
    );
  }

  Widget _buildSocialButton(
      String assetPath, String provider, VoidCallback onPressed) {
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
            offset: Offset(0, 2),
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
      await _googleSignIn.signIn();
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      print(error);

      SnackBarManager.showError(context,
          'Se produjo un error al iniciar sesión con Google. Inténtalo nuevamente.');
    }
  }

  void _loginWithApple() async {
    try {
      SnackBarManager.showError(
          context, 'Login con Apple próximamente disponible');
    } catch (error) {
      print(error);

      SnackBarManager.showError(context,
          'Se produjo un error al iniciar sesión con Apple. Inténtalo nuevamente.');
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
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TerminosCondicionesScreen(),
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
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PoliticaPrivacidadScreen(),
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