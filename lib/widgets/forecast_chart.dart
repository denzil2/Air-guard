import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/aqi_data.dart';
import '../utils/aqi_utils.dart';
import 'glass_card.dart';

/// A 24-hour AQI forecast chart using fl_chart.
class ForecastChart extends StatelessWidget {
  final List<AqiForecast> forecast;

  const ForecastChart({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '24-Hour Forecast',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 300,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, gIdx, rod, rIdx) {
                      final f = forecast[group.x.toInt()];
                      final hour = '${f.time.hour}:00';
                      return BarTooltipItem(
                        '$hour\nAQI ${f.aqi}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx % 4 != 0 || idx >= forecast.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${forecast[idx].time.hour}:00',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: forecast.asMap().entries.map((entry) {
                  final f = entry.value;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: f.aqi.toDouble(),
                        color: AqiUtils.colorForAqi(f.aqi),
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 600),
            ),
          ),
        ],
      ),
    );
  }
}
