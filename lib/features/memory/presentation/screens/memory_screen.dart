import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/adaptive_layout.dart';
import '../../../../shared/widgets/insight_card.dart';
import '../../../../shared/widgets/liquid_segmented_control.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../providers/memory_provider.dart';

class MemoryScreen extends ConsumerWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memoryProvider);
    final notifier = ref.read(memoryProvider.notifier);

    final configContent = [
      _buildModeSelector(state, notifier),
      const SizedBox(height: 32),
      _buildAlgorithmSelector(state, notifier),
      const SizedBox(height: 32),
      _buildActionCard(context, state, notifier),
    ];

    final resultContent = [
      _buildEducationalInsights(state),
      const SizedBox(height: 32),
      if (state.snapshots.isNotEmpty || state.pagingHistory.isNotEmpty) _buildVisualization(context, state),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AdaptiveLayout(
            mobile: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const GlassSliverAppBar(title: 'MEMORY MANAGEMENT'),
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
            child: GlassAppBar(title: 'MEMORY MANAGEMENT'),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(MemoryState state, MemoryNotifier notifier) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 40,
      opacity: 0.05,
      child: LiquidSegmentedControl<MemoryMode>(
        values: MemoryMode.values,
        labels: const ['ALLOCATION', 'PAGING'],
        selectedValue: state.mode,
        onSelected: notifier.setMode,
      ),
    );
  }

  Widget _buildAlgorithmSelector(MemoryState state, MemoryNotifier notifier) {
    final isAlloc = state.mode == MemoryMode.allocation;
    
    if (isAlloc) {
      return GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 40,
        opacity: 0.03,
        child: LiquidSegmentedControl<MemoryAlgorithm>(
          values: MemoryAlgorithm.values,
          labels: const ['FIRST FIT', 'NEXT FIT', 'BEST FIT', 'WORST FIT'],
          selectedValue: state.algorithm,
          onSelected: notifier.setAlgorithm,
          fontSize: 9,
        ),
      );
    } else {
      return GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 40,
        opacity: 0.03,
        child: LiquidSegmentedControl<PagingAlgorithm>(
          values: PagingAlgorithm.values,
          labels: const ['FIFO (Queue)', 'LRU (History)'],
          selectedValue: state.pagingAlgorithm,
          onSelected: notifier.setPagingAlgorithm,
        ),
      );
    }
  }

  Widget _buildEducationalInsights(MemoryState state) {
    String title = "RAM Insight 🧠";
    String msg = "Memory management handles how the OS shares physical RAM between multiple applications while protecting their data.";
    Color color = AppTheme.infoColor;

    if (state.mode == MemoryMode.allocation) {
      if (state.algorithm == MemoryAlgorithm.bestFit) {
        msg = "Best Fit minimizes wasted space, but often leaves behind tiny 'Holes' (External Fragmentation) that are too small for any process to use.";
        color = AppTheme.warningColor;
      } else if (state.algorithm == MemoryAlgorithm.firstFit) {
        msg = "First Fit is the fastest allocation method! It reduces CPU overhead by stopping at the very first available block that fits the process.";
        color = AppTheme.successColor;
      } else if (state.algorithm == MemoryAlgorithm.worstFit) {
        msg = "Worst Fit leaves the largest possible remaining holes, which might be more useful for future large process requests.";
      }
    } else {
      if (state.pagingAlgorithm == PagingAlgorithm.lru) {
        msg = "Least Recently Used (LRU) is highly effective as it exploits 'Temporal Locality'—the idea that pages accessed recently are likely to be accessed again.";
        color = AppTheme.successColor;
      } else {
        msg = "First-In-First-Out (FIFO) is simple to implement but can suffer from 'Belady's Anomaly', where adding more frames can actually increase page faults!";
        color = AppTheme.warningColor;
      }
    }
    return InsightCard(title: title, message: msg, color: color);
  }

  Widget _buildActionCard(BuildContext context, MemoryState state, MemoryNotifier notifier) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(state.mode == MemoryMode.allocation ? 'Memory Requests 📥' : 'Page Sequence 🔢', 
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      notifier.clearAll();
                      if (state.mode == MemoryMode.allocation) {
                        notifier.addRequest(size: 20, duration: 5);
                        notifier.addRequest(size: 10, duration: 3);
                        notifier.addRequest(size: 15, duration: 2);
                      } else {
                        for (var p in [7, 0, 1, 2, 0, 3, 0, 4, 2, 3]) {
                          notifier.addPageRef(p);
                        }
                      }
                    },
                    icon: const Icon(Icons.auto_awesome_rounded, color: Colors.amberAccent),
                    tooltip: 'Typical Scenario',
                  ),
                  IconButton(onPressed: notifier.clearAll, icon: const Icon(Icons.refresh_rounded, color: Colors.white38)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (state.mode == MemoryMode.allocation)
            _AnimatedMemoryInput(onAdd: (s, d) => notifier.addRequest(size: s, duration: d))
          else
            _AnimatedPagingInput(onAdd: (p) => notifier.addPageRef(p)),
        ],
      ),
    );
  }

  Widget _buildVisualization(BuildContext context, MemoryState state) {
    if (state.mode == MemoryMode.allocation) {
      return GlassCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Physical RAM Timeline 🏗️', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 18)),
            const SizedBox(height: 28),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGridHeader(),
                  const SizedBox(height: 16),
                  ...state.snapshots.map((s) => _buildSnapshotRow(context, s)),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return GlassCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Virtual Page Frames 📄', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 18)),
            const SizedBox(height: 28),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: state.pagingHistory.map((h) => _buildPagingStep(h)).toList(),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildGridHeader() {
    return Row(
      children: [
        const SizedBox(width: 50),
        ...List.generate(kMemorySize, (i) => Container(
          width: 24, alignment: Alignment.center,
          child: Text(i.toString(), style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w900)),
        )),
      ],
    );
  }

  Widget _buildSnapshotRow(BuildContext context, dynamic s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text('T${s.time}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14, color: Colors.white60))),
          ...s.slots.map((pId) {
            final color = pId != null ? s.processColors[pId] : Colors.white.withValues(alpha: 0.03);
            return Container(
              width: 22, height: 22, margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(6),
                border: Border.all(color: pId != null ? Colors.white24 : Colors.white.withValues(alpha: 0.05), width: 0.5),
              ),
              child: Center(child: Text(pId ?? '', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900))),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPagingStep(PagingStep h) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Text('Ref: ${h.page}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 16),
          ...h.frames.map((f) => Container(
            width: 44, height: 44, margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: f != null ? AppTheme.primaryColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Center(child: Text(f?.toString() ?? '-', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 16))),
          )),
          const SizedBox(height: 12),
          Icon(h.isFault ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: h.isFault ? AppTheme.errorColor : AppTheme.successColor, size: 24),
          Text(h.isFault ? 'FAULT' : 'HIT', style: TextStyle(color: h.isFault ? AppTheme.errorColor : AppTheme.successColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _AnimatedMemoryInput extends StatefulWidget {
  final Function(int s, int d) onAdd;
  const _AnimatedMemoryInput({required this.onAdd});
  @override
  State<_AnimatedMemoryInput> createState() => _AnimatedMemoryInputState();
}

class _AnimatedMemoryInputState extends State<_AnimatedMemoryInput> {
  final _s = TextEditingController();
  final _d = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildField(_s, 'Size'),
        const SizedBox(width: 16),
        _buildField(_d, 'Duration'),
        const SizedBox(width: 16),
        _addBtn(() {
          final s = int.tryParse(_s.text);
          final d = int.tryParse(_d.text);
          if (s != null && d != null) { widget.onAdd(s, d); _s.clear(); _d.clear(); }
        }),
      ],
    );
  }

  Widget _buildField(TextEditingController c, String label) {
    return Expanded(child: Container(height: 60, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)), child: TextField(controller: c, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), decoration: InputDecoration(border: InputBorder.none, labelText: label, labelStyle: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0)))));
  }

  Widget _addBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        height: 60, width: 60, 
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.accentColor]), 
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ), 
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32)
      )
    );
  }
}

class _AnimatedPagingInput extends StatelessWidget {
  final Function(int p) onAdd;
  _AnimatedPagingInput({required this.onAdd});
  final _p = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 60, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)), child: TextField(controller: _p, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), decoration: const InputDecoration(border: InputBorder.none, labelText: 'Page Ref Number', labelStyle: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0))))),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () { final p = int.tryParse(_p.text); if (p != null) { onAdd(p); _p.clear(); } }, 
          child: Container(
            height: 60, width: 60, 
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.accentColor]), 
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ), 
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 32)
          )
        ),
      ],
    );
  }
}
