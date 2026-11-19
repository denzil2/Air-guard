import 'package:flutter/material.dart';

import '../models/route_data.dart';
import '../services/route_service.dart';

/// Manages low-pollution route data.
class RouteProvider extends ChangeNotifier {
  final RouteService _service = RouteService();

  List<RouteData> _routes = [];
  RouteData? _selectedRoute;
  bool _isLoading = false;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────
  List<RouteData> get routes => _routes;
  RouteData? get selectedRoute => _selectedRoute;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RouteData? get cleanestRoute =>
      _routes.isEmpty ? null : _routes.firstWhere((r) => r.isCleanest);
  RouteData? get fastestRoute =>
      _routes.isEmpty ? null : _routes.firstWhere((r) => r.isFastest);

  // ── Actions ───────────────────────────────────────────────────
  Future<void> fetchRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _routes = await _service.fetchRoutes(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );

      // Auto-select cleanest route
      _selectedRoute = cleanestRoute;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectRoute(RouteData route) {
    _selectedRoute = route;
    notifyListeners();
  }

  void clearRoutes() {
    _routes = [];
    _selectedRoute = null;
    notifyListeners();
  }
}
