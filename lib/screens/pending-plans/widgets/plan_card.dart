import 'package:flutter/material.dart';
import '../../../models/nutrition_plan/nutririon_plan_model.dart';
import '../utils/date_formatter.dart';

class PlanCard extends StatelessWidget {
  final PendingPatientAcceptance plan;
  final VoidCallback onTap;
  final Function(int, bool, String?) onRespond;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildPlanInfo(),
              if (plan.reviewNotes != null) ...[
                const SizedBox(height: 12),
                _buildReviewNotes(),
              ],
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
    );
  }

  Widget _buildPlanInfo() {
    return Column(
      children: [
        _buildInfoRow(Icons.calendar_today, 'ID', '${plan.planId}'),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.calendar_today, 'Semana del', DateFormatter.formatDate(plan.weekStartDate)),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.local_fire_department, 'Energía requerida', '${plan.energyRequirement} kcal'),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.flag, 'Objetivo', plan.goal),
        if (plan.specialRequirements != null) ...[
          const SizedBox(height: 8),
          _buildInfoRow(Icons.warning, 'Requisitos especiales', plan.specialRequirements!),
        ],
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
          Row(
            children: [
              Icon(Icons.note, color: Colors.blue[700], size: 16),
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
          Text(plan.reviewNotes!, style: const TextStyle(fontSize: 14)),
          if (plan.reviewedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Revisado el: ${DateFormatter.formatDateTime(plan.reviewedAt!)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onRespond(plan.planId, false, null),
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
            onPressed: () => onRespond(plan.planId, true, null),
            icon: const Icon(Icons.check),
            label: const Text('Aceptar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}