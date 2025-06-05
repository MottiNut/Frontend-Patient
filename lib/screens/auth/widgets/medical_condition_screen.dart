import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';

class MedicalConditionScreen extends StatelessWidget {
  final bool hasMedicalCondition;
  final Function(bool) onConditionChanged;

  const MedicalConditionScreen({
    super.key,
    required this.hasMedicalCondition,
    required this.onConditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Padeces algún tipo de enfermedad?',
          style: AppTextStyles.subtitulo.copyWith(
            color: AppColors.mainOrange,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Proporciona más información y podré ayudarte mejor',
          style: AppTextStyles.descripcion.copyWith(
            color: Colors.grey[600],
            fontSize: 14,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 25),
        YesNoButtons(
          initialValue: hasMedicalCondition,
          onChanged: onConditionChanged,
        ),
      ],
    );
  }
}

class YesNoButtons extends StatefulWidget {
  final bool initialValue;
  final Function(bool) onChanged;

  const YesNoButtons({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _YesNoButtonsState createState() => _YesNoButtonsState();
}

class _YesNoButtonsState extends State<YesNoButtons> {
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    // Inicializar con el valor recibido
    selectedOption = widget.initialValue ? 'SI' : 'NO';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildOptionButton('SI'),
        const SizedBox(width: 16),
        _buildOptionButton('NO'),
      ],
    );
  }

  Widget _buildOptionButton(String label) {
    final isSelected = selectedOption == label;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedOption = label;
        });
        // Llamar al callback con el valor booleano
        widget.onChanged(label == 'SI');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.orange : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}