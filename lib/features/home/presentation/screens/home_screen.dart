import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontendpatient/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontendpatient/features/nutrition_plan/domain/models/daily_plan.dart';
import 'package:frontendpatient/features/nutrition_plan/domain/usecases/get_today_plan_usecase.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../shared/widgets/app_navigation_handler.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../widgets/welcome_header_widget.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/motivational_quote_widget.dart';
import '../widgets/daily_meals_widget.dart';

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
  // Usando el use case de la nueva arquitectura
  late final GetTodayPlanUseCase _getTodayPlanUseCase;

  MealPlanState _currentState = MealPlanState.loading;
  String? _errorMessage;
  DailyPlan? _currentPlan;

  @override
  void initState() {
    super.initState();
    // Inicializar el use case usando el service locator
    _getTodayPlanUseCase = sl<GetTodayPlanUseCase>();
    _loadTodayPlan();
  }

  Future<void> _loadTodayPlan() async {
    try {
      _setState(MealPlanState.loading);

      // Usando el use case en lugar del service directo
      final DailyPlan dailyPlan = await _getTodayPlanUseCase.call();

      _setState(MealPlanState.success, plan: dailyPlan);
    } catch (e) {
      // Manejo de errores específicos
      if (e.toString().contains('No tienes comidas programadas')) {
        _setState(
          MealPlanState.noPlan,
          errorMessage: 'No tienes comidas programadas para hoy',
        );
      } else {
        _setState(
          MealPlanState.error,
          errorMessage: e.toString(),
        );
        _showErrorSnackBar('Error al cargar plan: ${e.toString()}');
      }
    }
  }

  void _setState(
      MealPlanState state, {
        DailyPlan? plan,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
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
                  const DateSelectorWidget(
                    daysToShow: 7,
                    isReadOnly: true,
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
        currentIndex: AppNavigationHandler.currentIndex,
        onTap: (index) => AppNavigationHandler.handleNavigation(context, index),
      ),
    );
  }

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