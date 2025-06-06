import 'package:flutter/material.dart';
import 'package:frontendpatient/models/nutrition_plan.dart';
import 'package:frontendpatient/service/nutrition_plan_service.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/route_names.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  List<NutritionPlan> nutritionPlans = [];
  bool isLoadingPlans = true;
  String? errorMessage;

  // Datos para el calendario
  final List<Map<String, dynamic>> dates = [
    {'day': '12', 'month': 'Jun'},
    {'day': '13', 'month': 'Jun'},
    {'day': '14', 'month': 'Jun'},
    {'day': '15', 'month': 'Jun'},
    {'day': '16', 'month': 'Jun'},
    {'day': '17', 'month': 'Jun'},
  ];
  int selectedDateIndex = 2; // Índice del día seleccionado (14)

  // Navigation bar
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNutritionPlans();
  }

  Future<void> _loadNutritionPlans() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        final plans = await NutritionPlanService.getMyNutritionPlans(
          authProvider.token!,
        );
        setState(() {
          nutritionPlans = plans;
          isLoadingPlans = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoadingPlans = false;
      });
    }
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Aquí puedes agregar la navegación según el índice
    switch (index) {
      case 0:
      // Ya estamos en Home
        break;
      case 1:
      // Navegar a Recetas
      Navigator.pushNamed(context, RouteNames.recipes);
        break;
      case 2:
      // Navegar a Perfil
      // Navigator.pushNamed(context, RouteNames.profile);
        break;
    }
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
            onRefresh: _loadNutritionPlans,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo personalizado
                  Text(
                    'Hola! ${patient.firstName}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Calendario horizontal
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      itemBuilder: (context, index) {
                        final date = dates[index];
                        final isSelected = index == selectedDateIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDateIndex = index;
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${date['month']} ${date['day']}',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Imagen y frase motivacional
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_hospital, size: 48, color: Colors.orange),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            '"Comer bien es parte del tratamiento, no solo una opción."\n— Dr. Yordi Diaz',
                            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Comidas del día
                  const Text(
                    'Hoy, Comidas del día',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Mostrar comidas según el plan nutricional
                  if (isLoadingPlans)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (nutritionPlans.isNotEmpty)
                    _buildTodayMeals(nutritionPlans.first)
                  else
                    _buildDefaultMeals(),

                  const SizedBox(height: 32),

                  // Sección de planes nutricionales (versión compacta)
                  if (nutritionPlans.isNotEmpty) ...[
                    const Text(
                      'Tu Plan Nutricional',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildCompactNutritionPlan(nutritionPlans.first),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildTodayMeals(NutritionPlan plan) {
    // Agrupar comidas por tipo
    final breakfastMeals = plan.getDetailsByMealType('desayuno');
    final lunchMeals = plan.getDetailsByMealType('almuerzo');
    final dinnerMeals = plan.getDetailsByMealType('dinner');
    final snackMeals = plan.getDetailsByMealType('snack');

    return Column(
      children: [
        if (breakfastMeals.isNotEmpty)
          _buildMealTile(breakfastMeals.first.mealType, breakfastMeals.first.creationDate, breakfastMeals.first.description),
        if (snackMeals.isNotEmpty)
          _buildMealTile('Media mañana',breakfastMeals.first.creationDate, breakfastMeals.first.description),
        if (lunchMeals.isNotEmpty)
          _buildMealTile('almuerzo', breakfastMeals.first.creationDate, breakfastMeals.first.description),
        if (dinnerMeals.isNotEmpty)
          _buildMealTile('Cena', breakfastMeals.first.creationDate, breakfastMeals.first.description),
      ],
    );
  }

  Widget _buildDefaultMeals() {
    return Column(
      children: [
        _buildMealTile('Desayuno', '7:00 am', 'Pendiente de asignación'),
        _buildMealTile('Media mañana', '10:00 am', 'Pendiente de asignación'),
        _buildMealTile('Almuerzo', '12:30 pm', 'Pendiente de asignación'),
        _buildMealTile('Cena', '7:00 pm', 'Pendiente de asignación'),
      ],
    );
  }

  Widget _buildMealTile(String title, String time, [String? mealName]) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.restaurant_menu, color: Colors.orange),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time),
            if (mealName != null)
              Text(
                mealName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Aquí puedes agregar navegación a los detalles de la comida
        },
      ),
    );
  }

  Widget _buildCompactNutritionPlan(NutritionPlan plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Nutricional #${plan.planId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Creado: ${plan.creationDate}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(plan.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(plan.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlanStat('Calorías', '${plan.totalCalories} kcal'),
              _buildPlanStat('Comidas', '${plan.details.length}'),
              _buildPlanStat('Energía', '${plan.energyRequirement} kcal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Métodos auxiliares
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'activo':
        return Colors.green;
      case 'pending':
      case 'pendiente':
        return Colors.orange;
      case 'completed':
      case 'completado':
        return Colors.blue;
      case 'cancelled':
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Activo';
      case 'pending':
        return 'Pendiente';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status.toUpperCase();
    }
  }
}

// Widget del Navigation Bar
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.playlist_add_check),
          label: 'Recetas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}