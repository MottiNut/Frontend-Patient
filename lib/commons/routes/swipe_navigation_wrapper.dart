// shared/widgets/swipe_navigation_wrapper.dart
import 'package:flutter/material.dart';
import '../widgets/home/home_screen.dart';
import '../../nutrition_plan/presentation/screens/recipes_screen.dart';
import '../../nutrition_plan/presentation/screens/pending_plans_screen.dart';
import '../../auth/presentation/screens/profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/settings_drawer.dart'; // Importa tu SettingsDrawer

class SwipeNavigationWrapper extends StatefulWidget {
  final int initialIndex;

  const SwipeNavigationWrapper({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<SwipeNavigationWrapper> createState() => _SwipeNavigationWrapperState();
}

class _SwipeNavigationWrapperState extends State<SwipeNavigationWrapper> {
  late PageController _pageController;
  late int _currentIndex;

  final List<Widget> _pages = [
    const PatientHomeScreen(),
    const RecipesScreen(),
    const PendingPlansScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onBottomNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Aquí es donde defines el drawer que se verá por encima del bottomNavigationBar
      drawer: const SettingsDrawer(),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}

// Alternativa más avanzada con GestureDetector personalizado
class AdvancedSwipeNavigationWrapper extends StatefulWidget {
  final int initialIndex;

  const AdvancedSwipeNavigationWrapper({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AdvancedSwipeNavigationWrapper> createState() => _AdvancedSwipeNavigationWrapperState();
}

class _AdvancedSwipeNavigationWrapperState extends State<AdvancedSwipeNavigationWrapper>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final List<Widget> _pages = [
    const PatientHomeScreen(),
    const RecipesScreen(),
    const PendingPlansScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSwipe(DragEndDetails details) {
    const double sensitivity = 50.0;

    if (details.velocity.pixelsPerSecond.dx > sensitivity) {
      // Swipe a la derecha - página anterior
      _navigateToPage(_currentIndex - 1);
    } else if (details.velocity.pixelsPerSecond.dx < -sensitivity) {
      // Swipe a la izquierda - página siguiente
      _navigateToPage(_currentIndex + 1);
    }
  }

  void _navigateToPage(int index) {
    if (index < 0 || index >= _pages.length) return;

    setState(() {
      _currentIndex = index;
    });

    _animationController.reset();
    _animationController.forward();
  }

  void _onBottomNavTapped(int index) {
    _navigateToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Aquí también defines el drawer
      drawer: const SettingsDrawer(),
      body: GestureDetector(
        onPanEnd: _handleSwipe,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: Container(
            key: ValueKey<int>(_currentIndex),
            child: _pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}