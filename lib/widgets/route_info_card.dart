import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/route_data.dart';
import '../utils/aqi_utils.dart';
import 'glass_card.dart';

/// Card displaying a route option with pollution info.
class RouteInfoCard extends StatelessWidget {
  final RouteData route;
  final bool isSelected;
  final VoidCallback onTap;

  const RouteInfoCard({
    super.key,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderColor: isSelected
          ? route.routeColor.withOpacity(0.6)
          : AppTheme.cardBorder,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Route badge
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: route.routeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  route.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (route.isCleanest)
                _Badge(label: '🌿 Cleanest', color: AppTheme.accentGreen),
              if (route.isFastest)
                _Badge(label: '⚡ Fastest', color: AppTheme.accent),
            ],
          ),

          const SizedBox(height: 14),

          // Stats row
          Row(
            children: [
              _Stat(
                icon: Icons.air,
                label: 'Avg AQI',
                value: '${route.avgAqi}',
                color: AqiUtils.colorForAqi(route.avgAqi),
              ),
              _Stat(
                icon: Icons.warning_amber_rounded,
                label: 'Max AQI',
                value: '${route.maxAqi}',
                color: AqiUtils.colorForAqi(route.maxAqi),
              ),
              _Stat(
                icon: Icons.straighten,
                label: 'Distance',
                value: '${route.distanceKm} km',
                color: Colors.white70,
              ),
              _Stat(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value: '${route.durationMinutes} min',
                color: Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color.withOpacity(0.7)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
