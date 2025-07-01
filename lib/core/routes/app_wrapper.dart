import 'package:flutter/material.dart';
import 'package:frontendpatient/providers/auth_provider.dart';
import 'package:frontendpatient/screens/auth/login_screen.dart';
import 'package:frontendpatient/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Inicializar la app de forma más segura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, AuthState>(
      selector: (context, authProvider) => authProvider.state,
      builder: (context, authState, child) {
        switch (authState) {
          case AuthState.initial:
          case AuthState.loading:
          case AuthState.loggingOut:
            return const _LoadingScreen();

          case AuthState.authenticated:
            return const PatientHomeScreen();

          case AuthState.error:
            return _ErrorScreen(
              onRetry: () {
                final authProvider = context.read<AuthProvider>();
                authProvider.clearError(); // Limpiar error antes de reintentar
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

// Widget de loading unificado y optimizado
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 40,
                color: Colors.orange[600],
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
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

// Widget de error optimizado
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
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
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
                  return Text(
                    errorMessage ?? 'Error desconocido',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}