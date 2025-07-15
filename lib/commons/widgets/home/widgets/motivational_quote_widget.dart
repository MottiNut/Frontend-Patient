// lib/widgets/patient/motivational_quote_widget.dart
import 'package:flutter/material.dart';

class MotivationalQuoteWidget extends StatelessWidget {
  const MotivationalQuoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade200,
            Colors.orange.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_hospital, size: 48, color: Colors.orange),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              '"Comer bien es parte del tratamiento, no solo una opción."\n— Dr. Yordi Diaz',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}