import 'package:flutter/material.dart';
import 'package:frontendpatient/service/date_service.dart';
import 'package:frontendpatient/widgets/app_navigation_handler.dart';
import 'package:frontendpatient/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../models/nutrition_plan/daily_plan_response.dart';
import '../../models/nutrition_plan/nutririon_plan_model.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/route_names.dart';
import '../../service/nutrition_plan_service.dart';
import 'widgets/welcome_header_widget.dart';
import 'widgets/date_selector_widget.dart';
import 'widgets/motivational_quote_widget.dart';
import 'widgets/daily_meals_widget.dart';
class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final NutritionPlanService _planService = NutritionPlanService(); // ✅ Corregido el nombre del servicio
  final AppNavigationHandler _navigationHandler = AppNavigationHandler();

  bool isLoadingPlans = true;
  String? errorMessage;
  DailyPlanResponse? todayPlan;
  int selectedDateIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadTodayMeals();
  }

  Future<void> _loadTodayMeals() async {
    try {
      setState(() {
        isLoadingPlans = true;
        errorMessage = null;
      });

      final dailyPlan = await _planService.getTodayPlan(); // ✅ Ahora retorna DailyPlanResponse directamente

      setState(() {
        todayPlan = dailyPlan;
        isLoadingPlans = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoadingPlans = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar comidas: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ Nuevo método para cargar plan de una fecha específica
  Future<void> _loadPlanForDate(int dayNumber) async {
    try {
      setState(() {
        isLoadingPlans = true;
        errorMessage = null;
      });

      final dailyPlan = await _planService.getDayPlan(dayNumber);

      setState(() {
        todayPlan = dailyPlan;
        isLoadingPlans = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoadingPlans = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar plan del día: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onDateSelected(int index) {
    setState(() {
      selectedDateIndex = index;
    });

    // ✅ Cargar las comidas de la fecha seleccionada
    // Asumiendo que index 0 = Lunes (día 1), index 1 = Martes (día 2), etc.
    int dayNumber = index + 1;
    if (dayNumber <= 7) {
      _loadPlanForDate(dayNumber);
    }
  }

  @override
  void dispose() {
    _planService.dispose(); // ✅ Limpiar recursos del servicio
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'logout') {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, RouteNames.login);
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final patient = authProvider.currentUser;

          if (patient == null) {
            return const Center(
              child: Text('Error: No se pudo cargar la información del usuario'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTodayMeals,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeHeaderWidget(patientName: patient.firstName, patientLastName: patient.lastName),
                  const SizedBox(height: 24),

                  DateSelectorWidget(
                    daysToShow: 7, // ✅ Mostrar toda la semana
                    selectedIndex: selectedDateIndex, // ✅ Añadir índice seleccionado si el widget lo soporta
                    onDateSelected: (DateItem date) {
                      // ✅ Mejorar el manejo de selección de fecha
                      print('Seleccionaste: ${date.day} de ${date.month}');
                    },
                  ),
                  const SizedBox(height: 24),

                  const MotivationalQuoteWidget(),
                  const SizedBox(height: 24),

                  DailyMealsWidget(
                    isLoading: isLoadingPlans,
                    errorMessage: errorMessage,
                    todayPlan: todayPlan,
                    onRetry: _loadTodayMeals,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _navigationHandler.currentIndex,
        onTap: (index) => _navigationHandler.handleNavigation(context, index),
      ),
    );
  }
}