import 'package:flutter/material.dart';
<<<<<<< Updated upstream

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Este es Recipe', style: TextStyle(fontSize: 24)),
    );
  }
}
=======
import 'package:frontendpatient/models/plan_detail.dart';
import 'package:frontendpatient/widgets/app_navigation_handler.dart';
import 'package:frontendpatient/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../models/nutrition_plan/nutririon_plan_model.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/route_names.dart';
import 'widgets/day_plan_widget.dart';
import 'widgets/error_widget.dart';
import 'widgets/no_plan_widget.dart';

//class RecipesScreen extends StatefulWidget {
//  const RecipesScreen({super.key});
//
//  @override
//  State<RecipesScreen> createState() => _RecipesScreenState();
//}
//
//class _RecipesScreenState extends State<RecipesScreen> with TickerProviderStateMixin {
//  final PlanService _planService = PlanService();
//  final AppNavigationHandler _navigationHandler = AppNavigationHandler();
//
//  late TabController _tabController;
//  bool isLoadingWeeklyPlan = true;
//  String? errorMessage;
//  WeeklyPlanResponse? weeklyPlan;
//
//  final List<String> dayNames = [
//    'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'
//  ];
//
//  final List<String> dayKeys = [
//    'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
//  ];
//
//  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
//
//  @override
//  void initState() {
//    super.initState();
//    _tabController = TabController(length: 7, vsync: this);
//    _loadWeeklyPlan();
//  }
//
//  @override
//  void dispose() {
//    _tabController.dispose();
//    super.dispose();
//  }
//
//  Future<void> _loadWeeklyPlan() async {
//    try {
//      setState(() {
//        isLoadingWeeklyPlan = true;
//        errorMessage = null;
//      });
//
//      final plan = await _planService.getMyWeeklyPlan();
//
//      setState(() {
//        weeklyPlan = plan;
//        isLoadingWeeklyPlan = false;
//      });
//    } catch (e) {
//      setState(() {
//        errorMessage = e.toString();
//        isLoadingWeeklyPlan = false;
//      });
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: const Text('Plan Semanal'),
//        backgroundColor: Colors.orange,
//        foregroundColor: Colors.white,
//        actions: [
//          IconButton(
//            icon: const Icon(Icons.refresh),
//            onPressed: _loadWeeklyPlan,
//          ),
//          PopupMenuButton<String>(
//            icon: const Icon(Icons.more_vert, color: Colors.white),
//            onSelected: (value) async {
//              if (value == 'logout') {
//                final authProvider = Provider.of<AuthProvider>(context, listen: false);
//                await authProvider.logout();
//                if (context.mounted) {
//                  Navigator.pushReplacementNamed(context, RouteNames.login);
//                }
//              }
//            },
//            itemBuilder: (BuildContext context) => [
//              const PopupMenuItem<String>(
//                value: 'logout',
//                child: Row(
//                  children: [
//                    Icon(Icons.logout, color: Colors.grey),
//                    SizedBox(width: 8),
//                    Text('Cerrar sesión'),
//                  ],
//                ),
//              ),
//            ],
//          ),
//        ],
//        bottom: TabBar(
//          controller: _tabController,
//          isScrollable: true,
//          labelColor: Colors.white,
//          unselectedLabelColor: Colors.white70,
//          indicatorColor: Colors.white,
//          tabs: dayNames.map((day) => Tab(text: day)).toList(),
//        ),
//      ),
//      body: Consumer<AuthProvider>(
//        builder: (context, authProvider, child) {
//          final patient = authProvider.currentUser;
//
//          if (patient == null) {
//            return const Center(
//              child: Text('Error: No se pudo cargar la información del usuario'),
//            );
//          }
//
//          if (isLoadingWeeklyPlan) {
//            return const Center(
//              child: CircularProgressIndicator(
//                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
//              ),
//            );
//          }
//
//          if (weeklyPlan == null || weeklyPlan!.dailyPlans.isEmpty) {
//            return NoPlanWidget();
//          }
//
//          if (errorMessage != null) {
//            return RecipesErrorWidget(
//              errorMessage: errorMessage,
//              onRetry: _loadWeeklyPlan,
//            );
//          }
//
//          return TabBarView(
//            controller: _tabController,
//            children: List.generate(7, (index) {
//              final dayKey = capitalize(dayKeys[index]);
//              final dayMeals = weeklyPlan!.dailyPlans[dayKey] ?? [];
//
//              return RefreshIndicator(
//                onRefresh: _loadWeeklyPlan,
//                child: DayPlanWidget(
//                  dayName: dayNames[index],
//                  meals: dayMeals,
//                ),
//              );
//            }),
//          );
//        },
//      ),
//      bottomNavigationBar: CustomBottomNavBar(
//        currentIndex: 1,
//        onTap: (index) => _navigationHandler.handleNavigation(context, index),
//      ),
//    );
//  }
//}
>>>>>>> Stashed changes
