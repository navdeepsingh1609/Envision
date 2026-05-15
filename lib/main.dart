import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/cpu/presentation/screens/cpu_screen.dart';
import 'features/memory/presentation/screens/memory_screen.dart';
import 'features/storage/presentation/screens/storage_screen.dart';
import 'features/info/presentation/screens/info_screen.dart';
import 'shared/widgets/liquid_background.dart';
import 'shared/widgets/glass_card.dart';

void main() {
  runApp(const ProviderScope(child: EnvisionApp()));
}

final _router = GoRouter(
  initialLocation: '/cpu',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/info', builder: (context, state) => const InfoScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/cpu', builder: (context, state) => const CpuScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/memory', builder: (context, state) => const MemoryScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/storage', builder: (context, state) => const StorageScreen())],
        ),
      ],
    ),
  ],
);

class EnvisionApp extends StatelessWidget {
  const EnvisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Envision',
      theme: AppTheme.theme,
      routerConfig: _router,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      body: LiquidBackground(child: navigationShell),
      bottomNavigationBar: _LiquidNavBar(navigationShell: navigationShell),
    );
  }
}

class _LiquidNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _LiquidNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding > 0 ? bottomPadding : 24),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        borderRadius: 40,
        animate: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bubbleWidth = constraints.maxWidth / 4;
            return Stack(
              alignment: Alignment.center,
              children: [
                _AnimatedBubble(
                  index: navigationShell.currentIndex,
                  width: bubbleWidth,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.info_outline_rounded,
                      isActive: navigationShell.currentIndex == 0,
                      onTap: () => navigationShell.goBranch(0),
                    ),
                    _NavItem(
                      icon: Icons.memory_rounded,
                      isActive: navigationShell.currentIndex == 1,
                      onTap: () => navigationShell.goBranch(1),
                    ),
                    _NavItem(
                      icon: Icons.layers_outlined,
                      isActive: navigationShell.currentIndex == 2,
                      onTap: () => navigationShell.goBranch(2),
                    ),
                    _NavItem(
                      icon: Icons.storage_rounded,
                      isActive: navigationShell.currentIndex == 3,
                      onTap: () => navigationShell.goBranch(3),
                    ),
                  ],
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}

class _AnimatedBubble extends StatelessWidget {
  final int index;
  final double width;
  const _AnimatedBubble({required this.index, required this.width});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      left: index * width,
      child: Container(
        width: width,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.3),
              AppTheme.accentColor.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: -2,
            )
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: isActive ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.white24,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
