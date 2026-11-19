import 'package:flutter/material.dart';

import '../models/geofence_data.dart';
import '../models/location_data.dart';
import '../services/geofence_service.dart';
import '../config/constants.dart';

/// Tracks whether the user is inside or outside the home geofence.
/// Call [evaluate] every time the GPS position updates.
class GeofenceProvider extends ChangeNotifier {
  final GeofenceService _service = GeofenceService();

  GeofenceState _state = GeofenceState.unknown;
  final List<GeofenceEvent> _events = [];
  Duration _timeInsideToday = Duration.zero;
  Duration _timeOutsideToday = Duration.zero;
  DateTime? _lastCheck;
  double _distanceFromHome = 0;

  // ── Getters ───────────────────────────────────────────────────
  GeofenceState get state => _state;
  bool get isInsideHome => _state == GeofenceState.inside;
  bool get isOutsideHome => _state == GeofenceState.outside;
  List<GeofenceEvent> get events => List.unmodifiable(_events);
  Duration get timeInsideToday => _timeInsideToday;
  Duration get timeOutsideToday => _timeOutsideToday;
  double get distanceFromHome => _distanceFromHome;

  /// Formatted distance string.
  String get distanceLabel {
    if (_distanceFromHome < 1000) {
      return '${_distanceFromHome.round()} m from home';
    }
    return '${(_distanceFromHome / 1000).toStringAsFixed(1)} km from home';
  }

  GeofenceData get data => GeofenceData(
        currentState: _state,
        radiusMeters: AqiConstants.geofenceRadiusMeters,
        recentEvents: _events,
        timeInsideToday: _timeInsideToday,
        timeOutsideToday: _timeOutsideToday,
      );

  // ── Actions ───────────────────────────────────────────────────

  /// Call this every time the user's GPS position updates.
  /// Automatically detects enter/leave transitions.
  void evaluate({
    required UserPosition position,
    required LocationData home,
    int currentAqi = 0,
  }) {
    // Calculate actual distance
    _distanceFromHome = _service.distanceMetres(
      position.latitude,
      position.longitude,
      home.latitude,
      home.longitude,
    );

    final newState = _service.checkState(
      userLat: position.latitude,
      userLng: position.longitude,
      homeLat: home.latitude,
      homeLng: home.longitude,
      radiusM: AqiConstants.geofenceRadiusMeters,
    );

    // Track time
    final now = DateTime.now();
    if (_lastCheck != null) {
      final delta = now.difference(_lastCheck!);
      if (_state == GeofenceState.inside) {
        _timeInsideToday += delta;
      } else if (_state == GeofenceState.outside) {
        _timeOutsideToday += delta;
      }
    }
    _lastCheck = now;

    // Log transition events (enter / leave)
    if (newState != _state && _state != GeofenceState.unknown) {
      _events.insert(
        0,
        GeofenceEvent(
          state: newState,
          timestamp: now,
          aqiAtEvent: currentAqi,
        ),
      );
      // Keep last 50 events
      if (_events.length > 50) _events.removeLast();
    }

    _state = newState;
    notifyListeners();
  }

  /// Reset daily counters (call at midnight or on-demand).
  void resetDailyCounters() {
    _timeInsideToday = Duration.zero;
    _timeOutsideToday = Duration.zero;
    notifyListeners();
  }
}
