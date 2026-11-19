/// Saved home-location for geofence.
class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final DateTime savedAt;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.savedAt,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'saved_at': savedAt.toIso8601String(),
      };
}

/// Live position wrapper.
class UserPosition {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  const UserPosition({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });
}
