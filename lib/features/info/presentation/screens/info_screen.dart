import 'package:flutter/material.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/adaptive_layout.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../core/theme/app_theme.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AdaptiveLayout(
            mobile: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const GlassSliverAppBar(title: 'ALGORITHM INTELLIGENCE'),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildIntroCard(context),
                      const SizedBox(height: 48),
                      ..._buildSection(context, 'CPU SCHEDULING ⚙️', _cpuSteps),
                      const SizedBox(height: 40),
                      ..._buildSection(context, 'MEMORY MANAGEMENT 🧠', _memorySteps),
                      const SizedBox(height: 40),
                      ..._buildSection(context, 'STORAGE ANALYSIS 💿', _storageSteps),
                      const SizedBox(height: 40),
                      ..._buildSection(context, 'PRO TIPS 🪄', _proSteps),
                    ]),
                  ),
                ),
              ],
            ),
            desktop: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(60, 120, 60, 150), 
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroCard(context),
                      const SizedBox(height: 64),
                      _buildDesktopGrid(context, 'CPU SCHEDULING ⚙️', _cpuSteps),
                      const SizedBox(height: 48),
                      _buildDesktopGrid(context, 'MEMORY MANAGEMENT 🧠', _memorySteps),
                      const SizedBox(height: 48),
                      _buildDesktopGrid(context, 'STORAGE ANALYSIS 💿', _storageSteps),
                      const SizedBox(height: 48),
                      _buildDesktopGrid(context, 'PRO TIPS 🪄', _proSteps),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassAppBar(title: 'ALGORITHM INTELLIGENCE'),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Text('Welcome to Envision 🎓', 
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Master the core pillars of Operating System design through high-fidelity visualization. Follow this guide to unlock the secrets of CPU, RAM, and Disk management.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSection(BuildContext context, String title, List<_StepData> steps) {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 20),
        child: Text(title, style: Theme.of(context).textTheme.labelSmall),
      ),
      ...steps.map((step) => _buildStepCard(context, step)),
    ];
  }

  Widget _buildDesktopGrid(BuildContext context, String title, List<_StepData> steps) {
    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width > 1200 ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 28),
          child: Text(title, style: Theme.of(context).textTheme.labelSmall),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            mainAxisExtent: 150, 
          ),
          itemCount: steps.length,
          itemBuilder: (context, index) => _buildStepCard(context, steps[index]),
        ),
      ],
    );
  }

  Widget _buildStepCard(BuildContext context, _StepData step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: step.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: step.color.withValues(alpha: 0.2)),
              ),
              child: Icon(step.icon, color: step.color, size: 26),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(step.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(step.desc, style: Theme.of(context).textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepData {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  _StepData(this.title, this.desc, this.icon, this.color);
}

final List<_StepData> _cpuSteps = [
  _StepData('Task Creation', 'Enter Arrival and Burst time to queue processes for the CPU.', Icons.add_task_rounded, AppTheme.infoColor),
  _StepData('Gantt Timeline', 'Visualize CPU allocation over time. Grey zones indicate IDLE time.', Icons.bar_chart_rounded, AppTheme.successColor),
  _StepData('SRTF Logic', 'Watch how the OS preempts tasks when shorter jobs arrive.', Icons.bolt_rounded, AppTheme.warningColor),
  _StepData('Wait Metrics', 'Monitor Average Wait Time to calculate system efficiency.', Icons.timer_rounded, AppTheme.errorColor),
];

final List<_StepData> _memorySteps = [
  _StepData('RAM Allocation', 'Simulate how processes claim physical blocks in your RAM.', Icons.memory_rounded, AppTheme.primaryColor),
  _StepData('Fragmentation', 'Spot "Holes" in memory where space is too small to be used.', Icons.grid_view_rounded, AppTheme.accentColor),
  _StepData('Virtual Paging', 'Visualize the swap space as pages move between RAM and Disk.', Icons.layers_rounded, AppTheme.infoColor),
  _StepData('LRU Strategy', 'Modern paging based on temporal locality of page access.', Icons.psychology_rounded, AppTheme.successColor),
];

final List<_StepData> _storageSteps = [
  _StepData('Disk Head', 'Visualize the physical movement of the disk arm across cylinders.', Icons.storage_rounded, AppTheme.warningColor),
  _StepData('Elevator SCAN', 'Reduce seek time by serving requests in physical order.', Icons.unfold_more_rounded, AppTheme.infoColor),
  _StepData('File Scatter', 'Analyze fragmentation ratios to see file distribution on disk.', Icons.extension_rounded, AppTheme.errorColor),
  _StepData('C-SCAN Loop', 'Circular scanning for more uniform and predictable wait times.', Icons.loop_rounded, AppTheme.primaryColor),
];

final List<_StepData> _proSteps = [
  _StepData('Magic Wand', 'Tap the Sparkles icon for a perfectly populated OS scenario.', Icons.auto_awesome_rounded, Colors.amberAccent),
  _StepData('System Insights', 'Read the glowing cards for deep-dive hardware theory.', Icons.lightbulb_outline_rounded, AppTheme.successColor),
];
