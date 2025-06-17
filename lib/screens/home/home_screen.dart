import 'package:flutter/material.dart';
import 'package:frontendpatient/widgets/app_navigation_handler.dart';
import 'package:frontendpatient/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../models/nutrition_plan/daily_plan_response.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/route_names.dart';
import '../../service/nutrition_plan_service.dart';
import 'widgets/welcome_header_widget.dart';
import 'widgets/date_selector_widget.dart';
import 'widgets/motivational_quote_widget.dart';
import 'widgets/daily_meals_widget.dart';

enum MealPlanState {
  loading,
  success,
  noPlan,
  error,
}

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final NutritionPlanService _planService = NutritionPlanService();
  final AppNavigationHandler _navigationHandler = AppNavigationHandler();
  MealPlanState _currentState = MealPlanState.loading;
  String? _errorMessage;
  DailyPlanResponse? _currentPlan;

  @override
  void initState() {
    super.initState();
    AppNavigationHandler.setCurrentIndex(0);
    _loadTodayPlan();
  }

  /// Método para cargar solo el plan de hoy
  Future<void> _loadTodayPlan() async {
    try {
      _setState(MealPlanState.loading);

      final DailyPlanResponse dailyPlan = await _planService.getTodayPlan();

      _setState(MealPlanState.success, plan: dailyPlan);

    } catch (e) {
      if (e is NoPlanFoundException) {
        _setState(MealPlanState.noPlan, errorMessage: e.message);
      } else {
        _setState(MealPlanState.error, errorMessage: e.toString());
        _showErrorSnackBar('Error al cargar plan: ${e.toString()}');
      }
    }
  }

  /// Método helper para actualizar estado
  void _setState(MealPlanState state, {
    DailyPlanResponse? plan,
    String? errorMessage,
  }) {
    if (mounted) {
      setState(() {
        _currentState = state;
        _currentPlan = plan;
        _errorMessage = errorMessage;
      });
    }
  }

  /// Mostrar SnackBar de error
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: _loadTodayPlan,
          ),
        ),
      );
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
      appBar: _buildAppBar(),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final patient = authProvider.currentUser;

          if (patient == null) {
            return const Center(
              child: Text('Error: No se pudo cargar la información del usuario'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTodayPlan,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeHeaderWidget(
                    patientName: patient.firstName,
                    patientLastName: patient.lastName,
                  ),
                  const SizedBox(height: 24),

                  // DateSelectorWidget ahora es solo informativo
                  const DateSelectorWidget(
                    daysToShow: 7,
                    isReadOnly: true, // Nueva propiedad para hacerlo solo lectura
                  ),
                  const SizedBox(height: 24),

                  const MotivationalQuoteWidget(),
                  const SizedBox(height: 24),

                  _buildMealsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: AppNavigationHandler.currentIndex, // Usar el handler
        onTap: (index) => AppNavigationHandler.handleNavigation(context, index),
      ),
    );
  }

  /// AppBar extraído para mejor organización
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Bienvenido'),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: _handleMenuSelection,
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
    );
  }

  /// Manejar selección del menú
  Future<void> _handleMenuSelection(String value) async {
    if (value == 'logout') {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }
    }
  }

  /// Selector de widgets según el estado actual
  Widget _buildMealsSection() {
    switch (_currentState) {
      case MealPlanState.loading:
        return DailyMealsWidget(
          isLoading: true,
          errorMessage: null,
          todayPlan: null,
          onRetry: _loadTodayPlan,
        );

      case MealPlanState.noPlan:
        return _buildNoPlanWidget();

      case MealPlanState.error:
        return DailyMealsWidget(
          isLoading: false,
          errorMessage: _errorMessage,
          todayPlan: null,
          onRetry: _loadTodayPlan,
        );

      case MealPlanState.success:
        return DailyMealsWidget(
          isLoading: false,
          errorMessage: null,
          todayPlan: _currentPlan,
          onRetry: _loadTodayPlan,
        );
    }
  }

  /// Widget personalizado para estado "sin plan"
  Widget _buildNoPlanWidget() {
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
            _errorMessage ?? 'No tienes comidas programadas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Tu nutricionista aún no ha creado un plan para hoy. ¡Mantente atento!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadTodayPlan,
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
}