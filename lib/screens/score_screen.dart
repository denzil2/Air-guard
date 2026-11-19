import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../config/theme.dart';
import '../providers/score_provider.dart';
import '../providers/aqi_provider.dart';
import '../providers/geofence_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/score_factor_card.dart';

/// Screen showing the user's health-exposure score and breakdown.
class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  @override
  void initState() {
    super.initState();
    _calculateScore();
  }

  void _calculateScore() {
    final aqi = context.read<AqiProvider>().currentAqi;
    final gf = context.read<GeofenceProvider>();

    context.read<ScoreProvider>().calculateScore(
          currentAqi: aqi?.aqi ?? 100,
          timeOutside: gf.timeOutsideToday,
          timeInside: gf.timeInsideToday,
          isInsideHome: gf.isInsideHome,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Score'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _calculateScore,
          ),
        ],
      ),
      body: Consumer<ScoreProvider>(
        builder: (context, provider, _) {
          final score = provider.scoreData;
          if (score == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            );
          }

          final gradeColor = _gradeColor(score.grade);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Overall Score Circle ──────────────────────────
              Center(
                child: CircularPercentIndicator(
                  radius: 100,
                  lineWidth: 12,
                  percent: score.overallScore / 100,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        score.grade,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: gradeColor,
                        ),
                      ),
                      Text(
                        '${score.overallScore}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        'out of 100',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  progressColor: gradeColor,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 1500,
                ),
              ),

              const SizedBox(height: 10),
              Center(
                child: Text(
                  _gradeMessage(score.grade),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Section Title ─────────────────────────────────
              const Text(
                'Score Factors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What\'s affecting your air-health score today',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),

              const SizedBox(height: 16),

              // ── Factor Cards ──────────────────────────────────
              ...score.factors.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ScoreFactorCard(factor: f),
                ),
              ),

              const SizedBox(height: 20),

              // ── How it works ──────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppTheme.accent, size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          'How the Score Works',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your health score combines outdoor air quality, '
                      'time spent outside, estimated indoor air quality, '
                      'and your activity patterns. Each factor is weighted '
                      'to reflect its impact on your respiratory health.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return AppTheme.accentGreen;
      case 'B':
        return AppTheme.accent;
      case 'C':
        return AppTheme.accentOrange;
      default:
        return AppTheme.accentRed;
    }
  }

  String _gradeMessage(String grade) {
    switch (grade) {
      case 'A+':
        return 'Excellent! Your air exposure is very healthy today.';
      case 'A':
        return 'Great job keeping your exposure low.';
      case 'B':
        return 'Good, but there\'s room for improvement.';
      case 'C':
        return 'Moderate exposure. Consider spending more time indoors.';
      default:
        return 'High exposure detected. Take protective measures.';
    }
  }
}
