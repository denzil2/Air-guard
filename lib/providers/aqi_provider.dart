import 'dart:async';
import 'package:flutter/material.dart';

import '../models/aqi_data.dart';
import '../services/aqi_service.dart';

/// Manages real-time AQI state, polling, and forecast data.
/// Now connected to the live WAQI API.
class AqiProvider extends ChangeNotifier {
  final AqiService _service = AqiService();

  AqiData? _currentAqi;
  List<AqiForecast> _forecast = [];
  List<AqiData> _history = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // ── Getters ───────────────────────────────────────────────────
  AqiData? get currentAqi => _currentAqi;
  List<AqiForecast> get forecast => _forecast;
  List<AqiData> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _currentAqi != null;

  // ── Actions ───────────────────────────────────────────────────

  /// Fetch live AQI for given coordinates from WAQI API.
  Future<void> fetchAqi(double lat, double lng) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch current AQI (real API call)
      _currentAqi = await _service.fetchCurrentAqi(lat, lng);

      // Fetch forecast (may return empty if station has no forecast)
      _forecast = await _service.fetchForecast(lat, lng);

      // Keep last 24 readings in history
      if (_currentAqi != null) {
        _history = [..._history, _currentAqi!];
        if (_history.length > 24) {
          _history = _history.sublist(_history.length - 24);
        }
      }

      _retryCount = 0; // reset on success
      _isLoading = false;
      notifyListeners();

      // Auto-refresh every 5 minutes
      _startAutoRefresh(lat, lng);
    } catch (e) {
      _error = _friendlyError(e.toString());
      _isLoading = false;
      notifyListeners();

      // Retry with backoff (up to 3 times)
      if (_retryCount < _maxRetries) {
        _retryCount++;
        final delay = Duration(seconds: 5 * _retryCount);
        Future.delayed(delay, () => fetchAqi(lat, lng));
      }
    }
  }

  /// Fetch AQI by city name (e.g. "delhi", "mumbai").
  Future<void> fetchAqiByCity(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentAqi = await _service.fetchAqiByCity(city);

      if (_currentAqi != null) {
        _history = [..._history, _currentAqi!];
        if (_history.length > 24) {
          _history = _history.sublist(_history.length - 24);
        }

        // Also fetch forecast using the station's coordinates
        _forecast = await _service.fetchForecast(
          _currentAqi!.latitude,
          _currentAqi!.longitude,
        );
      }

      _retryCount = 0;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _friendlyError(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search for AQI monitoring stations.
  Future<List<AqiStation>> searchStations(String keyword) async {
    try {
      return await _service.searchStations(keyword);
    } catch (_) {
      return [];
    }
  }

  /// Force a manual refresh using the last-known location.
  Future<void> refresh() async {
    if (_currentAqi == null) return;
    _retryCount = 0;
    await fetchAqi(_currentAqi!.latitude, _currentAqi!.longitude);
  }

  // ── Internal ──────────────────────────────────────────────────

  void _startAutoRefresh(double lat, double lng) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => fetchAqi(lat, lng),
    );
  }

  String _friendlyError(String raw) {
    if (raw.contains('SocketException') || raw.contains('ClientException')) {
      return 'No internet connection. Check your network and try again.';
    }
    if (raw.contains('Invalid key') || raw.contains('token')) {
      return 'Invalid API key. Please check your WAQI token.';
    }
    if (raw.contains('Unknown station')) {
      return 'No monitoring station found near this location.';
    }
    return 'Failed to load AQI data. Tap to retry.';
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
