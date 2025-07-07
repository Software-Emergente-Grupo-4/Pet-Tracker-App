import 'package:flutter/material.dart';

class TipItem {
  final String range;
  final IconData icon;
  final Color color;
  final String text;

  const TipItem({
    required this.range,
    required this.icon,
    required this.color,
    required this.text,
  });
}

class TipCardWithAccentBorder extends StatelessWidget {
  final TipItem tip;

  const TipCardWithAccentBorder(this.tip);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: tip.color, width: 5),
        ),
      ),
      child: ListTile(
        leading: Icon(tip.icon, color: tip.color),
        title: Text(
          tip.range,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(tip.text),
      ),
    );
  }
}
