import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';
import 'package:intl/intl.dart';
import '../../models/nutrition_plan/nutririon_plan_model.dart';
import '../../service/nutrition_plan_service.dart';
import '../../widgets/app_navigation_handler.dart';
import '../../widgets/bottom_nav_bar.dart';

class PendingPlansScreen extends StatefulWidget {
  const PendingPlansScreen({super.key});

  @override
  State<PendingPlansScreen> createState() => _PendingPlansScreenState();
}

class _PendingPlansScreenState extends State<PendingPlansScreen> {
  final NutritionPlanService _planService = NutritionPlanService();
  List<PendingPatientAcceptance> _pendingPlans = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    AppNavigationHandler.setCurrentIndex(2);
    _loadPendingPlans();
  }

  @override
  void dispose() {
    _planService.dispose();
    super.dispose();
  }

  Future<void> _loadPendingPlans() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final plans = await _planService.getPendingAcceptancePlans();

      setState(() {
        _pendingPlans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // MÉTODO ACTUALIZADO para manejar String en lugar de NutritionPlanResponse
  Future<void> _respondToPlan(int planId, bool accept, String? feedback, {bool fromDialog = false}) async {
    try {
      setState(() => _isLoading = true);

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

      _showSuccessDialog(displayMessage);

      // Si viene del diálogo, cerrar el diálogo automáticamente después de la acción
      if (fromDialog) {
        // Esperar un poco antes de cerrar para que el usuario vea el mensaje
        await Future.delayed(const Duration(seconds: 1));
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Cerrar el diálogo de detalles
        }
      }

      await _loadPendingPlans();
    } catch (e) {
      _showErrorDialog('Error al responder al plan: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showPlanDetails(PendingPatientAcceptance plan) {
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Planes Pendientes'),
        backgroundColor: AppColors.mainOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingPlans,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: AppNavigationHandler.currentIndex,
        onTap: (index) => AppNavigationHandler.handleNavigation(context, index),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los planes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPendingPlans,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_pendingPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in,
              size: 64,
              color: AppColors.lightOrange,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay planes pendientes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Todos tus planes han sido revisados',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingPlans,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingPlans.length,
        itemBuilder: (context, index) {
          final plan = _pendingPlans[index];
          return _buildPlanCard(plan);
        },
      ),
    );
  }

  Widget _buildPlanCard(PendingPatientAcceptance plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: () => _showPlanDetails(plan),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.green[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      plan.nutritionistName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Pendiente',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              _buildInfoRow(
                Icons.calendar_today,
                'ID',
                '${plan.planId}',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.calendar_today,
                'Semana del',
                _formatDate(plan.weekStartDate),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.local_fire_department,
                'Energía requerida',
                '${plan.energyRequirement} kcal',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.flag,
                'Objetivo',
                plan.goal,
              ),
              if (plan.specialRequirements != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.warning,
                  'Requisitos especiales',
                  plan.specialRequirements!,
                ),
              ],
              if (plan.reviewNotes != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.note,
                            color: Colors.blue[700],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Notas del nutricionista',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.reviewNotes!,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (plan.reviewedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Revisado el: ${_formatDateTime(plan.reviewedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _respondToPlan(plan.planId, false, null, fromDialog: false),
                      icon: const Icon(Icons.close),
                      label: const Text('Rechazar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _respondToPlan(plan.planId, true, null, fromDialog: false),
                      icon: const Icon(Icons.check),
                      label: const Text('Aceptar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PlanDetailsDialog extends StatefulWidget {
  final PendingPatientAcceptance plan;
  final Function(String?) onAccept;
  final Function(String?) onReject;

  const PlanDetailsDialog({
    Key? key,
    required this.plan,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  State<PlanDetailsDialog> createState() => _PlanDetailsDialogState();
}

class _PlanDetailsDialogState extends State<PlanDetailsDialog> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _showFeedback = false;
  bool _isAccepting = true;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleResponse(bool accept) {
    setState(() {
      _isAccepting = accept;
      _showFeedback = true;
    });
  }

  void _submitResponse() {
    final feedback = _feedbackController.text.trim();
    Navigator.of(context).pop();

    if (_isAccepting) {
      widget.onAccept(feedback.isEmpty ? null : feedback);
    } else {
      widget.onReject(feedback.isEmpty ? null : feedback);
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Detalles del Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Nutricionista', widget.plan.nutritionistName),
                    _buildDetailRow('Semana del', _formatDate(widget.plan.weekStartDate)),
                    _buildDetailRow('Energía requerida', '${widget.plan.energyRequirement} kcal'),
                    _buildDetailRow('Objetivo', widget.plan.goal),
                    if (widget.plan.specialRequirements != null)
                      _buildDetailRow('Requisitos especiales', widget.plan.specialRequirements!),
                    if (widget.plan.reviewNotes != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notas del nutricionista',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(widget.plan.reviewNotes!),
                            if (widget.plan.reviewedAt != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Revisado el: ${_formatDateTime(widget.plan.reviewedAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (_showFeedback) ...[
                      const SizedBox(height: 16),
                      Text(
                        _isAccepting ? 'Comentarios (opcional)' : 'Razón del rechazo (opcional)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _feedbackController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: _isAccepting
                              ? 'Agregar comentarios sobre el plan...'
                              : 'Explicar por qué rechazas el plan...',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _showFeedback
                  ? Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showFeedback = false;
                          _feedbackController.clear();
                        });
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitResponse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAccepting ? Colors.green[700] : Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isAccepting ? 'Aceptar' : 'Rechazar'),
                    ),
                  ),
                ],
              )
                  : Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleResponse(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleResponse(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}