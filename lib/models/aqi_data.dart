/// Represents a single AQI reading with pollutant breakdown.
class AqiData {
  final int aqi;
  final String category;
  final String emoji;
  final String dominantPollutant;
  final Map<String, double> pollutants;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String locationName;

  const AqiData({
    required this.aqi,
    required this.category,
    required this.emoji,
    required this.dominantPollutant,
    required this.pollutants,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.locationName = '',
  });

  AqiData copyWith({
    int? aqi,
    String? category,
    String? emoji,
    String? dominantPollutant,
    Map<String, double>? pollutants,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return AqiData(
      aqi: aqi ?? this.aqi,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      dominantPollutant: dominantPollutant ?? this.dominantPollutant,
      pollutants: pollutants ?? this.pollutants,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }

  /// Build from a JSON map (e.g. API response).
  factory AqiData.fromJson(Map<String, dynamic> json) {
    return AqiData(
      aqi: json['aqi'] as int,
      category: json['category'] as String,
      emoji: json['emoji'] as String? ?? '',
      dominantPollutant: json['dominant_pollutant'] as String,
      pollutants: Map<String, double>.from(json['pollutants'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationName: json['location_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'aqi': aqi,
        'category': category,
        'emoji': emoji,
        'dominant_pollutant': dominantPollutant,
        'pollutants': pollutants,
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
      };
}

/// A single hour of AQI forecast data.
class AqiForecast {
  final DateTime time;
  final int aqi;
  final String category;

  const AqiForecast({
    required this.time,
    required this.aqi,
    required this.category,
  });
}
