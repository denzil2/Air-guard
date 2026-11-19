import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Maps AQI values to colors, labels, and advice.
class AqiUtils {
  AqiUtils._();

  static Color colorForAqi(int aqi) {
    if (aqi <= 50) return AppTheme.aqiGood;
    if (aqi <= 100) return AppTheme.aqiModerate;
    if (aqi <= 150) return AppTheme.aqiUnhealthySensitive;
    if (aqi <= 200) return AppTheme.aqiUnhealthy;
    if (aqi <= 300) return AppTheme.aqiVeryUnhealthy;
    return AppTheme.aqiHazardous;
  }

  static String labelForAqi(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  static String emojiForAqi(int aqi) {
    if (aqi <= 50) return '😊';
    if (aqi <= 100) return '😐';
    if (aqi <= 150) return '😷';
    if (aqi <= 200) return '🤢';
    if (aqi <= 300) return '🤮';
    return '☠️';
  }

  static String adviceForAqi(int aqi) {
    if (aqi <= 50) return 'Air quality is great. Enjoy outdoor activities!';
    if (aqi <= 100) return 'Acceptable air. Sensitive people should limit prolonged outdoor exertion.';
    if (aqi <= 150) return 'Sensitive groups may experience health effects. Reduce heavy outdoor exertion.';
    if (aqi <= 200) return 'Everyone may begin to experience health effects. Limit outdoor activity.';
    if (aqi <= 300) return 'Health alert! Avoid all outdoor physical activity.';
    return 'Health emergency! Stay indoors and keep windows closed.';
  }

  /// Progress 0.0 – 1.0 for gauge display (capped at 500).
  static double progressForAqi(int aqi) => (aqi / 500).clamp(0.0, 1.0);

  /// Gradient for the AQI gauge arc.
  static List<Color> get gaugeGradient => const [
        AppTheme.aqiGood,
        AppTheme.aqiModerate,
        AppTheme.aqiUnhealthySensitive,
        AppTheme.aqiUnhealthy,
        AppTheme.aqiVeryUnhealthy,
        AppTheme.aqiHazardous,
      ];
}
