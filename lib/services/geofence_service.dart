import 'dart:math';
import '../models/geofence_data.dart';

/// Calculates whether the user is inside or outside the geofence.
/// In production, replace with background-location / geofencing plugin.
class GeofenceService {
  /// Returns the distance in metres between two lat/lng points (Haversine).
  double distanceMetres(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371000.0; // metres
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// Check if [userLat, userLng] is inside [homeLat, homeLng] + [radiusM].
  GeofenceState checkState({
    required double userLat,
    required double userLng,
    required double homeLat,
    required double homeLng,
    required double radiusM,
  }) {
    final dist = distanceMetres(userLat, userLng, homeLat, homeLng);
    return dist <= radiusM ? GeofenceState.inside : GeofenceState.outside;
  }

  double _deg2rad(double deg) => deg * (pi / 180);
}
