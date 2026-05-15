import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/adaptive_layout.dart';
import '../../../../shared/widgets/insight_card.dart';
import '../../../../shared/widgets/liquid_segmented_control.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../domain/models/storage_model.dart';
import '../providers/storage_provider.dart';

class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storageProvider);
    final notifier = ref.read(storageProvider.notifier);

    final configContent = [
      _buildModeSelector(state, notifier),
      const SizedBox(height: 28),
      _buildAlgorithmSelector(state, notifier),
      const SizedBox(height: 28),
      _buildActionCard(context, state, notifier),
    ];

    final resultContent = [
      if (state.result != null || state.headPath.isNotEmpty) _buildEducationalInsights(state),
      const SizedBox(height: 28),
      if (state.result != null || state.headPath.isNotEmpty) _buildVisualization(context, state),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AdaptiveLayout(
            mobile: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const GlassSliverAppBar(title: 'DISK MANAGEMENT'),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
                  sliver: SliverList(delegate: SliverChildListDelegate([...configContent, const SizedBox(height: 28), ...resultContent, const SizedBox(height: 150)])),
                ),
              ],
            ),
            desktop: Column(
              children: [
                const GlassAppBar(title: 'DISK MANAGEMENT'),
                Expanded(child: DesktopContentShell(configChildren: configContent, resultChildren: resultContent)),
              ],
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassAppBar(title: 'DISK MANAGEMENT'),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(StorageState state, StorageNotifier notifier) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 40,
      opacity: 0.05,
      child: LiquidSegmentedControl<StorageMode>(
        values: StorageMode.values,
        labels: const ['FRAGMENTATION', 'HEAD SCHEDULING'],
        selectedValue: state.mode,
        onSelected: notifier.setMode,
      ),
    );
  }

  Widget _buildAlgorithmSelector(StorageState state, StorageNotifier notifier) {
    if (state.mode == StorageMode.scheduling) {
      return GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 40,
        opacity: 0.03,
        child: LiquidSegmentedControl<DiskAlgorithm>(
          values: DiskAlgorithm.values,
          labels: const ['FCFS (Queued)', 'SCAN (Elevator)', 'C-SCAN (Loop)'],
          selectedValue: state.algorithm,
          onSelected: notifier.setAlgorithm,
          fontSize: 10,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEducationalInsights(StorageState state) {
    String title = "Disk Insight 💿";
    String msg = "Modern storage management optimizes how data is physically arranged and accessed on the drive to minimize mechanical wear and speed up data retrieval.";
    Color color = AppTheme.infoColor;

    if (state.mode == StorageMode.fragmentation) {
      if (state.result != null && state.result!.fragmentedFilesRatio > 0.4) {
        title = "High Fragmentation 🧩";
        msg = "Multiple files are scattered! This increases 'Seek Time' as the head must move to multiple physical locations to read a single file. SSDs mitigate this, but it's still a filesystem overhead.";
        color = AppTheme.errorColor;
      } else {
        msg = "Contiguous allocation ensures maximum read speeds. File fragmentation occurs when files are frequently created, edited, and deleted.";
        color = AppTheme.successColor;
      }
    } else {
      if (state.algorithm == DiskAlgorithm.scan) {
        msg = "SCAN (Elevator) reduces arm movement significantly by serving requests in one direction until it reaches the edge, then reverses—just like an elevator.";
        color = AppTheme.successColor;
      } else if (state.algorithm == DiskAlgorithm.cScan) {
        msg = "C-SCAN (Circular SCAN) provides more uniform waiting times by only serving requests in one direction, then jumping back to the start without serving requests on the return trip.";
        color = AppTheme.infoColor;
      } else if (state.algorithm == DiskAlgorithm.fcfs) {
        msg = "FCFS Disk Scheduling is simple but inefficient. It can cause the disk arm to swing wildly across the platter, increasing wear and latency.";
        color = AppTheme.warningColor;
      }
    }
    return InsightCard(title: title, message: msg, color: color);
  }

  Widget _buildActionCard(BuildContext context, StorageState state, StorageNotifier notifier) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(state.mode == StorageMode.fragmentation ? 'Physical Operations 📀' : 'Cylinder Queue 📥', 
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 18)),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      notifier.clearAll();
                      if (state.mode == StorageMode.fragmentation) {
                        notifier.addOperation(name: 'A', type: StorageOpType.create, size: 8);
                        notifier.addOperation(name: 'B', type: StorageOpType.create, size: 12);
                        notifier.addOperation(name: 'A', type: StorageOpType.delete, size: 0);
                        notifier.addOperation(name: 'C', type: StorageOpType.create, size: 6);
                      } else {
                        for (var c in [12, 42, 8, 35, 24, 16, 48]) {
                          notifier.addDiskRequest(c);
                        }
                      }
                    },
                    icon: const Icon(Icons.auto_awesome_rounded, color: Colors.amberAccent),
                    tooltip: 'Educational Scenario',
                  ),
                  IconButton(onPressed: notifier.clearAll, icon: const Icon(Icons.refresh_rounded, color: Colors.white38)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (state.mode == StorageMode.fragmentation)
            _AnimatedStorageInput(onAdd: (n, t, s) => notifier.addOperation(name: n, type: t, size: s))
          else
            _AnimatedSchedulingInput(onAdd: (c) => notifier.addDiskRequest(c)),
        ],
      ),
    );
  }

  Widget _buildVisualization(BuildContext context, StorageState state) {
    if (state.mode == StorageMode.fragmentation) {
      return Column(
        children: [
          if (state.result != null) ...[
            _buildMetricCard(context, state),
            const SizedBox(height: 28),
            _buildAllocationSteps(context, state),
          ],
        ],
      );
    } else {
      return _buildSchedulingPath(context, state);
    }
  }

  Widget _buildMetricCard(BuildContext context, StorageState state) {
    final result = state.result!;
    return GlassCard(
      color: AppTheme.accentColor,
      opacity: 0.05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric(context, 'FRAGMENTATION', '${(result.fragmentedFilesRatio * 100).toStringAsFixed(1)}%', Icons.blur_on_rounded),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildMetric(context, 'UTILIZATION', '${(result.fragmentedAreaRatio * 100).toStringAsFixed(1)}%', Icons.donut_large_rounded),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value, IconData icon) {
    return Column(children: [Icon(icon, color: AppTheme.primaryColor, size: 28), const SizedBox(height: 12), Text(value, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)), Text(label, style: Theme.of(context).textTheme.labelSmall)]);
  }

  Widget _buildAllocationSteps(BuildContext context, StorageState state) {
    return GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Allocation Timeline 📉', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 18)), const SizedBox(height: 32), ...state.result!.steps.map((step) => _buildStepRow(context, step))]));
  }

  Widget _buildStepRow(BuildContext context, StorageStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: Text('STEP ${step.stepIndex}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5))), const SizedBox(width: 16), Text(step.description, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15))]),
          const SizedBox(height: 16),
          SingleChildScrollView(scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), child: Row(children: step.blocks.map<Widget>((fileName) { final color = fileName != null ? step.fileColors[fileName]! : Colors.white.withValues(alpha: 0.05); return Container(width: 20, height: 20, margin: const EdgeInsets.symmetric(horizontal: 1.5), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5), border: Border.all(color: fileName != null ? Colors.white24 : Colors.transparent, width: 0.5)), child: Center(child: Text(fileName ?? '', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)))); }).toList())),
        ],
      ),
    );
  }

  Widget _buildSchedulingPath(BuildContext context, StorageState state) {
    return RepaintBoundary(
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Head Movement Path 🧭', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 18)),
            const SizedBox(height: 40),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: CustomPaint(painter: _DiskPathPainter(state.headPath)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DiskPathPainter extends CustomPainter {
  final List<int> path;
  _DiskPathPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final dotPaint = Paint()..color = Colors.white;
    final glowPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final stepY = size.height / (path.length - 1);
    final scaleX = size.width / 49;

    for (int i = 0; i < path.length - 1; i++) {
      final p1 = Offset(path[i] * scaleX, i * stepY);
      final p2 = Offset(path[i + 1] * scaleX, (i + 1) * stepY);
      
      canvas.drawLine(p1, p2, glowPaint);
      canvas.drawLine(p1, p2, paint);
      canvas.drawCircle(p1, 5, dotPaint);
    }
    canvas.drawCircle(Offset(path.last * scaleX, (path.length - 1) * stepY), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DiskPathPainter oldDelegate) => oldDelegate.path != path;
}

class _AnimatedStorageInput extends StatefulWidget {
  final Function(String n, StorageOpType t, int s) onAdd;
  const _AnimatedStorageInput({required this.onAdd});
  @override
  State<_AnimatedStorageInput> createState() => _AnimatedStorageInputState();
}

class _AnimatedStorageInputState extends State<_AnimatedStorageInput> {
  final _n = TextEditingController();
  final _s = TextEditingController();
  StorageOpType _t = StorageOpType.create;

  @override
  Widget build(BuildContext context) {
    return Column(children: [Row(children: [Expanded(flex: 3, child: _buildField(_n, 'Name')), const SizedBox(width: 16), Expanded(flex: 4, child: _buildDropdown())]), const SizedBox(height: 16), Row(children: [if (_t != StorageOpType.delete) ...[Expanded(child: _buildField(_s, 'Size')), const SizedBox(width: 16)], GestureDetector(onTap: () { if (_n.text.isNotEmpty) { widget.onAdd(_n.text.trim(), _t, int.tryParse(_s.text) ?? 0); _n.clear(); _s.clear(); } }, child: Container(height: 60, padding: const EdgeInsets.symmetric(horizontal: 24), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.accentColor]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]), child: const Center(child: Text('ADD OPERATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)))))])]);
  }

  Widget _buildField(TextEditingController c, String label) {
    return Container(height: 60, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)), child: TextField(controller: c, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), decoration: InputDecoration(border: InputBorder.none, labelText: label, labelStyle: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0))));
  }

  Widget _buildDropdown() {
    return Container(height: 60, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)), child: DropdownButton<StorageOpType>(value: _t, dropdownColor: AppTheme.surfaceColor, underline: const SizedBox(), isExpanded: true, items: StorageOpType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)))).toList(), onChanged: (v) => v != null ? setState(() => _t = v) : null));
  }
}

class _AnimatedSchedulingInput extends StatelessWidget {
  final Function(int c) onAdd;
  _AnimatedSchedulingInput({required this.onAdd});
  final _c = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(children: [Expanded(child: Container(height: 60, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)), child: TextField(controller: _c, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), decoration: const InputDecoration(border: InputBorder.none, labelText: 'Cylinder Addr (0-49)', labelStyle: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0))))), const SizedBox(width: 16), GestureDetector(onTap: () { final c = int.tryParse(_c.text); if (c != null) { onAdd(c); _c.clear(); } }, child: Container(height: 60, width: 60, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.accentColor]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]), child: const Icon(Icons.add_rounded, color: Colors.white, size: 32)))]);
  }
}
