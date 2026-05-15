import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cpu_process.dart';

enum CpuAlgorithm { fcfs, sjf, srtf, roundRobin, priority }

class CpuState {
  final List<CpuProcess> processes;
  final CpuAlgorithm algorithm;
  final int timeQuantum;
  final CpuResultModel? result;
  final String? error;

  CpuState({
    this.processes = const [],
    this.algorithm = CpuAlgorithm.fcfs,
    this.timeQuantum = 2,
    this.result,
    this.error,
  });

  CpuState copyWith({
    List<CpuProcess>? processes,
    CpuAlgorithm? algorithm,
    int? timeQuantum,
    CpuResultModel? result,
    String? error,
  }) {
    return CpuState(
      processes: processes ?? this.processes,
      algorithm: algorithm ?? this.algorithm,
      timeQuantum: timeQuantum ?? this.timeQuantum,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

class CpuNotifier extends StateNotifier<CpuState> {
  CpuNotifier() : super(CpuState()) {
    // Populate default data on startup
    addProcess(arrivalTime: 0, burstTime: 8, priority: 2);
    addProcess(arrivalTime: 2, burstTime: 4, priority: 1);
    addProcess(arrivalTime: 4, burstTime: 1, priority: 3);
  }

  void setAlgorithm(CpuAlgorithm algo) {
    state = state.copyWith(algorithm: algo);
    _runAlgorithm();
  }

  void setTimeQuantum(int tq) {
    state = state.copyWith(timeQuantum: tq);
    if (state.algorithm == CpuAlgorithm.roundRobin) {
      _runAlgorithm();
    }
  }

  void addProcess({required int arrivalTime, required int burstTime, int priority = 0}) {
    final random = Random();
    final newProcess = CpuProcess(
      id: state.processes.isEmpty ? 0 : state.processes.map((p) => p.id).reduce(max) + 1,
      arrivalTime: arrivalTime,
      burstTime: burstTime,
      priority: priority,
      color: Color((random.nextDouble() * 0xFFFFFF).toInt()).withValues(alpha: 1.0),
    );
    state = state.copyWith(processes: [...state.processes, newProcess], error: null);
    _runAlgorithm();
  }

  void removeProcess(int id) {
    state = state.copyWith(processes: state.processes.where((p) => p.id != id).toList());
    _runAlgorithm();
  }

  void clearAll() {
    state = CpuState();
  }

  void _runAlgorithm() {
    if (state.processes.isEmpty) {
      state = state.copyWith(result: null);
      return;
    }

    switch (state.algorithm) {
      case CpuAlgorithm.fcfs:
        _runFCFS();
        break;
      case CpuAlgorithm.sjf:
        _runSJF();
        break;
      case CpuAlgorithm.srtf:
        _runSRTF();
        break;
      case CpuAlgorithm.roundRobin:
        _runRR();
        break;
      case CpuAlgorithm.priority:
        _runPriority();
        break;
    }
  }

  void _runFCFS() {
    final sorted = List<CpuProcess>.from(state.processes)
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    int time = 0;
    int totalWait = 0;
    final List<CpuExecutionStep> steps = [];

    for (var p in sorted) {
      if (time < p.arrivalTime) {
        steps.add(CpuExecutionStep(start: time, end: p.arrivalTime, processName: "", color: Colors.grey.withValues(alpha: 0.1)));
        time = p.arrivalTime;
      }
      totalWait += time - p.arrivalTime;
      steps.add(CpuExecutionStep(start: time, end: time + p.burstTime, processName: p.name, color: p.color));
      time += p.burstTime;
    }
    state = state.copyWith(result: CpuResultModel(averageWaitTime: totalWait / sorted.length, executionSteps: steps));
  }

  void _runSJF() {
    final original = List<CpuProcess>.from(state.processes);
    int time = 0;
    int completed = 0;
    int totalWait = 0;
    final List<CpuExecutionStep> steps = [];
    final List<bool> isDone = List.filled(original.length, false);

    while (completed < original.length) {
      int idx = -1;
      int minBurst = 999999;
      for (int i = 0; i < original.length; i++) {
        if (original[i].arrivalTime <= time && !isDone[i]) {
          if (original[i].burstTime < minBurst) {
            minBurst = original[i].burstTime;
            idx = i;
          }
        }
      }
      if (idx == -1) {
        int next = original.where((p) => !isDone[original.indexOf(p)]).map((p) => p.arrivalTime).reduce(min);
        steps.add(CpuExecutionStep(start: time, end: next, processName: "", color: Colors.grey.withValues(alpha: 0.1)));
        time = next;
      } else {
        totalWait += time - original[idx].arrivalTime;
        steps.add(CpuExecutionStep(start: time, end: time + original[idx].burstTime, processName: original[idx].name, color: original[idx].color));
        time += original[idx].burstTime;
        isDone[idx] = true;
        completed++;
      }
    }
    state = state.copyWith(result: CpuResultModel(averageWaitTime: totalWait / original.length, executionSteps: steps));
  }

  void _runSRTF() {
    final n = state.processes.length;
    final processes = List<CpuProcess>.from(state.processes.map((p) => CpuProcess(
      id: p.id,
      arrivalTime: p.arrivalTime,
      burstTime: p.burstTime,
      color: p.color,
    )));
    int time = 0;
    int completed = 0;
    final List<CpuExecutionStep> steps = [];
    int totalWait = 0;
    int? lastIdx;

    while (completed < n) {
      int idx = -1;
      int minRem = 999999;
      for (int i = 0; i < n; i++) {
        if (processes[i].arrivalTime <= time && processes[i].remainingTime > 0) {
          if (processes[i].remainingTime < minRem) {
            minRem = processes[i].remainingTime;
            idx = i;
          }
        }
      }

      if (idx == -1) {
        int next = processes.where((p) => p.remainingTime > 0).map((p) => p.arrivalTime).reduce(min);
        steps.add(CpuExecutionStep(start: time, end: next, processName: "", color: Colors.grey.withValues(alpha: 0.1)));
        time = next;
        lastIdx = null;
      } else {
        if (lastIdx == idx) {
          final lastStep = steps.removeLast();
          steps.add(CpuExecutionStep(start: lastStep.start, end: time + 1, processName: processes[idx].name, color: processes[idx].color));
        } else {
          steps.add(CpuExecutionStep(start: time, end: time + 1, processName: processes[idx].name, color: processes[idx].color));
        }
        processes[idx].remainingTime--;
        time++;
        lastIdx = idx;
        if (processes[idx].remainingTime == 0) {
          completed++;
          totalWait += time - processes[idx].arrivalTime - processes[idx].burstTime;
        }
      }
    }
    state = state.copyWith(result: CpuResultModel(averageWaitTime: totalWait / n, executionSteps: steps));
  }

  void _runRR() {
    final n = state.processes.length;
    final List<int> remBurst = state.processes.map((p) => p.burstTime).toList();
    final List<int> arrival = state.processes.map((p) => p.arrivalTime).toList();
    final List<int> wait = List.filled(n, 0);
    final List<CpuExecutionStep> steps = [];
    final List<int> queue = [];
    final List<bool> inQueue = List.filled(n, false);
    int time = 0;
    int completed = 0;

    void updateQueue() {
      for (int i = 0; i < n; i++) {
        if (arrival[i] <= time && !inQueue[i] && remBurst[i] > 0) {
          queue.add(i);
          inQueue[i] = true;
        }
      }
    }

    updateQueue();
    while (completed < n) {
      if (queue.isNotEmpty) {
        int i = queue.removeAt(0);
        int take = min(state.timeQuantum, remBurst[i]);
        steps.add(CpuExecutionStep(start: time, end: time + take, processName: state.processes[i].name, color: state.processes[i].color));
        time += take;
        remBurst[i] -= take;
        updateQueue();
        if (remBurst[i] > 0) {
          queue.add(i);
        } else {
          completed++;
          wait[i] = time - arrival[i] - state.processes[i].burstTime;
        }
      } else {
        int next = arrival.where((a) => a > time).reduce(min);
        steps.add(CpuExecutionStep(start: time, end: next, processName: "", color: Colors.grey.withValues(alpha: 0.1)));
        time = next;
        updateQueue();
      }
    }
    state = state.copyWith(result: CpuResultModel(averageWaitTime: wait.reduce((a, b) => a + b) / n, executionSteps: steps));
  }

  void _runPriority() {
    final original = List<CpuProcess>.from(state.processes);
    int time = 0;
    int completed = 0;
    int totalWait = 0;
    final List<CpuExecutionStep> steps = [];
    final List<bool> isDone = List.filled(original.length, false);

    while (completed < original.length) {
      int idx = -1;
      int minPri = 999999;
      for (int i = 0; i < original.length; i++) {
        if (original[i].arrivalTime <= time && !isDone[i]) {
          if (original[i].priority < minPri) {
            minPri = original[i].priority;
            idx = i;
          }
        }
      }
      if (idx == -1) {
        int next = original.where((p) => !isDone[original.indexOf(p)]).map((p) => p.arrivalTime).reduce(min);
        steps.add(CpuExecutionStep(start: time, end: next, processName: "", color: Colors.grey.withValues(alpha: 0.1)));
        time = next;
      } else {
        totalWait += time - original[idx].arrivalTime;
        steps.add(CpuExecutionStep(start: time, end: time + original[idx].burstTime, processName: original[idx].name, color: original[idx].color));
        time += original[idx].burstTime;
        isDone[idx] = true;
        completed++;
      }
    }
    state = state.copyWith(result: CpuResultModel(averageWaitTime: totalWait / original.length, executionSteps: steps));
  }
}

final cpuProvider = StateNotifierProvider<CpuNotifier, CpuState>((ref) => CpuNotifier());
