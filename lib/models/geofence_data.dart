/// Geofence state & event log.
enum GeofenceState { inside, outside, unknown }

class GeofenceEvent {
  final GeofenceState state;
  final DateTime timestamp;
  final int aqiAtEvent;

  const GeofenceEvent({
    required this.state,
    required this.timestamp,
    required this.aqiAtEvent,
  });
}

class GeofenceData {
  final GeofenceState currentState;
  final double radiusMeters;
  final List<GeofenceEvent> recentEvents;
  final Duration timeInsideToday;
  final Duration timeOutsideToday;

  const GeofenceData({
    required this.currentState,
    required this.radiusMeters,
    required this.recentEvents,
    required this.timeInsideToday,
    required this.timeOutsideToday,
  });
}
