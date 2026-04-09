import 'dart:math';
import 'package:flutter/material.dart';

class RippleWidget extends StatefulWidget {
  const RippleWidget({super.key});

  @override
  State<RippleWidget> createState() => _RippleWidgetState();
}

class _RippleWidgetState extends State<RippleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double emissionThickness = 30.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildWave({
    required double delay,
    required Color color,
    required double maxRadius,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final raw = (_controller.value + delay) % 1.0;

        if (raw < 0.02) return const SizedBox();

        final t = Curves.easeOutCubic.transform(raw);

        final radius = maxRadius * t;

        final thickness = emissionThickness * (1 - t * 0.8);

        final opacity = (1 - t * 0.85).clamp(0.0, 1.0);

        final phase = _controller.value * 2 * pi;

        return CustomPaint(
          size: Size.square(maxRadius * 2),
          painter: _BandPainter(
            radius: radius,
            thickness: thickness,
            color: color.withAlpha((opacity * 255).round()),
            phase: phase,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    const maxRadius = 130.0;

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildWave(delay: 0.0, color: color, maxRadius: maxRadius),
          _buildWave(delay: 0.33, color: color, maxRadius: maxRadius),
          _buildWave(delay: 0.66, color: color, maxRadius: maxRadius),
        ],
      ),
    );
  }
}

class _BandPainter extends CustomPainter {
  final double radius;
  final double thickness;
  final Color color;
  final double phase;

  _BandPainter({
    required this.radius,
    required this.thickness,
    required this.color,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const steps = 160;

    // subtle expressive distortion
    const amplitude = 2.0;
    const frequency = 6.0;

    final center = size.center(Offset.zero);

    final outerPath = Path();
    final innerPath = Path();

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final angle = t * 2 * pi;

      final wave = sin(angle * frequency + phase) * amplitude;

      final outerR = radius + thickness / 2 + wave;
      final innerR = radius - thickness / 2 + wave;

      final ox = center.dx + outerR * cos(angle);
      final oy = center.dy + outerR * sin(angle);

      final ix = center.dx + innerR * cos(angle);
      final iy = center.dy + innerR * sin(angle);

      if (i == 0) {
        outerPath.moveTo(ox, oy);
        innerPath.moveTo(ix, iy);
      } else {
        outerPath.lineTo(ox, oy);
        innerPath.lineTo(ix, iy);
      }
    }

    final path = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BandPainter oldDelegate) => true;
}
