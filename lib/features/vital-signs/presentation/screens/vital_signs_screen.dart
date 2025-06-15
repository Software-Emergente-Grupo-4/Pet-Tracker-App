import 'package:flutter/material.dart';

class VitalSignsScreen extends StatelessWidget {
  const VitalSignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Vital Signs Screen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ), 
          ),
        ],
      ),
    );
  }
}
