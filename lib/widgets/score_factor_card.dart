import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../config/theme.dart';
import '../models/score_data.dart';
import 'glass_card.dart';

/// Card showing a single score factor with circular progress and label.
class ScoreFactorCard extends StatelessWidget {
  final ScoreFactor factor;

  const ScoreFactorCard({super.key, required this.factor});

  @override
  Widget build(BuildContext context) {
    final color = _colorForImpact(factor.impact);
    final icon = _iconForId(factor.icon);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 30,
            lineWidth: 5,
            percent: factor.score / 100,
            center: Icon(icon, size: 22, color: color),
            progressColor: color,
            backgroundColor: Colors.white.withOpacity(0.08),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1200,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  factor.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  factor.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                '${factor.score}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                '${(factor.weight * 100).round()}%',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorForImpact(ScoreImpact impact) {
    switch (impact) {
      case ScoreImpact.positive:
        return AppTheme.accentGreen;
      case ScoreImpact.neutral:
        return AppTheme.accentOrange;
      case ScoreImpact.negative:
        return AppTheme.accentRed;
    }
  }

  IconData _iconForId(String id) {
    switch (id) {
      case 'cloud':
        return Icons.cloud_outlined;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'home':
        return Icons.home_outlined;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.info_outline;
    }
  }
}
