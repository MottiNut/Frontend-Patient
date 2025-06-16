// birth_date_screen.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';
import 'package:frontendpatient/utils/validators.dart';

class BirthDateScreen extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateChanged;

  const BirthDateScreen({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de Nacimiento',
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.mainOrange,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Fecha de nacimiento',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onDateChanged(picked);
            }
          },
          readOnly: true,
          controller: TextEditingController(
            text: selectedDate?.toString().split(' ').first ?? '',
          ),
          validator: (value) => Validators.validateBirthDate(selectedDate),
        ),
      ],
    );
  }
}