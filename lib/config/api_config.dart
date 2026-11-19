/// App-wide API configuration.
/// Keep API keys here so they're easy to find and rotate.
class ApiConfig {
  ApiConfig._();

  // ── WAQI (World Air Quality Index) ────────────────────────────
  static const String waqiApiKey = 'e18c0f8b44619749a5f428fd5814e1c75843c87b';
  static const String waqiBaseUrl = 'https://api.waqi.info';

  /// Current AQI by coordinates.
  static String waqiGeoUrl(double lat, double lng) =>
      '$waqiBaseUrl/feed/geo:$lat;$lng/?token=$waqiApiKey';

  /// Current AQI by city name.
  static String waqiCityUrl(String city) =>
      '$waqiBaseUrl/feed/$city/?token=$waqiApiKey';

  /// Search stations.
  static String waqiSearchUrl(String keyword) =>
      '$waqiBaseUrl/search/?keyword=$keyword&token=$waqiApiKey';
}
