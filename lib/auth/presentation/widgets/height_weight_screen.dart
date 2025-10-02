import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontendpatient/commons/themes/app_theme.dart';

import '../../../commons/widgets/requestSnacbar/snackBar_manager.dart';

class HeightWeightScreen extends StatefulWidget {
  final double? initialHeight;
  final int? initialWeight;
  final Function(double height, int weight) onValuesChanged;

  const HeightWeightScreen({
    super.key,
    this.initialHeight,
    this.initialWeight,
    required this.onValuesChanged,
  });

  @override
  State<HeightWeightScreen> createState() => _HeightWeightScreenState();
}

class _HeightWeightScreenState extends State<HeightWeightScreen> {
  late double _selectedHeight;
  late int _selectedWeight;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  bool _isEditMode = false;

  final List<double> _heights = [
    1.40, 1.42, 1.44, 1.46, 1.48, 1.50, 1.52, 1.54, 1.56, 1.58,
    1.60, 1.62, 1.64, 1.66, 1.68, 1.70, 1.72, 1.74, 1.76, 1.78,
    1.80, 1.82, 1.84, 1.86, 1.88, 1.90, 1.92, 1.94, 1.96, 1.98, 2.00
  ];

  final List<int> _weights = [
    40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70,
    72, 74, 76, 78, 80, 82, 84, 86, 88, 90, 92, 94, 96, 98, 100,
    102, 104, 106, 108, 110, 112, 114, 116, 118, 120
  ];

  @override
  void initState() {
    super.initState();
    _selectedHeight = widget.initialHeight ?? 1.65;
    _selectedWeight = widget.initialWeight ?? 70;

    if (!_heights.contains(_selectedHeight)) {
      _selectedHeight = 1.65;
    }
    if (!_weights.contains(_selectedWeight)) {
      _selectedWeight = 70;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValuesChanged(_selectedHeight, _selectedWeight);
    });
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      if (_isEditMode) {
        final heightValue = double.tryParse(_heightController.text);
        final weightValue = int.tryParse(_weightController.text);

        bool hasError = false;

        if (heightValue != null && heightValue >= 1.0 && heightValue <= 2.5) {
      _selectedHeight = heightValue;
      } else {
      SnackBarManager.showWarning(
      context,
      'Altura válida: 1.0 - 2.5 m',
      );
      hasError = true;
      }

      if (weightValue != null && weightValue >= 30 && weightValue <= 300) {
      _selectedWeight = weightValue;
      } else {
      SnackBarManager.showWarning(
      context,
      'Peso válido: 30 - 300 kg',
      );
      hasError = true;
      }

      if (!hasError) {
      widget.onValuesChanged(_selectedHeight, _selectedWeight);
      _isEditMode = !_isEditMode;
      }
      } else {

      _heightController.text = _selectedHeight.toStringAsFixed(2);
      _weightController.text = _selectedWeight.toString();
      _isEditMode = !_isEditMode;
      }
    });
  }

  void _updateHeight(double height) {
    setState(() {
      _selectedHeight = height;
    });
    widget.onValuesChanged(_selectedHeight, _selectedWeight);
  }

  void _updateWeight(int weight) {
    setState(() {
      _selectedWeight = weight;
    });
    widget.onValuesChanged(_selectedHeight, _selectedWeight);
  }

  double _calculateBMI() {
    return _selectedWeight / (_selectedHeight * _selectedHeight);
  }

  String _getBMICategory() {
    final bmi = _calculateBMI();
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Color _getBMIColor() {
    final bmi = _calculateBMI();
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '¿Cuál es tu peso y altura?',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.mainOrange,
                        letterSpacing: 0,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Proporciona más información y podré ayudarte mejor',
                      style: AppTextStyles.description.copyWith(
                        color: Colors.grey[600],
                        fontSize: 13,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: _isEditMode ? Colors.green : AppColors.mainOrange,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  onPressed: _toggleMode,
                  icon: Icon(
                  _isEditMode ? Icons.check : Icons.edit,
                  color: Colors.white,
                  size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: _isEditMode ? 'Guardar' : 'Editar manualmente',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),


          if (!_isEditMode) ...[

            _buildSelectionMode(),
          ] else ...[

            _buildEditMode(),
          ],

          const SizedBox(height: 20),


          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getBMIColor().withOpacity(0.15),
                  _getBMIColor().withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _getBMIColor().withOpacity(0.3), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getBMIColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _calculateBMI().toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const Text(
                        'IMC',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Índice de Masa Corporal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getBMICategory(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getBMIColor(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[500], size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${_selectedHeight.toStringAsFixed(2)} m • $_selectedWeight kg',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSelectionMode() {
    return Column(
      children: [

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.height, color: AppColors.mainOrange, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'Altura',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${_selectedHeight.toStringAsFixed(2)} m',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 65,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _heights.length,
                  itemBuilder: (context, index) {
                    final height = _heights[index];
                    final isSelected = _selectedHeight == height;
                    return GestureDetector(
                      onTap: () => _updateHeight(height),
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.mainOrange : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${height.toStringAsFixed(2)}\nm',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Peso con selección
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.monitor_weight, color: AppColors.mainOrange, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'Peso',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '$_selectedWeight kg',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 65,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _weights.length,
                  itemBuilder: (context, index) {
                    final weight = _weights[index];
                    final isSelected = _selectedWeight == weight;
                    return GestureDetector(
                      onTap: () => _updateWeight(weight),
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.mainOrange : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$weight\nkg',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Campo de altura
          Row(
            children: [
              Icon(Icons.height, color: AppColors.mainOrange, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainOrange,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Altura',
                    hintText: '0.00',
                    suffixText: 'm',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.mainOrange, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Campo de peso
          Row(
            children: [
              Icon(Icons.monitor_weight, color: AppColors.mainOrange, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainOrange,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Peso',
                    hintText: '0',
                    suffixText: 'kg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.mainOrange, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}