// recipes_screen.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/models/plan_detail.dart';
import 'package:frontendpatient/widgets/app_navigation_handler.dart';
import 'package:frontendpatient/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../models/nutrition_plan/daily_plan_response.dart';
import '../../models/nutrition_plan/nutririon_plan_model.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/route_names.dart';
import '../../service/nutrition_plan_service.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> with TickerProviderStateMixin {
  final NutritionPlanService _nutritionPlanService = NutritionPlanService();
  final AppNavigationHandler _navigationHandler = AppNavigationHandler();

  late TabController _tabController;
  bool isLoadingWeeklyPlan = true;
  String? errorMessage;
  WeeklyPlanResponse? weeklyPlan;

  final List<String> dayNames = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadWeeklyPlan();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nutritionPlanService.dispose();
    super.dispose();
  }

  Future<void> _loadWeeklyPlan() async {
    try {
      setState(() {
        isLoadingWeeklyPlan = true;
        errorMessage = null;
      });

      final plan = await _nutritionPlanService.getWeeklyPlan();

      setState(() {
        weeklyPlan = plan;
        isLoadingWeeklyPlan = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoadingWeeklyPlan = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Semanal'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeeklyPlan,
          ),
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: dayNames.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(
              child: Text('Error: No se pudo cargar la información del usuario'),
            );
          }

          if (isLoadingWeeklyPlan) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            );
          }

          if (errorMessage != null) {
            return RecipesErrorWidget(
              errorMessage: errorMessage!,
              onRetry: _loadWeeklyPlan,
            );
          }

          if (weeklyPlan == null || weeklyPlan!.dailyPlans.isEmpty) {
            return NoPlanWidget();
          }

          return Column(
            children: [
              // Header con información del plan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.orange.shade200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Objetivo: ${weeklyPlan!.goal}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requerimiento energético: ${weeklyPlan!.energyRequirement} kcal/día',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Semana: ${_formatDate(weeklyPlan!.weekStartDate)} - ${_formatDate(weeklyPlan!.weekEndDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (weeklyPlan!.reviewNotes != null && weeklyPlan!.reviewNotes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.note,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Nota del nutricionista: ${weeklyPlan!.reviewNotes}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // TabBarView con los días
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: weeklyPlan!.dailyPlans.map((dailyPlan) {
                    return RefreshIndicator(
                      onRefresh: _loadWeeklyPlan,
                      child: DayPlanWidget(
                        dailyPlan: dailyPlan,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) => _navigationHandler.handleNavigation(context, index),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

// Widget para mostrar el plan de un día específico
class DayPlanWidget extends StatelessWidget {
  final DailyPlanResponse dailyPlan;

  const DayPlanWidget({
    super.key,
    required this.dailyPlan,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del día
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dailyPlan.dayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _formatDate(dailyPlan.date),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${dailyPlan.totalCalories} kcal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Información nutricional
          MacronutrientsCard(macronutrients: dailyPlan.macronutrients),

          const SizedBox(height: 16),

          // Comidas del día
          ...dailyPlan.meals.entries.map((entry) {
            final mealType = entry.key;
            final mealData = entry.value as Map<String, dynamic>;

            return MealCard(
              mealType: mealType,
              mealData: mealData,
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const months = [
        'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
      ];
      return '${date.day} de ${months[date.month - 1]}';
    } catch (e) {
      return dateString;
    }
  }
}

// Widget para mostrar los macronutrientes
class MacronutrientsCard extends StatelessWidget {
  final Map<String, num> macronutrients;

  const MacronutrientsCard({
    super.key,
    required this.macronutrients,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Macronutrientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem(
                  'Proteínas',
                  '${macronutrients['proteins']?.toStringAsFixed(1) ?? '0'}g',
                  Colors.red.shade300,
                  Icons.fitness_center,
                ),
                _buildMacroItem(
                  'Carbohidratos',
                  '${macronutrients['carbohydrates']?.toStringAsFixed(1) ?? '0'}g',
                  Colors.blue.shade300,
                  Icons.grain,
                ),
                _buildMacroItem(
                  'Grasas',
                  '${macronutrients['fats']?.toStringAsFixed(1) ?? '0'}g',
                  Colors.yellow.shade600,
                  Icons.opacity,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// Widget para mostrar una comida específica
class MealCard extends StatelessWidget {
  final String mealType;
  final Map<String, dynamic> mealData;

  const MealCard({
    super.key,
    required this.mealType,
    required this.mealData,
  });

  @override
  Widget build(BuildContext context) {
    final foods = mealData['foods'] as List<dynamic>? ?? [];
    final totalCalories = mealData['total_calories'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getMealIcon(mealType),
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMealLabel(mealType),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$totalCalories kcal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...foods.map((food) {
              final name = food['name'] as String? ?? '';
              final quantity = food['quantity'] as String? ?? '';
              final calories = food['calories'] as int? ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (quantity.isNotEmpty)
                            Text(
                              quantity,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${calories} kcal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snacks':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  String _getMealLabel(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Desayuno';
      case 'lunch':
        return 'Almuerzo';
      case 'dinner':
        return 'Cena';
      case 'snacks':
        return 'Snacks';
      default:
        return 'Comida';
    }
  }
}

// Widget para mostrar cuando no hay plan disponible
class NoPlanWidget extends StatelessWidget {
  const NoPlanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.no_meals,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes un plan nutricional asignado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contacta con tu nutricionista para obtener tu plan personalizado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar errores
class RecipesErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const RecipesErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar el plan',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}