import 'package:flutter/material.dart';
import 'package:frontendpatient/nutrition_plan/domain/models/weekly_plan.dart';
import 'package:frontendpatient/nutrition_plan/presentation/widgets/day_plan_widget.dart';
import 'package:frontendpatient/nutrition_plan/presentation/widgets/no_plan_widget.dart';
import 'package:frontendpatient/nutrition_plan/presentation/widgets/recipes_error_widget.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../application/services/nutrition_plan_service.dart';
import '../../../commons/widgets/custom_app_bar.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> with TickerProviderStateMixin {
  final NutritionPlanService _nutritionPlanService = NutritionPlanService();
  final PageController _pageController = PageController();

  // Variables para el header colapsable
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;
  // Variables para el deslizamiento en tiempo real
  double _headerHeight = 1.0; // 1.0 = completamente visible, 0.0 = completamente oculto
  bool _isHeaderCollapsed = false;
  double _startPanY = 0.0;
  final double _maxHeaderHeight = 200.0; // Altura máxima aproximada del header

  bool isLoadingWeeklyPlan = true;
  String? errorMessage;
  WeeklyPlan? weeklyPlan;
  int currentDayIndex = 0;

  final List<String> dayNames = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    _loadWeeklyPlan();

    // Inicializar la animación del header
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerAnimationController.dispose();
    _nutritionPlanService.dispose();
    super.dispose();
  }

  Future<void> _loadWeeklyPlan() async {
    try {
      if (!mounted) return;

      setState(() {
        isLoadingWeeklyPlan = true;
        errorMessage = null;
      });

      final plan = await _nutritionPlanService.getWeeklyPlan();

      if (!mounted) return;

      setState(() {
        weeklyPlan = plan;
        isLoadingWeeklyPlan = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoadingWeeklyPlan = false;
      });
    }
  }

  void _navigateToDay(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // El método _toggleHeader ahora puede ser simplificado o eliminado
  void _toggleHeader() {
    if (_isHeaderCollapsed) {
      _animateToHeight(1.0);
      _isHeaderCollapsed = false;
    } else {
      _animateToHeight(0.0);
      _isHeaderCollapsed = true;
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
              _buildCollapsibleHeader(),
              _buildDayIndicators(),
              _buildPageView(),
            ],
          );
        },
      ),
    );
  }

  void _animateToHeight(double targetHeight) {
    final currentHeight = _headerHeight;

    _headerAnimationController.reset();
    _headerAnimationController.addListener(() {
      setState(() {
        _headerHeight = currentHeight +
            (_headerAnimationController.value * (targetHeight - currentHeight));
      });
    });

    _headerAnimationController.forward();
  }

  Widget _buildCollapsibleHeader() {
    return GestureDetector(
      onPanStart: (details) {
        _startPanY = details.localPosition.dy;
      },
      onPanUpdate: (details) {
        final deltaY = details.localPosition.dy - _startPanY;
        final sensitivity = 0.005; // Ajusta la sensibilidad del deslizamiento

        setState(() {
          _headerHeight = (_headerHeight - (deltaY * sensitivity)).clamp(0.0, 1.0);
        });

        _startPanY = details.localPosition.dy;
      },
      onPanEnd: (details) {
        // Determinar si debe colapsar completamente o expandir completamente
        if (_headerHeight > 0.5) {
          // Expandir completamente
          _animateToHeight(1.0);
          _isHeaderCollapsed = false;
        } else {
          // Colapsar completamente
          _animateToHeight(0.0);
          _isHeaderCollapsed = true;
        }
      },
      child: Column(
        children: [
          ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: _headerHeight,
              child: _buildPlanHeader(),
            ),
          ),
          // Indicador persistente cuando está colapsado
          if (_headerHeight < 0.1) _buildCollapsedIndicator(),
        ],
      ),
    );
  }

  Widget _buildCollapsedIndicator() {
    return GestureDetector(
      onTap: () {
        _animateToHeight(1.0);
        _isHeaderCollapsed = false;
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          border: Border(
            bottom: BorderSide(color: Colors.orange.shade200, width: 0.5),
          ),
        ),
        child: Column(
          children: [
            // Texto indicativo
            Text(
              'Toca aquí o desliza hacia abajo para ver detalles',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            // Barra indicadora visual
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.orange.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            // Icono de flecha hacia abajo
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.orange.shade600,
              size: 20,
            ),
          ],
        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Objetivo: ${weeklyPlan!.goal}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _toggleHeader,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isHeaderCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
          // Indicador visual para el gesto de deslizar
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.orange.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayIndicators() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            dayNames.length,
                (index) => GestureDetector(
              onTap: () => _navigateToDay(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  maxWidth: 50,
                ),
                decoration: BoxDecoration(
                  color: currentDayIndex == index
                      ? Colors.orange
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: currentDayIndex == index
                        ? Colors.orange.shade700
                        : Colors.grey.shade300,
                  ),
                  boxShadow: currentDayIndex == index
                      ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    dayNames[index].substring(0, 3), // Abreviatura del día
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: currentDayIndex == index
                          ? Colors.white
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentDayIndex = index;
          });
        },
        itemCount: weeklyPlan!.dailyPlans.length,
        itemBuilder: (context, index) {
          final dailyPlan = weeklyPlan!.dailyPlans[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: RefreshIndicator(
              onRefresh: _loadWeeklyPlan,
              child: DayPlanWidget(
                dailyPlan: dailyPlan,
              ),
            ),
          );
        },
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