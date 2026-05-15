import 'package:flutter_test/flutter_test.dart';
import 'package:envision/features/cpu/presentation/providers/cpu_provider.dart';

void main() {
  group('CPU Algorithm Tests', () {
    test('FCFS Calculation Test', () {
      final notifier = CpuNotifier();
      notifier.clearAll();
      notifier.addProcess(arrivalTime: 0, burstTime: 5);
      notifier.addProcess(arrivalTime: 2, burstTime: 3);
      
      notifier.setAlgorithm(CpuAlgorithm.fcfs);
      final result = notifier.state.result;
      
      expect(result, isNotNull);
      // P1 starts at 0, ends at 5. Wait = 0.
      // P2 starts at 5, ends at 8. Wait = 5 - 2 = 3.
      // Avg Wait = (0 + 3) / 2 = 1.5
      expect(result!.averageWaitTime, 1.5);
    });

    test('SRTF Preemption Test', () {
      final notifier = CpuNotifier();
      notifier.clearAll();
      notifier.addProcess(arrivalTime: 0, burstTime: 8);
      notifier.addProcess(arrivalTime: 1, burstTime: 2);
      
      notifier.setAlgorithm(CpuAlgorithm.srtf);
      final steps = notifier.state.result!.executionSteps;
      
      // P1 runs for 1ms, then P2 arrives and is shorter (2 < 7 rem).
      // Step 0: P1 (0-1)
      // Step 1: P2 (1-3)
      // Step 2: P1 (3-10)
      expect(steps[0].processName, 'P1');
      expect(steps[1].processName, 'P2');
      expect(steps[2].processName, 'P1');
    });
  });
}
