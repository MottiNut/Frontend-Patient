import 'package:flutter/material.dart';
import 'package:frontendpatient/models/nutrition_plan/nutririon_plan_model.dart';
import 'package:frontendpatient/services/nutrition_plan_service.dart';

class PendingPlansController extends ChangeNotifier {
  final NutritionPlanService _planService = NutritionPlanService();

  List<PendingPatientAcceptance> _pendingPlans = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<PendingPatientAcceptance> get pendingPlans => _pendingPlans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPendingPlans() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final plans = await _planService.getPendingAcceptancePlans();

      _pendingPlans = plans;
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  Future<String> respondToPlan(int planId, bool accept, String? feedback) async {
    _setLoading(true);

    try {
      String message;
      if (accept) {
        message = await _planService.acceptPlan(planId, feedback: feedback);
      } else {
        message = await _planService.rejectPlan(planId, feedback: feedback);
      }

      String displayMessage = accept ? 'Plan aceptado exitosamente' : 'Plan rechazado exitosamente';
      if (feedback != null && feedback.isNotEmpty) {
        displayMessage += accept ? '\nCon comentarios: $feedback' : '\nMotivo: $feedback';
      }

      await loadPendingPlans();
      return displayMessage;
    } catch (e) {
      _setLoading(false);
      throw Exception('Error al responder al plan: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _planService.dispose();
    super.dispose();
  }
}