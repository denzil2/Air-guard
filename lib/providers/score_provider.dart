import 'package:flutter/material.dart';

import '../models/score_data.dart';

/// Calculates & exposes the user's health-exposure score.
class ScoreProvider extends ChangeNotifier {
  ScoreData? _scoreData;
  bool _isLoading = false;

  ScoreData? get scoreData => _scoreData;
  bool get isLoading => _isLoading;
  int get overallScore => _scoreData?.overallScore ?? 0;
  String get grade => _scoreData?.grade ?? '--';

  /// Recalculate score from current inputs.
  void calculateScore({
    required int currentAqi,
    required Duration timeOutside,
    required Duration timeInside,
    required bool isInsideHome,
  }) {
    _isLoading = true;
    notifyListeners();

    // ── Factor 1: Current outdoor AQI ──────────────────────────
    final outdoorAqiScore = _aqiToScore(currentAqi);

    // ── Factor 2: Time spent outside today ─────────────────────
    final outsideHours = timeOutside.inMinutes / 60.0;
    final exposureScore = (100 - (outsideHours * 8).clamp(0, 60)).round();

    // ── Factor 3: Home air quality estimate ────────────────────
    final homeAqiScore = isInsideHome
        ? _aqiToScore((currentAqi * 0.4).round()) // indoor ~40% of outdoor
        : 70; // neutral when no data

    // ── Factor 4: Activity pattern ─────────────────────────────
    final totalHours = (timeInside + timeOutside).inMinutes / 60.0;
    final insideRatio = totalHours > 0
        ? timeInside.inMinutes / (timeInside + timeOutside).inMinutes
        : 0.5;
    final activityScore = (insideRatio * 100).round().clamp(0, 100);

    final factors = [
      ScoreFactor(
        id: 'outdoor_aqi',
        label: 'Outdoor Air Quality',
        description: 'AQI at your current location',
        score: outdoorAqiScore,
        weight: 0.35,
        icon: 'cloud',
        impact: outdoorAqiScore > 70
            ? ScoreImpact.positive
            : outdoorAqiScore > 40
                ? ScoreImpact.neutral
                : ScoreImpact.negative,
      ),
      ScoreFactor(
        id: 'exposure',
        label: 'Outdoor Exposure',
        description: 'Time spent in outdoor air today',
        score: exposureScore,
        weight: 0.25,
        icon: 'directions_walk',
        impact: exposureScore > 70
            ? ScoreImpact.positive
            : exposureScore > 40
                ? ScoreImpact.neutral
                : ScoreImpact.negative,
      ),
      ScoreFactor(
        id: 'home_aqi',
        label: 'Home Air Quality',
        description: 'Estimated indoor air quality',
        score: homeAqiScore,
        weight: 0.25,
        icon: 'home',
        impact: homeAqiScore > 70
            ? ScoreImpact.positive
            : homeAqiScore > 40
                ? ScoreImpact.neutral
                : ScoreImpact.negative,
      ),
      ScoreFactor(
        id: 'activity',
        label: 'Activity Pattern',
        description: 'Indoor vs outdoor time balance',
        score: activityScore,
        weight: 0.15,
        icon: 'fitness_center',
        impact: activityScore > 60
            ? ScoreImpact.positive
            : ScoreImpact.neutral,
      ),
    ];

    final overall = factors.fold<double>(
      0,
      (sum, f) => sum + f.score * f.weight,
    );

    _scoreData = ScoreData(
      overallScore: overall.round(),
      grade: _gradeFromScore(overall.round()),
      factors: factors,
      calculatedAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────
  int _aqiToScore(int aqi) {
    if (aqi <= 50) return 95;
    if (aqi <= 100) return 75;
    if (aqi <= 150) return 55;
    if (aqi <= 200) return 35;
    if (aqi <= 300) return 15;
    return 5;
  }

  String _gradeFromScore(int score) {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }
}
