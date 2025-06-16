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
  final NutritionPlanService _planService = NutritionPlanService();
  final AppNavigationHandler _navigationHandler = AppNavigationHandler();

  bool isLoadingPlans = true;
  String? errorMessage;
  DailyPlanResponse? todayPlan;
  int selectedDateIndex = 2;
  bool isNoPlanFound = false; // Nueva variable para manejar cuando no hay plan

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
        isNoPlanFound = false;
      });

      final dailyPlan = await _planService.getTodayPlan();

      setState(() {
        todayPlan = dailyPlan;
        isLoadingPlans = false;
        isNoPlanFound = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPlans = false;

        // Verificar si es la excepción personalizada para plan no encontrado
        if (e is NoPlanFoundException) {
          isNoPlanFound = true;
          errorMessage = e.message;
          todayPlan = null;
          // No mostrar SnackBar para este caso
        } else {
          isNoPlanFound = false;
          errorMessage = e.toString();
          todayPlan = null;

          // Solo mostrar SnackBar para errores reales
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cargar comidas: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    }
  }

  // Método para cargar plan de una fecha específica
  Future<void> _loadPlanForDate(int dayNumber) async {
    try {
      setState(() {
        isLoadingPlans = true;
        errorMessage = null;
        isNoPlanFound = false;
      });

      final dailyPlan = await _planService.getDayPlan(dayNumber);

      setState(() {
        todayPlan = dailyPlan;
        isLoadingPlans = false;
        isNoPlanFound = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPlans = false;

        // Verificar si es la excepción personalizada para plan no encontrado
        if (e is NoPlanFoundException) {
          isNoPlanFound = true;
          errorMessage = e.message;
          todayPlan = null;
          // No mostrar SnackBar para este caso
        } else {
          isNoPlanFound = false;
          errorMessage = e.toString();
          todayPlan = null;

          // Solo mostrar SnackBar para errores reales
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cargar plan del día: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    }
  }

  void _onDateSelected(int index) {
    setState(() {
      selectedDateIndex = index;
    });

    // Cargar las comidas de la fecha seleccionada
    // Asumiendo que index 0 = Lunes (día 1), index 1 = Martes (día 2), etc.
    int dayNumber = index + 1;
    if (dayNumber <= 7) {
      _loadPlanForDate(dayNumber);
    }
  }

  @override
  void dispose() {
    _planService.dispose();
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
                    daysToShow: 7,
                    selectedIndex: selectedDateIndex,
                    onDateSelected: (DateItem date) {
                      print('Seleccionaste: ${date.day} de ${date.month}');
                    },
                  ),
                  const SizedBox(height: 24),

                  const MotivationalQuoteWidget(),
                  const SizedBox(height: 24),

                  // Widget personalizado para mostrar el estado del plan
                  _buildMealsSection(),

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

  // Nuevo widget para manejar los diferentes estados
  Widget _buildMealsSection() {
    if (isLoadingPlans) {
      return DailyMealsWidget(
        isLoading: true,
        errorMessage: null,
        todayPlan: null,
        onRetry: _loadTodayMeals,
      );
    }

    if (isNoPlanFound) {
      // Widget personalizado para mostrar mensaje amigable cuando no hay plan
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 48,
              color: Colors.blue.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'No tienes comidas programadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tu nutricionista aún no ha creado un plan para este día. ¡Mantente atento!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTodayMeals,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return DailyMealsWidget(
      isLoading: false,
      errorMessage: errorMessage,
      todayPlan: todayPlan,
      onRetry: _loadTodayMeals,
    );
  }
}