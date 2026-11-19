import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_data.dart';

/// Manages saving / loading the user's home location via SharedPreferences.
/// For actual GPS, the provider calls the geolocator package directly.
class LocationService {
  static const _homeKey = 'home_location';

  /// Persist user's chosen home location.
  Future<void> saveHomeLocation(LocationData location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_homeKey, jsonEncode(location.toJson()));
  }

  /// Load saved home location, or null if not set.
  Future<LocationData?> loadHomeLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_homeKey);
    if (raw == null) return null;
    return LocationData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Clear saved home.
  Future<void> clearHomeLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_homeKey);
  }
}
