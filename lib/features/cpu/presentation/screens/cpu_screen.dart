import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/adaptive_layout.dart';
import '../../../../shared/widgets/insight_card.dart';
import '../../../../shared/widgets/liquid_segmented_control.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../providers/cpu_provider.dart';

class CpuScreen extends ConsumerWidget {
  const CpuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cpuProvider);
    final notifier = ref.read(cpuProvider.notifier);

    final configContent = [
      _buildAlgorithmSelector(state, notifier),
      const SizedBox(height: 28),
      _buildActionCard(context, state, notifier),
      const SizedBox(height: 28),
      if (state.processes.isNotEmpty) _buildProcessList(context, state, notifier),
    ];

    final resultContent = [
      if (state.result != null) _buildEducationalInsights(state),
      const SizedBox(height: 28),
      if (state.result != null) _buildVisualization(context, state),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AdaptiveLayout(
            mobile: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const GlassSliverAppBar(title: 'CPU SCHEDULING'),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
                  sliver: SliverList(delegate: SliverChildListDelegate([...configContent, const SizedBox(height: 28), ...resultContent, const SizedBox(height: 150)])),
                ),
              ],
            ),
            desktop: DesktopContentShell(
              configChildren: configContent,
              resultChildren: resultContent,
              topPadding: 104,
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassAppBar(title: 'CPU SCHEDULING'),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalInsights(CpuState state) {
    String title = "System Insight";
    String msg = "";
    Color color = AppTheme.infoColor;

    switch (state.algorithm) {
      case CpuAlgorithm.fcfs:
        final longBurst = state.processes.any((p) => p.burstTime > 10);
        if (longBurst) {
          title = "Convoy Effect Detected 🚛";
          msg = "A process with a long burst time is holding up the CPU, causing others to wait significantly. This is a classic First-Come-First-Serve weakness where small processes suffer.";
          color = AppTheme.errorColor;
        } else {
          msg = "First-Come-First-Serve is predictable and fair in order of arrival, but doesn't optimize for turnaround time. It's best for non-interactive systems.";
        }
        break;
      case CpuAlgorithm.sjf:
        msg = "Shortest Job First is optimal for minimum average waiting time! However, it can cause 'Starvation' for long tasks if short ones keep arriving.";
        color = AppTheme.successColor;
        break;
      case CpuAlgorithm.srtf:
        msg = "Shortest Remaining Time First is the preemptive version of SJF. It's even more efficient but requires frequent 'Context Switching' overhead.";
        color = AppTheme.successColor;
        break;
      case CpuAlgorithm.roundRobin:
        if (state.timeQuantum < 2) {
          title = "High Overhead Detected 🔄";
          msg = "A very small time quantum increases 'Context Switching' overhead, reducing the percentage of time actually spent doing real work.";
          color = AppTheme.warningColor;
        } else {
          msg = "Round Robin provides great responsiveness for interactive systems by giving everyone a fair slice of time. It prevents any single process from hogging the CPU.";
        }
        break;
      case CpuAlgorithm.priority:
        msg = "Priority scheduling ensures critical tasks run first. Careful: low-priority tasks might never run (Starvation) without 'Aging' logic.";
        color = AppTheme.warningColor;
        break;
    }

    return InsightCard(title: title, message: msg, color: color);
  }

  Widget _buildAlgorithmSelector(CpuState state, CpuNotifier notifier) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 40,
      opacity: 0.05,
      child: LiquidSegmentedControl<CpuAlgorithm>(
        values: CpuAlgorithm.values,
        labels: const ['FCFS', 'SJF', 'SRTF', 'ROUND ROBIN', 'PRIORITY'],
        selectedValue: state.algorithm,
        onSelected: notifier.setAlgorithm,
        fontSize: 9,
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, CpuState state, CpuNotifier notifier) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Configure Tasks ⚙️', style: Theme.of(context).textTheme.headlineLarge),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      notifier.clearAll();
                      notifier.addProcess(arrivalTime: 0, burstTime: 8, priority: 2);
                      notifier.addProcess(arrivalTime: 2, burstTime: 4, priority: 1);
                      notifier.addProcess(arrivalTime: 4, burstTime: 2, priority: 3);
                    },
                    icon: const Icon(Icons.auto_awesome_rounded, color: Colors.amberAccent),
                    tooltip: 'Educational Scenario',
                  ),
                  IconButton(
                    onPressed: notifier.clearAll,
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white38),
                    tooltip: 'Clear All',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _AnimatedProcessInput(
            showPriority: state.algorithm == CpuAlgorithm.priority,
            onAdd: (a, b, p) => notifier.addProcess(arrivalTime: a, burstTime: b, priority: p),
          ),
          if (state.algorithm == CpuAlgorithm.roundRobin) ...[
            const SizedBox(height: 24),
            _buildTimeQuantumInput(context, state, notifier),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeQuantumInput(BuildContext context, CpuState state, CpuNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          const Icon(Icons.speed_rounded, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 12),
          Text('Time Quantum', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
          const Spacer(),
          SizedBox(
            width: 60,
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (v) => int.tryParse(v) != null ? notifier.setTimeQuantum(int.parse(v)) : null,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              decoration: const InputDecoration(border: InputBorder.none, hintText: '2'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessList(BuildContext context, CpuState state, CpuNotifier notifier) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            child: Text('Process Queue 📥', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
          ),
          ...state.processes.map((p) => _buildProcessItem(context, p, notifier, state.algorithm == CpuAlgorithm.priority)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildProcessItem(BuildContext context, dynamic p, CpuNotifier notifier, bool showPriority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05)))),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: p.color.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Center(child: Text(p.name, style: TextStyle(color: p.color, fontWeight: FontWeight.w900, fontSize: 14))),
          ),
          const SizedBox(width: 24),
          _buildMetricCol(context, 'Arrival', p.arrivalTime.toString()),
          const SizedBox(width: 32),
          _buildMetricCol(context, 'Burst', p.burstTime.toString()),
          if (showPriority) ...[
            const SizedBox(width: 32),
            _buildMetricCol(context, 'Pri', p.priority.toString()),
          ],
          const Spacer(),
          IconButton(onPressed: () => notifier.removeProcess(p.id), icon: const Icon(Icons.close_rounded, color: Colors.white24, size: 24)),
        ],
      ),
    );
  }

  Widget _buildMetricCol(BuildContext context, String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
        Text(val, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
      ],
    );
  }

  Widget _buildVisualization(BuildContext context, CpuState state) {
    final result = state.result!;
    return GlassCard(
      color: AppTheme.primaryColor,
      opacity: 0.03,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gantt Timeline 📈', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: Text('Avg Wait: ${result.averageWaitTime.toStringAsFixed(2)}', 
                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: result.executionSteps.map((step) => _buildGanttBlock(step)).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildGanttBlock(dynamic step) {
    final width = max<double>(50.0, (step.end - step.start) * 50.0);
    final isIdle = step.processName.isEmpty;
    return Column(
      children: [
        Container(
          width: width, height: 64, margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: step.color.withValues(alpha: isIdle ? 0.05 : 0.9),
            borderRadius: BorderRadius.circular(18),
            boxShadow: isIdle ? [] : [BoxShadow(color: step.color.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: -2)],
            gradient: isIdle ? null : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [step.color, step.color.withValues(alpha: 0.7)]),
          ),
          child: Center(child: Text(step.processName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(step.start.toString(), style: const TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(step.end.toString(), style: const TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedProcessInput extends StatefulWidget {
  final bool showPriority;
  final Function(int a, int b, int p) onAdd;
  const _AnimatedProcessInput({required this.onAdd, this.showPriority = false});
  @override
  State<_AnimatedProcessInput> createState() => _AnimatedProcessInputState();
}

class _AnimatedProcessInputState extends State<_AnimatedProcessInput> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _p = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildField(_a, 'Arrival'),
        const SizedBox(width: 16),
        _buildField(_b, 'Burst'),
        if (widget.showPriority) ...[
          const SizedBox(width: 16),
          _buildField(_p, 'Pri'),
        ],
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            final a = int.tryParse(_a.text);
            final b = int.tryParse(_b.text);
            final p = int.tryParse(_p.text) ?? 0;
            if (a != null && b != null) {
              widget.onAdd(a, b, p);
              _a.clear(); _b.clear(); _p.clear();
            }
          },
          child: Container(
            height: 60, width: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.accentColor]), 
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
          ),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController c, String label) {
    return Expanded(
      child: Container(
        height: 60, padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
        child: TextField(
          controller: c, keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          decoration: InputDecoration(border: InputBorder.none, labelText: label, labelStyle: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        ),
      ),
    );
  }
}
