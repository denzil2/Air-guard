import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/aqi_utils.dart';

/// A beautiful circular arc gauge that displays the current AQI.
class AqiGauge extends StatefulWidget {
  final int aqi;
  final double size;

  const AqiGauge({super.key, required this.aqi, this.size = 220});

  @override
  State<AqiGauge> createState() => _AqiGaugeState();
}

class _AqiGaugeState extends State<AqiGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(
      begin: 0,
      end: AqiUtils.progressForAqi(widget.aqi),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AqiGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aqi != widget.aqi) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: AqiUtils.progressForAqi(widget.aqi),
      ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AqiUtils.colorForAqi(widget.aqi);
    final emoji = AqiUtils.emojiForAqi(widget.aqi);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background & Progress arc
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GaugeArcPainter(
                  progress: _animation.value,
                  color: color,
                  bgColor: Colors.white.withOpacity(0.08),
                ),
              ),
              // Center content (Emoji + Big Number + AQI)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 34)),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.aqi}',
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: color,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AQI',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugeArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _GaugeArcPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const startAngle = 2.3; // ~132°
    const sweepAngle = 4.6; // ~264°
    const strokeWidth = 14.0;

    // Background arc
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: AqiUtils.gaugeGradient,
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );

    // Glow dot at the end of the arc
    if (progress > 0.01) {
      final angle = startAngle + sweepAngle * progress;
      final dotX = center.dx + radius * cos(angle);
      final dotY = center.dy + radius * sin(angle);

      final glowPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(dotX, dotY), 10, glowPaint);

      final dotPaint = Paint()..color = color;
      canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_GaugeArcPainter old) =>
      old.progress != progress || old.color != color;
}
