import 'package:flutter/material.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? desktop;

  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900 && desktop != null) {
          return desktop!;
        }
        return mobile;
      },
    );
  }
}

class DesktopContentShell extends StatelessWidget {
  final List<Widget>? configChildren;
  final List<Widget>? resultChildren;
  final List<Widget> children;
  final double topPadding;

  const DesktopContentShell({
    super.key,
    this.configChildren,
    this.resultChildren,
    this.children = const [],
    this.topPadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    final leftItems = configChildren ?? children.take(2).toList();
    final rightItems = resultChildren ?? children.skip(2).toList();
    final bottomNavHeight = MediaQuery.of(context).padding.bottom + 120;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1600),
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: topPadding, bottom: bottomNavHeight),
                children: [
                  ...leftItems,
                  const SizedBox(height: 40),
                  _buildQuickGuide(),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              flex: 3,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: topPadding, bottom: bottomNavHeight),
                children: rightItems,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickGuide() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SYSTEM INTELLIGENCE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1.5)),
          SizedBox(height: 20),
          _GuideItem(icon: Icons.auto_fix_high_rounded, text: 'Use the Magic Wand to instantly see deep-theory educational scenarios.'),
          SizedBox(height: 16),
          _GuideItem(icon: Icons.layers_rounded, text: 'Dual-pane analysis allows you to track memory state and scheduling side-by-side.'),
          SizedBox(height: 16),
          _GuideItem(icon: Icons.bolt_rounded, text: 'Real-time computation re-runs on every change to keep visualization live.'),
        ],
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _GuideItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.white24),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.white60, height: 1.5))),
      ],
    );
  }
}
