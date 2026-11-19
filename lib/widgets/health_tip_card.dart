import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../utils/aqi_utils.dart';
import 'glass_card.dart';

/// Shows a contextual health tip based on the current AQI level.
class HealthTipCard extends StatelessWidget {
  final int aqi;

  const HealthTipCard({super.key, required this.aqi});

  @override
  Widget build(BuildContext context) {
    final color = AqiUtils.colorForAqi(aqi);
    final advice = AqiUtils.adviceForAqi(aqi);
    final tips = _tipsForAqi(aqi);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: color, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Health Advisory',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advice,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      tip.icon,
                      size: 16,
                      color: AppTheme.accent.withOpacity(0.7),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip.text,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<_Tip> _tipsForAqi(int aqi) {
    if (aqi <= 50) {
      return [
        _Tip(Icons.directions_run, 'Great day for outdoor exercise'),
        _Tip(Icons.window, 'Open windows to ventilate your home'),
      ];
    } else if (aqi <= 100) {
      return [
        _Tip(Icons.elderly, 'Sensitive groups should take precautions'),
        _Tip(Icons.schedule, 'Exercise in the morning when AQI is lower'),
      ];
    } else if (aqi <= 200) {
      return [
        _Tip(Icons.masks, 'Wear an N95 mask outdoors'),
        _Tip(Icons.window, 'Keep windows closed'),
        _Tip(Icons.air, 'Use an air purifier indoors'),
      ];
    } else {
      return [
        _Tip(Icons.home, 'Stay indoors as much as possible'),
        _Tip(Icons.masks, 'Wear an N95 mask if you must go out'),
        _Tip(Icons.air, 'Run air purifiers on max'),
        _Tip(Icons.local_hospital, 'Seek medical help if breathing difficulties occur'),
      ];
    }
  }
}

class _Tip {
  final IconData icon;
  final String text;
  const _Tip(this.icon, this.text);
}
