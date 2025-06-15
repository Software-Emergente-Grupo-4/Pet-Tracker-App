import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HealthStatsBar extends StatelessWidget {
  final String bpm;
  final String spo2;

  const HealthStatsBar({
    super.key,
    required this.bpm,
    required this.spo2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/heartbeat.svg',
            width: 24,
            height: 24,
            colorFilter:
                const ColorFilter.mode(Color(0xFFE8F7FF), BlendMode.srcIn),
          ),
          const SizedBox(width: 4),
          Row(
            children: [
              Text(
                '$bpm ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8F7FF),
                ),
              ),
              const Text(
                'bpm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF49BEFF),
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 4),
          Row(
            children: [
              Text(
                '$spo2% ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8F7FF),
                ),
              ),
              const Text(
                'SpO₂',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF49BEFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
