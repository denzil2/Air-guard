/// AQI breakpoint ranges and labels used throughout the app.
class AqiConstants {
  AqiConstants._();

  static const double geofenceRadiusMeters = 200.0;
  static const int aqiRefreshIntervalSeconds = 300; // 5 minutes

  // AQI category breakpoints  (US EPA standard)
  static const List<AqiBreakpoint> breakpoints = [
    AqiBreakpoint(min: 0, max: 50, label: 'Good', emoji: '😊'),
    AqiBreakpoint(min: 51, max: 100, label: 'Moderate', emoji: '😐'),
    AqiBreakpoint(
        min: 101,
        max: 150,
        label: 'Unhealthy for Sensitive',
        emoji: '😷'),
    AqiBreakpoint(min: 151, max: 200, label: 'Unhealthy', emoji: '🤢'),
    AqiBreakpoint(min: 201, max: 300, label: 'Very Unhealthy', emoji: '🤮'),
    AqiBreakpoint(min: 301, max: 500, label: 'Hazardous', emoji: '☠️'),
  ];

  // Pollutant names
  static const Map<String, String> pollutantNames = {
    'pm25': 'PM₂.₅',
    'pm10': 'PM₁₀',
    'o3': 'O₃',
    'no2': 'NO₂',
    'so2': 'SO₂',
    'co': 'CO',
  };

  // Pollutant units
  static const Map<String, String> pollutantUnits = {
    'pm25': 'µg/m³',
    'pm10': 'µg/m³',
    'o3': 'ppb',
    'no2': 'ppb',
    'so2': 'ppb',
    'co': 'ppm',
  };
}

class AqiBreakpoint {
  final int min;
  final int max;
  final String label;
  final String emoji;

  const AqiBreakpoint({
    required this.min,
    required this.max,
    required this.label,
    required this.emoji,
  });
}
