import 'package:flutter/material.dart';

class CpuProcess {
  final int id;
  final int arrivalTime;
  final int burstTime;
  final int priority; // Lower value = higher priority
  int remainingTime;
  final Color color;
  
  // Track metrics
  int? completionTime;
  int? turnaroundTime;
  int? waitingTime;

  CpuProcess({
    required this.id,
    required this.arrivalTime,
    required this.burstTime,
    this.priority = 0,
    required this.color,
  }) : remainingTime = burstTime;

  String get name => 'P${id + 1}';

  @override
  String toString() => '$name($arrivalTime, $burstTime)';
}

class CpuExecutionStep {
  final int start;
  final int end;
  final String processName;
  final Color color;

  CpuExecutionStep({
    required this.start,
    required this.end,
    required this.processName,
    required this.color,
  });
}

class CpuResultModel {
  final double averageWaitTime;
  final List<CpuExecutionStep> executionSteps;

  CpuResultModel({
    required this.averageWaitTime,
    required this.executionSteps,
  });
}
