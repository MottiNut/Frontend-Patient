import 'package:flutter/material.dart';
import '../../../models/nutrition_plan/nutririon_plan_model.dart';
import '../utils/date_formatter.dart';

class PlanDetailsDialog extends StatefulWidget {
  final PendingPatientAcceptance plan;
  final Function(String?) onAccept;
  final Function(String?) onReject;

  const PlanDetailsDialog({
    super.key,
    required this.plan,
    required this.onAccept,
    required this.onReject,
  });

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

  void _cancelFeedback() {
    setState(() {
      _showFeedback = false;
      _feedbackController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlanDetails(),
                    if (widget.plan.reviewNotes != null) ...[
                      const SizedBox(height: 16),
                      _buildReviewNotes(),
                    ],
                    if (_showFeedback) ...[
                      const SizedBox(height: 16),
                      _buildFeedbackSection(),
                    ],
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          const Icon(Icons.assignment, color: Colors.white),
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
    );
  }

  Widget _buildPlanDetails() {
    return Column(
      children: [
        _buildDetailRow('Nutricionista', widget.plan.nutritionistName),
        _buildDetailRow('Semana del', DateFormatter.formatDate(widget.plan.weekStartDate)),
        _buildDetailRow('Energía requerida', '${widget.plan.energyRequirement} kcal'),
        _buildDetailRow('Objetivo', widget.plan.goal),
        if (widget.plan.specialRequirements != null)
          _buildDetailRow('Requisitos especiales', widget.plan.specialRequirements!),
      ],
    );
  }

  Widget _buildReviewNotes() {
    return Container(
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
              'Revisado el: ${DateFormatter.formatDateTime(widget.plan.reviewedAt!)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isAccepting ? 'Comentarios (opcional)' : 'Razón del rechazo (opcional)',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _showFeedback ? _buildFeedbackButtons() : _buildInitialButtons(),
    );
  }

  Widget _buildFeedbackButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _cancelFeedback,
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
    );
  }

  Widget _buildInitialButtons() {
    return Row(
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