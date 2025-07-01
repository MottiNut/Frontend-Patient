// lib/core/app_wrapper.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/providers/auth_provider.dart';
import 'package:frontendpatient/screens/auth/login_screen.dart';
import 'package:frontendpatient/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        debugPrint('🔄 AppWrapper - Current AuthState: ${authProvider.state}');

        // ✅ LOADING: Mostrar splash durante inicialización
        if (authProvider.state == AuthState.initial ||
            authProvider.state == AuthState.loading) {
          return const AppLoadingScreen();
        }

        // ✅ LOGOUT: Mostrar loading específico durante logout
        if (authProvider.state == AuthState.loggingOut) {
          return const LogoutLoadingScreen();
        }

        // ✅ AUTHENTICATED: Mostrar app principal
        if (authProvider.state == AuthState.authenticated) {
          return const PatientHomeScreen();
        }

        // ✅ ERROR: Mostrar error pero con opción de retry
        if (authProvider.state == AuthState.error) {
          return AppErrorScreen(
            error: authProvider.errorMessage ?? 'Error desconocido',
            onRetry: () => authProvider.checkAuthStatus(),
          );
        }

        // ✅ UNAUTHENTICATED: Mostrar login - SIEMPRE DEBE LLEGAR AQUÍ DESPUÉS DE LOGOUT
        debugPrint('✅ AppWrapper - Showing LoginScreen');
        return const LoginScreen();
      },
    );
  }
}

// ✅ Pantalla de carga general
class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la app
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

// ✅ Pantalla específica para logout
class LogoutLoadingScreen extends StatelessWidget {
  const LogoutLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            const SizedBox(height: 16),
            Text(
              'Cerrando sesión...',
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

// ✅ Pantalla de error con opción de reintentar
class AppErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const AppErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
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