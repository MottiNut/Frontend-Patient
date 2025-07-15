import 'package:flutter/material.dart';
import 'package:frontendpatient/models/nutrition_plan/nutririon_plan_model.dart';
import 'package:frontendpatient/services/nutrition_plan_service.dart';

class PendingPlansController extends ChangeNotifier {
  final NutritionPlanService _planService = NutritionPlanService();

  // Variable para rastrear si el controller ha sido dispuesto
  bool _disposed = false;

  List<PendingPatientAcceptance> _pendingPlans = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<PendingPatientAcceptance> get pendingPlans => _pendingPlans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPendingPlans() async {
    if (_disposed) return; // Verificar si ya fue dispuesto

    try {
      _setLoading(true);
      _errorMessage = null;

      final plans = await _planService.getPendingAcceptancePlans();

      // Verificar nuevamente después de la operación asíncrona
      if (_disposed) return;

      _pendingPlans = plans;
      _setLoading(false);
    } catch (e) {
      // Verificar antes de actualizar el estado
      if (_disposed) return;

      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  Future<String> respondToPlan(int planId, bool accept, String? feedback) async {
    if (_disposed) return 'Controller was disposed'; // Verificar al inicio

    _setLoading(true);

    try {
      String message;
      if (accept) {
        message = await _planService.acceptPlan(planId, feedback: feedback);
      } else {
        message = await _planService.rejectPlan(planId, feedback: feedback);
      }

      // Verificar después de la operación asíncrona
      if (_disposed) return 'Controller was disposed';

      String displayMessage = accept ? 'Plan aceptado exitosamente' : 'Plan rechazado exitosamente';
      if (feedback != null && feedback.isNotEmpty) {
        displayMessage += accept ? '\nCon comentarios: $feedback' : '\nMotivo: $feedback';
      }

      await loadPendingPlans();
      return displayMessage;
    } catch (e) {
      // Verificar antes de actualizar el estado
      if (!_disposed) {
        _setLoading(false);
      }
      throw Exception('Error al responder al plan: $e');
    }
  }

  void _setLoading(bool loading) {
    // Verificar si el controller ya fue dispuesto antes de notificar
    if (_disposed) return;

    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true; // Marcar como dispuesto
    _planService.dispose();
    super.dispose();
  }
}