import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LiquidBackground extends StatefulWidget {
  final Widget child;
  const LiquidBackground({super.key, required this.child});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final List<Color> _colors = [
    AppTheme.primaryColor,
    AppTheme.accentColor,
    AppTheme.infoColor,
    AppTheme.successColor,
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (i) => AnimationController(
      vsync: this,
      duration: Duration(seconds: 10 + i * 2),
    )..repeat(reverse: true));
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppTheme.surfaceColor),
        ...List.generate(4, (i) => AnimatedBuilder(
          animation: _controllers[i],
          builder: (context, _) {
            final phase = _controllers[i].value * 2 * pi;
            return Positioned(
              top: (MediaQuery.of(context).size.height / 2) * (1 + 0.5 * sin(phase)) - 200,
              left: (MediaQuery.of(context).size.width / 2) * (1 + 0.5 * cos(phase + i)) - 200,
              child: _GlowOrb(
                color: _colors[i],
                size: 400 + i * 50,
              ),
            );
          },
        )),
        widget.child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
