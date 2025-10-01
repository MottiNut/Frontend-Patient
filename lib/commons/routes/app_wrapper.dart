import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontendpatient/commons/routes/swipe_navigation_wrapper.dart';
import 'package:frontendpatient/auth/presentation/providers/auth_provider.dart';
import 'package:frontendpatient/auth/presentation/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  AuthState? _previousState;

  @override
  void initState() {
    super.initState();
    // Inicializar la app de forma más segura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initializeApp();
    });
  }

  void _handleStateChange(AuthState currentState, AuthProvider authProvider) {
    // Debug para verificar cambios de estado
    debugPrint('🔄 Estado anterior: $_previousState, Estado actual: $currentState');

    // Manejar estado de error (tanto inicial como transición)
    if (currentState == AuthState.error) {
      // Si es la primera vez que vemos este estado de error, o si cambió de otro estado
      if (_previousState == null || _previousState != AuthState.error) {
        debugPrint('❌ ERROR detectado! Ejecutando vibración...');
        _handleError(authProvider.errorMessage);
      }
    }

    // Manejar transición a no autenticado (logout o fallo de autenticación)
    if (currentState == AuthState.unauthenticated &&
        _previousState == AuthState.authenticated) {
      debugPrint('🚪 Sesión cerrada');
      _showToast(
        'Sesión cerrada',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }

    // Actualizar estado anterior
    _previousState = currentState;
  }

  Future<void> _handleError(String? errorMessage) async {
    debugPrint('🔥 Manejando error: $errorMessage');

    // Vibrar el dispositivo para alertar al usuario
    await _triggerVibration();


  }

  Future<void> _triggerVibration() async {
    try {
      debugPrint('📳 Intentando vibrar...');

      await HapticFeedback.heavyImpact();
      debugPrint('✅ Vibración ejecutada');
    } catch (e) {
      // Si falla la vibración, continuar sin interrumpir la app
      debugPrint('❌ Error al generar feedback háptico: $e');
    }
  }

  void _showToast(String message, {Color? backgroundColor, Color? textColor}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 3,
      backgroundColor: backgroundColor ?? Colors.grey[800],
      textColor: textColor ?? Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Manejar cambios de estado inmediatamente
        _handleStateChange(authProvider.state, authProvider);

        switch (authProvider.state) {
          case AuthState.initial:
          case AuthState.loading:
          case AuthState.loggingOut:
            return const _LoadingScreen();

          case AuthState.authenticated:

            return const SwipeNavigationWrapper(initialIndex: 0);

          case AuthState.error:
            return _ErrorScreen(
              onRetry: () {
                authProvider.clearError();
                authProvider.checkAuthStatus();
              },
            );

          case AuthState.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}

// Widget de loading mejorado con mejor animación
class _LoadingScreen extends StatefulWidget {
  const _LoadingScreen();

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de error mejorado con mejor UX
class _ErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de error mejorado con animación
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.triangleExclamation,
                          size: 40,
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Error al cargar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Selector<AuthProvider, String?>(
                selector: (context, authProvider) => authProvider.errorMessage,
                builder: (context, errorMessage, child) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.circleInfo,
                          size: 16,
                          color: Colors.red[600],
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            errorMessage ?? 'Error desconocido',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Botón de reintentar mejorado
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const FaIcon(
                  FontAwesomeIcons.arrowRotateRight,
                  size: 16,
                ),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                  shadowColor: Colors.orange.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 16),
              // Botón secundario para ir al login
              TextButton.icon(
                onPressed: () {
                  final authProvider = context.read<AuthProvider>();
                  authProvider.clearError();
                  authProvider.logout();
                },
                icon: const FaIcon(
                  FontAwesomeIcons.rightToBracket,
                  size: 16,
                ),
                label: const Text('Ir al Login'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  minimumSize: const Size(200, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}