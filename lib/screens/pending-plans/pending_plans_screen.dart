import 'package:flutter/material.dart';
import 'package:frontendpatient/screens/pending-plans/widgets/empty_state_widget.dart';
import 'package:frontendpatient/screens/pending-plans/widgets/error_state_widget.dart';
import 'package:frontendpatient/screens/pending-plans/widgets/plan_card.dart';
import 'package:frontendpatient/screens/pending-plans/widgets/plan_details_dialog.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import '../../widgets/app_navigation_handler.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'controllers/pending_plans_controller.dart';


class PendingPlansScreen extends StatefulWidget {
  const PendingPlansScreen({super.key});

  @override
  State<PendingPlansScreen> createState() => _PendingPlansScreenState();
}

class _PendingPlansScreenState extends State<PendingPlansScreen> {
  late PendingPlansController _controller;

  @override
  void initState() {
    super.initState();
    AppNavigationHandler.setCurrentIndex(2);
    _controller = PendingPlansController();
    _controller.loadPendingPlans();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _respondToPlan(int planId, bool accept, String? feedback, {bool fromDialog = false}) async {
    try {
      final message = await _controller.respondToPlan(planId, accept, feedback);
      _showSuccessDialog(message);

      if (fromDialog) {
        await Future.delayed(const Duration(seconds: 1));
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showPlanDetails(plan) {
    showDialog(
      context: context,
      builder: (context) => PlanDetailsDialog(
        plan: plan,
        onAccept: (feedback) => _respondToPlan(plan.planId, true, feedback, fromDialog: true),
        onReject: (feedback) => _respondToPlan(plan.planId, false, feedback, fromDialog: true),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éxito'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Planes Pendientes'),
          backgroundColor: AppColors.mainOrange,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _controller.loadPendingPlans,
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: AppNavigationHandler.currentIndex,
          onTap: (index) => AppNavigationHandler.handleNavigation(context, index),
        ),
        body: Consumer<PendingPlansController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return ErrorStateWidget(
                errorMessage: controller.errorMessage!,
                onRetry: controller.loadPendingPlans,
              );
            }

            if (controller.pendingPlans.isEmpty) {
              return const EmptyStateWidget();
            }

            return RefreshIndicator(
              onRefresh: controller.loadPendingPlans,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.pendingPlans.length,
                itemBuilder: (context, index) {
                  final plan = controller.pendingPlans[index];
                  return PlanCard(
                    plan: plan,
                    onTap: () => _showPlanDetails(plan),
                    onRespond: (planId, accept, feedback) =>
                        _respondToPlan(planId, accept, feedback),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}