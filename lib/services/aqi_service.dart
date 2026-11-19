import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/aqi_data.dart';

/// Service to fetch real-time AQI data from the WAQI API.
///
/// API docs: https://aqicn.org/json-api/doc/
class AqiService {
  final http.Client _client;

  AqiService({http.Client? client}) : _client = client ?? http.Client();

  // ════════════════════════════════════════════════════════════════
  // Fetch current AQI by coordinates
  // ════════════════════════════════════════════════════════════════
  Future<AqiData> fetchCurrentAqi(double lat, double lng) async {
    final url = ApiConfig.waqiGeoUrl(lat, lng);
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('WAQI API error: HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['status'] != 'ok') {
      throw Exception('WAQI API error: ${json['data'] ?? 'Unknown error'}');
    }

    final data = json['data'] as Map<String, dynamic>;
    return _parseAqiData(data);
  }

  // ════════════════════════════════════════════════════════════════
  // Fetch current AQI by city name (e.g. "delhi", "mumbai")
  // ════════════════════════════════════════════════════════════════
  Future<AqiData> fetchAqiByCity(String city) async {
    final url = ApiConfig.waqiCityUrl(city);
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('WAQI API error: HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['status'] != 'ok') {
      throw Exception('WAQI API error: ${json['data'] ?? 'Unknown error'}');
    }

    final data = json['data'] as Map<String, dynamic>;
    return _parseAqiData(data);
  }

  // ════════════════════════════════════════════════════════════════
  // Fetch 24-hour forecast from the same response
  // ════════════════════════════════════════════════════════════════
  Future<List<AqiForecast>> fetchForecast(double lat, double lng) async {
    final url = ApiConfig.waqiGeoUrl(lat, lng);
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode != 200) return [];

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['status'] != 'ok') return [];

    final data = json['data'] as Map<String, dynamic>;
    return _parseForecast(data);
  }

  // ════════════════════════════════════════════════════════════════
  // Fetch AQI at a specific point (used for route scoring)
  // ════════════════════════════════════════════════════════════════
  Future<int> fetchAqiAtPoint(double lat, double lng) async {
    try {
      final aqiData = await fetchCurrentAqi(lat, lng);
      return aqiData.aqi;
    } catch (_) {
      return -1; // Indicate failure
    }
  }

  // ════════════════════════════════════════════════════════════════
  // Search for AQI stations by keyword
  // ════════════════════════════════════════════════════════════════
  Future<List<AqiStation>> searchStations(String keyword) async {
    final url = ApiConfig.waqiSearchUrl(keyword);
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode != 200) return [];

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['status'] != 'ok') return [];

    final results = json['data'] as List;
    return results.map((item) {
      final station = item as Map<String, dynamic>;
      final geo = station['station']?['geo'] as List?;
      return AqiStation(
        uid: station['uid'] as int? ?? 0,
        name: station['station']?['name'] as String? ?? '',
        aqi: int.tryParse(station['aqi']?.toString() ?? '') ?? 0,
        latitude: geo != null && geo.length >= 2
            ? (geo[0] as num).toDouble()
            : 0.0,
        longitude: geo != null && geo.length >= 2
            ? (geo[1] as num).toDouble()
            : 0.0,
      );
    }).toList();
  }

  // ── Internal parsers ──────────────────────────────────────────

  AqiData _parseAqiData(Map<String, dynamic> data) {
    // AQI value
    final aqi = (data['aqi'] is int)
        ? data['aqi'] as int
        : int.tryParse(data['aqi'].toString()) ?? 0;

    // Station location
    final city = data['city'] as Map<String, dynamic>? ?? {};
    final geo = city['geo'] as List? ?? [];
    final lat = geo.isNotEmpty ? (geo[0] as num).toDouble() : 0.0;
    final lng = geo.length > 1 ? (geo[1] as num).toDouble() : 0.0;
    final locationName = city['name'] as String? ?? 'Unknown';

    // Dominant pollutant
    final dominantPol = data['dominentpol'] as String? ?? 'pm25';

    // Individual pollutant readings from iaqi
    final iaqi = data['iaqi'] as Map<String, dynamic>? ?? {};
    final pollutants = <String, double>{};
    for (final key in ['pm25', 'pm10', 'o3', 'no2', 'so2', 'co']) {
      final entry = iaqi[key] as Map<String, dynamic>?;
      if (entry != null && entry['v'] != null) {
        pollutants[key] = (entry['v'] as num).toDouble();
      }
    }

    // Timestamp
    final timeData = data['time'] as Map<String, dynamic>? ?? {};
    final isoTime = timeData['iso'] as String?;
    final timestamp =
        isoTime != null ? DateTime.tryParse(isoTime) ?? DateTime.now() : DateTime.now();

    return AqiData(
      aqi: aqi,
      category: _category(aqi),
      emoji: _emoji(aqi),
      dominantPollutant: dominantPol,
      pollutants: pollutants,
      timestamp: timestamp,
      latitude: lat,
      longitude: lng,
      locationName: locationName,
    );
  }

  List<AqiForecast> _parseForecast(Map<String, dynamic> data) {
    final forecast = data['forecast'] as Map<String, dynamic>?;
    if (forecast == null) return [];

    final daily = forecast['daily'] as Map<String, dynamic>? ?? {};
    // Use PM2.5 forecast as the primary forecast series
    final pm25Forecast = daily['pm25'] as List?;
    if (pm25Forecast == null || pm25Forecast.isEmpty) return [];

    return pm25Forecast.map((item) {
      final entry = item as Map<String, dynamic>;
      final avg = entry['avg'] as int? ?? 0;
      final day = entry['day'] as String? ?? '';
      final date = DateTime.tryParse(day) ?? DateTime.now();
      return AqiForecast(
        time: date,
        aqi: avg,
        category: _category(avg),
      );
    }).toList();
  }

  // ── AQI category helpers ──────────────────────────────────────

  static String _category(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  static String _emoji(int aqi) {
    if (aqi <= 50) return '😊';
    if (aqi <= 100) return '😐';
    if (aqi <= 150) return '😷';
    if (aqi <= 200) return '🤢';
    if (aqi <= 300) return '🤮';
    return '☠️';
  }
}

/// A monitoring station returned by the search API.
class AqiStation {
  final int uid;
  final String name;
  final int aqi;
  final double latitude;
  final double longitude;

  const AqiStation({
    required this.uid,
    required this.name,
    required this.aqi,
    required this.latitude,
    required this.longitude,
  });
}
