import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/aqi_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/pollutant_tile.dart';
import '../widgets/forecast_chart.dart';
import '../utils/aqi_utils.dart';
import '../utils/format_utils.dart';

/// Detailed AQI view with pollutant breakdown and history.
class AqiDetailScreen extends StatelessWidget {
  const AqiDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AQI Details')),
      body: Consumer<AqiProvider>(
        builder: (context, provider, _) {
          final aqi = provider.currentAqi;
          if (aqi == null) {
            return const Center(
              child: Text(
                'No AQI data available',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          final color = AqiUtils.colorForAqi(aqi.aqi);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Big AQI card ───────────────────────────────────
              GlassCard(
                borderColor: color.withOpacity(0.3),
                child: Column(
                  children: [
                    Text(
                      aqi.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${aqi.aqi}',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: color,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        aqi.category,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dominant pollutant: ${aqi.dominantPollutant.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FormatUtils.dateTime(aqi.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Pollutant Breakdown ────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pollutant Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...aqi.pollutants.entries.map(
                      (e) => PollutantTile(
                        pollutantKey: e.key,
                        value: e.value,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Forecast ──────────────────────────────────────
              ForecastChart(forecast: provider.forecast),

              const SizedBox(height: 20),

              // ── AQI Scale Reference ───────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AQI Scale',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _scaleRow('0-50', 'Good', AppTheme.aqiGood),
                    _scaleRow('51-100', 'Moderate', AppTheme.aqiModerate),
                    _scaleRow('101-150', 'Unhealthy (Sensitive)',
                        AppTheme.aqiUnhealthySensitive),
                    _scaleRow(
                        '151-200', 'Unhealthy', AppTheme.aqiUnhealthy),
                    _scaleRow('201-300', 'Very Unhealthy',
                        AppTheme.aqiVeryUnhealthy),
                    _scaleRow(
                        '301-500', 'Hazardous', AppTheme.aqiHazardous),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _scaleRow(String range, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              range,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
