import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../config/constants.dart';
import '../utils/aqi_utils.dart';

/// Displays a single pollutant row with name, value, bar, and unit.
class PollutantTile extends StatelessWidget {
  final String pollutantKey;
  final double value;

  const PollutantTile({
    super.key,
    required this.pollutantKey,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final name = AqiConstants.pollutantNames[pollutantKey] ?? pollutantKey;
    final unit = AqiConstants.pollutantUnits[pollutantKey] ?? '';
    // Rough percent for visual bar (each pollutant has different scale)
    final pct = (value / _maxForPollutant(pollutantKey)).clamp(0.0, 1.0);
    final color = AqiUtils.colorForAqi((pct * 300).round());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LinearPercentIndicator(
              lineHeight: 8,
              percent: pct,
              backgroundColor: Colors.white.withOpacity(0.08),
              linearGradient: LinearGradient(
                colors: [color.withOpacity(0.7), color],
              ),
              barRadius: const Radius.circular(4),
              padding: EdgeInsets.zero,
              animation: true,
              animationDuration: 1000,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              '${value.toStringAsFixed(1)} $unit',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _maxForPollutant(String key) {
    switch (key) {
      case 'pm25':
        return 150;
      case 'pm10':
        return 250;
      case 'o3':
        return 120;
      case 'no2':
        return 100;
      case 'so2':
        return 60;
      case 'co':
        return 10;
      default:
        return 100;
    }
  }
}
