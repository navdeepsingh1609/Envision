import 'package:flutter/material.dart';

class MemoryProcessModel {
  final String id;
  final int size;
  final int duration;
  int remainingDuration;
  final Color color;
  int? startAddress;
  int? endAddress;

  MemoryProcessModel({
    required this.id,
    required this.size,
    required this.duration,
    required this.color,
  }) : remainingDuration = duration;

  bool get isAllocated => startAddress != null;

  @override
  String toString() => '$id($size, $duration)';
}

class MemorySnapshot {
  final int time;
  final List<String?> slots; // null means free, String is process ID
  final Map<String, Color> processColors;
  final String? addedProcess;

  MemorySnapshot({
    required this.time,
    required this.slots,
    required this.processColors,
    this.addedProcess,
  });
}
