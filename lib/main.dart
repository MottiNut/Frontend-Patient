// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/routes/route_names.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'NutriApp - Pacientes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Configuración de colores principales
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.mainOrange,
            primary: AppColors.mainOrange,
            secondary: AppColors.mediumOrange,
          ),

          // Fuente principal
          fontFamily: 'Montserrat',

          // Configuración del AppBar
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.mainOrange,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          // Configuración de botones elevados
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainOrange,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Configuración de botones de texto
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mainOrange,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Configuración de campos de texto
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.mainOrange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            labelStyle: TextStyle(color: Colors.grey[700]),
            hintStyle: TextStyle(color: Colors.grey[500]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),

          // Configuración de cards
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
          ),

          // Configuración de scaffold
          scaffoldBackgroundColor: AppColors.whiteBackground,

          // Configuración de iconos
          iconTheme: const IconThemeData(
            color: AppColors.mainOrange,
          ),

          // Configuración de dividers
          dividerTheme: DividerThemeData(
            color: Colors.grey[300],
            thickness: 1,
            space: 1,
          ),
        ),

        // Configuración de rutas
        initialRoute: RouteNames.login,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}