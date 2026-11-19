import 'package:flutter/material.dart';

/// A route option with pollution metadata.
class RouteData {
  final String id;
  final String name;
  final List<RoutePoint> points;
  final double distanceKm;
  final int durationMinutes;
  final int avgAqi;
  final int maxAqi;
  final Color routeColor;
  final bool isCleanest;
  final bool isFastest;

  const RouteData({
    required this.id,
    required this.name,
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
    required this.avgAqi,
    required this.maxAqi,
    required this.routeColor,
    this.isCleanest = false,
    this.isFastest = false,
  });
}

/// A point along a route with its local AQI.
class RoutePoint {
  final double latitude;
  final double longitude;
  final int aqi;

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.aqi,
  });
}
