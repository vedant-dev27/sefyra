import 'dart:math';
import 'package:flutter/material.dart';

class WavyProgressIndicator extends StatefulWidget {
  final double progress;

  const WavyProgressIndicator({
    super.key,
    required this.progress,
  });

  @override
  State<WavyProgressIndicator> createState() => _WavyProgressIndicatorState();
}

class _WavyProgressIndicatorState extends State<WavyProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 300,
      height: 300,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final phase = _controller.value * 2 * pi;

          return CustomPaint(
            painter: _WavePainter(
              progress: widget.progress,
              phase: phase,
              color: color,
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final double phase;
  final Color color;

  _WavePainter({
    required this.progress,
    required this.phase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 13.0;
    const amplitude = 7.0;
    const frequency = 10.0;

    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - strokeWidth;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.transparent;

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(center, radius, trackPaint);

    final path = Path();
    final totalAngle = 2 * pi * progress;

    const steps = 200;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final angle = t * totalAngle;

      final wave = sin(angle * frequency + phase) * amplitude;
      final r = radius + wave;

      final x = center.dx + r * cos(angle - pi / 2);
      final y = center.dy + r * sin(angle - pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
