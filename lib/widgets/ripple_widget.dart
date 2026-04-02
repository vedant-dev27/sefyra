import 'package:flutter/material.dart';

class RippleWidget extends StatefulWidget {
  const RippleWidget({super.key});

  @override
  State<RippleWidget> createState() => _RippleWidgetState();
}

class _RippleWidgetState extends State<RippleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCircle(double delay, Color color, double maxSize) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final value = (_controller.value + delay) % 1.0;

        if (value < 0.01) return const SizedBox();

        final curved = Curves.easeOut.transform(value);

        final size = maxSize * curved;
        final opacity = (1 - curved).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.6),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    const double maxSize = 260;

    return Stack(
      alignment: Alignment.center,
      children: [
        _buildCircle(0.0, colors.primary, maxSize),
        _buildCircle(0.33, colors.primary, maxSize),
        _buildCircle(0.66, colors.primary, maxSize),
      ],
    );
  }
}
