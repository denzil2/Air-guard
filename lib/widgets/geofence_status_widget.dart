import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/geofence_data.dart';
import '../utils/format_utils.dart';
import 'glass_card.dart';

/// Shows the current geofence status (home / away) with time tracking.
class GeofenceStatusWidget extends StatelessWidget {
  final GeofenceData data;

  const GeofenceStatusWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isUnknown = data.currentState == GeofenceState.unknown;
    final isInside = data.currentState == GeofenceState.inside;
    final statusColor = isUnknown
        ? AppTheme.accent
        : isInside
            ? AppTheme.accentGreen
            : AppTheme.accentOrange;
    final statusIcon = isUnknown
        ? Icons.add_location_alt_outlined
        : isInside
            ? Icons.home_rounded
            : Icons.directions_walk;
    final statusLabel = isUnknown
        ? 'Home Not Configured'
        : isInside
            ? 'At Home'
            : 'Away';
    final statusSubtext = isUnknown
        ? 'Set your home location to enable auto-geofencing'
        : isInside
            ? 'You are inside your home safe zone'
            : 'You have left your home zone';

    return GlassCard(
      borderColor: statusColor.withOpacity(0.3),
      child: Column(
        children: [
          // Status header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(statusIcon, color: statusColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusSubtext,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppTheme.cardBorder, height: 1),
          const SizedBox(height: 16),

          // Time bars
          Row(
            children: [
              _TimeStat(
                icon: Icons.home_outlined,
                label: 'Inside',
                value: FormatUtils.duration(data.timeInsideToday),
                color: AppTheme.accentGreen,
              ),
              const SizedBox(width: 24),
              _TimeStat(
                icon: Icons.explore_outlined,
                label: 'Outside',
                value: FormatUtils.duration(data.timeOutsideToday),
                color: AppTheme.accentOrange,
              ),
            ],
          ),

          // Recent events
          if (data.recentEvents.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppTheme.cardBorder, height: 1),
            const SizedBox(height: 12),
            ...data.recentEvents.take(3).map(
                  (e) => _EventRow(event: e),
                ),
          ],
        ],
      ),
    );
  }
}

class _TimeStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TimeStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.withOpacity(0.7)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final GeofenceEvent event;

  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final isEnter = event.state == GeofenceState.inside;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isEnter ? Icons.login : Icons.logout,
            size: 16,
            color:
                isEnter ? AppTheme.accentGreen : AppTheme.accentOrange,
          ),
          const SizedBox(width: 8),
          Text(
            isEnter ? 'Entered home' : 'Left home',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const Spacer(),
          Text(
            FormatUtils.time(event.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'AQI ${event.aqiAtEvent}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
