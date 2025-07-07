import 'package:flutter/material.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/tip_card.dart';

class BpmTipsListWidget extends StatelessWidget {
  const BpmTipsListWidget({super.key});

  final List<TipItem> tips = const [
    TipItem(
      range: '< 60 BPM',
      icon: Icons.warning_amber,
      color: Colors.orange,
      text:
          'Low heart rate. May indicate fatigue, bradycardia, or medical issues. Veterinary advice recommended.',
    ),
    TipItem(
      range: '60 - 100 BPM',
      icon: Icons.favorite,
      color: Colors.green,
      text:
          'Normal resting heart rate. Your pet appears to be healthy and relaxed.',
    ),
    TipItem(
      range: '101 - 140 BPM',
      icon: Icons.monitor_heart,
      color: Colors.yellow,
      text:
          'Slightly elevated. Could be caused by excitement, physical activity, or stress.',
    ),
    TipItem(
      range: '> 140 BPM',
      icon: Icons.heart_broken,
      color: Colors.red,
      text:
          'High heart rate. May indicate fever, pain, or serious heart conditions. Seek immediate attention.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tips.map((tip) => TipCardWithAccentBorder(tip)).toList(),
    );
  }
}
