import 'dart:math';
import 'package:flutter/material.dart';

class ScanField extends StatefulWidget {
  const ScanField({super.key});

  @override
  State<ScanField> createState() => _ScanFieldState();
}

class _ScanFieldState extends State<ScanField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double maxRadius = 130.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildWave(double delay, Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final raw = (_controller.value + delay) % 1.0;
        final t = Curves.easeOutCubic.transform(raw);

        final radius = maxRadius * t;
        final opacity = (1 - t).clamp(0.0, 1.0);

        return CustomPaint(
          size: Size.square(maxRadius * 2),
          painter: _CleanBandPainter(
            radius: radius,
            thickness: 28 * (1 - t * 0.6),
            color: color.withAlpha((opacity * 0.9 * 255).round()),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildWave(0.0, scheme.primary),
                _buildWave(0.33, scheme.primary),
                _buildWave(0.66, scheme.primary),

                // soft radial glow
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        scheme.primary.withAlpha((0.25 * 255).round()),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // core
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final scale = 1 + (sin(_controller.value * 2 * pi) * 0.04);

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primaryContainer,
                        ),
                        child: Icon(
                          Icons.phone_android_rounded,
                          size: 40,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Text(
            "Scanning nearby",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CleanBandPainter extends CustomPainter {
  final double radius;
  final double thickness;
  final Color color;

  _CleanBandPainter({
    required this.radius,
    required this.thickness,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = color
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _CleanBandPainter oldDelegate) => true;
}
