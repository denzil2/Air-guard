import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/route_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/route_info_card.dart';

/// Screen showing low-pollution route options with a map placeholder.
class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final _destLatController = TextEditingController(text: '28.5355');
  final _destLngController = TextEditingController(text: '77.3910');

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  @override
  void dispose() {
    _destLatController.dispose();
    _destLngController.dispose();
    super.dispose();
  }

  void _fetchRoutes() {
    final home = context.read<LocationProvider>().homeLocation;
    final originLat = home?.latitude ?? 28.6139;
    final originLng = home?.longitude ?? 77.2090;

    final destLat = double.tryParse(_destLatController.text) ?? 28.5355;
    final destLng = double.tryParse(_destLngController.text) ?? 77.3910;

    context.read<RouteProvider>().fetchRoutes(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low-Pollution Routes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRoutes,
          ),
        ],
      ),
      body: Consumer<RouteProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // ── Map Placeholder ──────────────────────────────
              Expanded(
                flex: 4,
                child: _MapPlaceholder(
                  routes: provider.routes,
                  selectedRoute: provider.selectedRoute,
                ),
              ),

              // ── Bottom Sheet with Routes ─────────────────────
              Expanded(
                flex: 5,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Destination input
                      Row(
                        children: [
                          const Icon(Icons.flag, color: AppTheme.accent, size: 20),
                          const SizedBox(width: 10),
                          const Text(
                            'Destination',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _fetchRoutes,
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniInput(
                              controller: _destLatController,
                              label: 'Lat',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MiniInput(
                              controller: _destLngController,
                              label: 'Lng',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Route options header
                      Row(
                        children: [
                          const Icon(Icons.alt_route,
                              color: AppTheme.accent, size: 20),
                          const SizedBox(width: 10),
                          const Text(
                            'Route Options',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          if (provider.routes.isNotEmpty)
                            Text(
                              '${provider.routes.length} routes found',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (provider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                              color: AppTheme.accent,
                            ),
                          ),
                        )
                      else if (provider.routes.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Text(
                              'No routes available',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ),
                        )
                      else
                        ...provider.routes.map(
                          (route) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RouteInfoCard(
                              route: route,
                              isSelected:
                                  provider.selectedRoute?.id == route.id,
                              onTap: () => provider.selectRoute(route),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Legend
                      GlassCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Route Color = AQI Level',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _LegendDot(
                                    color: AppTheme.aqiGood, label: 'Good'),
                                _LegendDot(
                                    color: AppTheme.aqiModerate,
                                    label: 'Moderate'),
                                _LegendDot(
                                    color: AppTheme.aqiUnhealthy,
                                    label: 'Unhealthy'),
                                _LegendDot(
                                    color: AppTheme.aqiHazardous,
                                    label: 'Hazardous'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Map Placeholder ─────────────────────────────────────────────
class _MapPlaceholder extends StatelessWidget {
  final List routes;
  final dynamic selectedRoute;

  const _MapPlaceholder({required this.routes, this.selectedRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceLight,
      child: Stack(
        children: [
          // Grid pattern to simulate a map
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(),
          ),

          // Route lines (simulated)
          if (routes.isNotEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.map,
                    size: 48,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Google Maps View',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add API key to enable interactive map',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  if (selectedRoute != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '📍 ${selectedRoute.name} selected',
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Origin & destination markers
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Destination',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

class _MiniInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _MiniInput({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.4), fontSize: 12),
        filled: true,
        fillColor: AppTheme.surfaceLight.withOpacity(0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.accent),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 10, color: Colors.white.withOpacity(0.5)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
