/// Individual score factor contributing to overall health score.
class ScoreData {
  final int overallScore; // 0-100
  final String grade; // A+ , A, B, C, D, F
  final List<ScoreFactor> factors;
  final DateTime calculatedAt;

  const ScoreData({
    required this.overallScore,
    required this.grade,
    required this.factors,
    required this.calculatedAt,
  });
}

class ScoreFactor {
  final String id;
  final String label;
  final String description;
  final int score; // 0-100
  final double weight; // 0.0 – 1.0
  final String icon; // Material icon name
  final ScoreImpact impact;

  const ScoreFactor({
    required this.id,
    required this.label,
    required this.description,
    required this.score,
    required this.weight,
    required this.icon,
    required this.impact,
  });
}

enum ScoreImpact { positive, neutral, negative }
