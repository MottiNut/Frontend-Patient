import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';

class HeightWeightScreen extends StatefulWidget {
  final double? initialHeight; // Altura inicial en metros
  final int? initialWeight; // Peso inicial en kg
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

  // Listas de opciones
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

    // Usar valores iniciales o valores por defecto
    _selectedHeight = widget.initialHeight ?? 1.65;
    _selectedWeight = widget.initialWeight ?? 70;

    // Asegurar que los valores iniciales estén en las listas
    if (!_heights.contains(_selectedHeight)) {
      _selectedHeight = 1.65; // Valor por defecto si no está en la lista
    }
    if (!_weights.contains(_selectedWeight)) {
      _selectedWeight = 70; // Valor por defecto si no está en la lista
    }

    // Llamar al callback con los valores iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValuesChanged(_selectedHeight, _selectedWeight);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '¿Cuál es tu peso y altura?',
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.mainOrange,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Proporciona más información y podré ayudarte mejor',
          style: AppTextStyles.description.copyWith(
            color: Colors.grey[600],
            fontSize: 14,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        // Altura
        const Text(
            'Altura',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _heights.length,
            itemBuilder: (context, index) {
              final height = _heights[index];
              final isSelected = _selectedHeight == height;
              return GestureDetector(
                onTap: () => _updateHeight(height),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.mainOrange : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${height.toStringAsFixed(2)} m',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 32),

        // Peso
        const Text(
            'Peso',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _weights.length,
            itemBuilder: (context, index) {
              final weight = _weights[index];
              final isSelected = _selectedWeight == weight;
              return GestureDetector(
                onTap: () => _updateWeight(weight),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.mainOrange : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$weight kg',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // Información adicional (opcional)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightOrange),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.mainOrange, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Altura: ${_selectedHeight.toStringAsFixed(2)} m • Peso: $_selectedWeight kg',
                  style: TextStyle(
                    color: AppColors.darkOrange1,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}