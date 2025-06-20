import 'package:flutter/material.dart';
import 'package:frontendpatient/screens/recipes/widgets/day_plan_widget.dart';
import 'package:frontendpatient/screens/recipes/widgets/no_plan_widget.dart';
import 'package:frontendpatient/screens/recipes/widgets/recipes_error_widget.dart';
import 'package:provider/provider.dart';
import '../../models/nutrition_plan/nutririon_plan_model.dart';
import '../../providers/auth_provider.dart';
import '../../service/nutrition_plan_service.dart';
import '../../shared/widgets/app_navigation_handler.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/custom_app_bar.dart';

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
      appBar: const CustomAppBar(),
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
            return const NoPlanWidget();
          }

          return Column(
            children: [
              _buildPlanHeader(),
              _buildTabBarView(),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: AppNavigationHandler.currentIndex, // Usar el handler
        onTap: (index) => AppNavigationHandler.handleNavigation(context, index),
      ),
    );
  }

  Widget _buildPlanHeader() {
    return Container(
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
    );
  }

  Widget _buildTabBarView() {
    return Expanded(
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