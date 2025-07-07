import 'package:flutter/material.dart';

class PredictButton extends StatelessWidget {
  final VoidCallback onTap;

  const PredictButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.auto_awesome, color: Colors.white),
      label: const Text(
        'Predict with AI',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Fondo azul
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Bordes redondeados
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 4,
      ),
    );
  }
}
