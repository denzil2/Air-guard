import 'dart:math';
import 'package:flutter/material.dart';
import '../models/route_data.dart';

/// Generates mock route options with pollution metadata.
/// Replace with Directions API + AQI overlay in production.
class RouteService {
  static final _random = Random();

  Future<List<RouteData>> fetchRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Generate 3 mock routes
    return [
      _generateRoute(
        id: 'fast',
        name: 'Fastest Route',
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
        baseAqi: 80 + _random.nextInt(60),
        distKm: 4.2 + _random.nextDouble() * 2,
        durMin: 12 + _random.nextInt(5),
        color: Colors.redAccent,
        isFastest: true,
      ),
      _generateRoute(
        id: 'clean',
        name: 'Cleanest Air Route',
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
        baseAqi: 25 + _random.nextInt(30),
        distKm: 5.5 + _random.nextDouble() * 3,
        durMin: 18 + _random.nextInt(8),
        color: Colors.greenAccent,
        isCleanest: true,
      ),
      _generateRoute(
        id: 'balanced',
        name: 'Balanced Route',
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
        baseAqi: 50 + _random.nextInt(40),
        distKm: 4.8 + _random.nextDouble() * 2,
        durMin: 15 + _random.nextInt(5),
        color: Colors.orangeAccent,
      ),
    ];
  }

  RouteData _generateRoute({
    required String id,
    required String name,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required int baseAqi,
    required double distKm,
    required int durMin,
    required Color color,
    bool isFastest = false,
    bool isCleanest = false,
  }) {
    // Interpolate 10 points between origin and dest with jitter
    final points = List.generate(10, (i) {
      final t = i / 9;
      final jitterLat = (_random.nextDouble() - 0.5) * 0.005;
      final jitterLng = (_random.nextDouble() - 0.5) * 0.005;
      return RoutePoint(
        latitude: originLat + (destLat - originLat) * t + jitterLat,
        longitude: originLng + (destLng - originLng) * t + jitterLng,
        aqi: (baseAqi + _random.nextInt(30) - 15).clamp(0, 500),
      );
    });

    final aqis = points.map((p) => p.aqi);
    return RouteData(
      id: id,
      name: name,
      points: points,
      distanceKm: double.parse(distKm.toStringAsFixed(1)),
      durationMinutes: durMin,
      avgAqi: (aqis.reduce((a, b) => a + b) / aqis.length).round(),
      maxAqi: aqis.reduce(max),
      routeColor: color,
      isFastest: isFastest,
      isCleanest: isCleanest,
    );
  }
}
