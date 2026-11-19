import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location_data.dart';
import '../services/location_service.dart';

/// Manages user's live GPS position and saved home location.
/// Uses the geolocator package for real-time tracking.
class LocationProvider extends ChangeNotifier {
  final LocationService _service = LocationService();

  LocationData? _homeLocation;
  UserPosition? _currentPosition;
  bool _isLoading = false;
  bool _isTracking = false;
  String? _error;
  StreamSubscription<Position>? _positionStream;

  // ── Getters ───────────────────────────────────────────────────
  LocationData? get homeLocation => _homeLocation;
  UserPosition? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  bool get isTracking => _isTracking;
  bool get hasHome => _homeLocation != null;
  String? get error => _error;

  // ════════════════════════════════════════════════════════════════
  // GPS Permission & Service Check
  // ════════════════════════════════════════════════════════════════

  /// Check and request location permissions.
  /// Returns true if permission is granted and location service is enabled.
  Future<bool> checkAndRequestPermission() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error = 'Location services are disabled. Please enable GPS.';
      notifyListeners();
      return false;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error = 'Location permission denied. Please allow location access.';
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _error =
          'Location permission permanently denied. Please enable in Settings.';
      notifyListeners();
      return false;
    }

    _error = null;
    notifyListeners();
    return true;
  }

  // ════════════════════════════════════════════════════════════════
  // Get Current Position (one-shot)
  // ════════════════════════════════════════════════════════════════

  /// Get the user's current GPS position (single read).
  Future<UserPosition?> getCurrentPosition() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      _isLoading = false;
      notifyListeners();
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentPosition = UserPosition(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );

      _isLoading = false;
      _error = null;
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      _error = 'Failed to get location: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // Live GPS Tracking Stream
  // ════════════════════════════════════════════════════════════════

  /// Start continuous GPS tracking.
  /// Updates [currentPosition] every time the device moves.
  Future<void> startTracking({
    int distanceFilterMeters = 10,
    int intervalMs = 5000,
  }) async {
    if (_isTracking) return;

    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return;

    _isTracking = true;
    notifyListeners();

    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilterMeters,
      intervalDuration: Duration(milliseconds: intervalMs),
      // Keep tracking in background (needs foreground service on Android)
      forceLocationManager: false,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentPosition = UserPosition(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          timestamp: position.timestamp,
        );
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'GPS tracking error: $error';
        notifyListeners();
      },
    );
  }

  /// Stop continuous GPS tracking.
  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════
  // Home Location Management
  // ════════════════════════════════════════════════════════════════

  /// Load saved home from disk.
  Future<void> loadHome() async {
    _isLoading = true;
    notifyListeners();

    try {
      _homeLocation = await _service.loadHomeLocation();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Save a new home location.
  Future<void> setHomeLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final loc = LocationData(
      latitude: latitude,
      longitude: longitude,
      address: address,
      savedAt: DateTime.now(),
    );

    await _service.saveHomeLocation(loc);
    _homeLocation = loc;
    notifyListeners();
  }

  /// Set current GPS position as home.
  Future<bool> setCurrentPositionAsHome({String? label}) async {
    final pos = await getCurrentPosition();
    if (pos == null) return false;

    await setHomeLocation(
      latitude: pos.latitude,
      longitude: pos.longitude,
      address: label ?? 'My Home (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})',
    );
    return true;
  }

  /// Update the user's live position (can also be called manually).
  void updatePosition(UserPosition position) {
    _currentPosition = position;
    notifyListeners();
  }

  /// Clear saved home.
  Future<void> clearHome() async {
    await _service.clearHomeLocation();
    _homeLocation = null;
    notifyListeners();
  }

  /// Open device location settings (useful when permission denied).
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings (useful when permission permanently denied).
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // ── Cleanup ───────────────────────────────────────────────────
  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
