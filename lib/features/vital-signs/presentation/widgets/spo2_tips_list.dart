import 'package:flutter/material.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/tip_card.dart';

class Spo2TipsListWidget extends StatelessWidget {
  const Spo2TipsListWidget({super.key});

  final List<TipItem> tips = const [
    TipItem(
      range: '≥ 97%',
      icon: Icons.check_circle,
      color: Colors.green,
      text: 'Excellent oxygen saturation. No cause for concern.',
    ),
    TipItem(
      range: '94% - 96%',
      icon: Icons.info_outline,
      color: Colors.yellow,
      text:
          'Slight decrease in oxygen. Monitor your pet and ensure proper ventilation.',
    ),
    TipItem(
      range: '90% - 93%',
      icon: Icons.warning_amber,
      color: Colors.orange,
      text:
          'Low oxygen levels. Your pet may be experiencing respiratory discomfort. Consider consulting a vet.',
    ),
    TipItem(
      range: '< 90%',
      icon: Icons.error,
      color: Colors.red,
      text:
          'Critical level. Immediate veterinary attention is required to avoid serious complications.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tips.map((tip) => TipCardWithAccentBorder(tip)).toList(),
    );
  }
}
