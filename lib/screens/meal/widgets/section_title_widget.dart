// lib/widgets/meal_detail/section_title_widget.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/themes/app_theme.dart';

class SectionTitleWidget extends StatelessWidget {
  final String title;

  const SectionTitleWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.subtitulo,
    );
  }
}