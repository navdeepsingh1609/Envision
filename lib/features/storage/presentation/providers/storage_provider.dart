import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/storage_model.dart';

enum StorageMode { fragmentation, scheduling }
enum DiskAlgorithm { fcfs, scan, cScan }

const int kTotalDisk = 48;
const int kMaxCylinders = 50; 

class StorageState {
  final List<StorageOperationModel> ops;
  final List<int> diskRequests;
  final StorageMode mode;
  final DiskAlgorithm algorithm;
  final StorageResultModel? result;
  final List<int> headPath;
  final int initialHead;
  final String? error;

  StorageState({
    this.ops = const [],
    this.diskRequests = const [],
    this.mode = StorageMode.fragmentation,
    this.algorithm = DiskAlgorithm.fcfs,
    this.result,
    this.headPath = const [],
    this.initialHead = 25,
    this.error,
  });

  StorageState copyWith({
    List<StorageOperationModel>? ops,
    List<int>? diskRequests,
    StorageMode? mode,
    DiskAlgorithm? algorithm,
    StorageResultModel? result,
    List<int>? headPath,
    int? initialHead,
    String? error,
  }) {
    return StorageState(
      ops: ops ?? this.ops,
      diskRequests: diskRequests ?? this.diskRequests,
      mode: mode ?? this.mode,
      algorithm: algorithm ?? this.algorithm,
      result: result ?? this.result,
      headPath: headPath ?? this.headPath,
      initialHead: initialHead ?? this.initialHead,
      error: error ?? this.error,
    );
  }
}

class StorageNotifier extends StateNotifier<StorageState> {
  StorageNotifier() : super(StorageState()) {
    // Default fragmentation data
    addOperation(name: 'A', type: StorageOpType.create, size: 10);
    addOperation(name: 'B', type: StorageOpType.create, size: 15);
    addOperation(name: 'A', type: StorageOpType.delete, size: 0);
    addOperation(name: 'C', type: StorageOpType.create, size: 8);
    // Default scheduling data
    state = state.copyWith(diskRequests: [10, 45, 2, 38, 22]);
    _run();
  }

  void setMode(StorageMode mode) {
    state = state.copyWith(mode: mode);
    _run();
  }

  void setAlgorithm(DiskAlgorithm algo) {
    state = state.copyWith(algorithm: algo);
    _run();
  }

  void addOperation({required String name, required StorageOpType type, int size = 0}) {
    state = state.copyWith(ops: [...state.ops, StorageOperationModel(fileName: name, type: type, size: size)], error: null);
    _run();
  }

  void addDiskRequest(int cylinder) {
    if (cylinder < 0 || cylinder >= kMaxCylinders) return;
    state = state.copyWith(diskRequests: [...state.diskRequests, cylinder]);
    _run();
  }

  void clearAll() {
    state = StorageState(mode: state.mode);
  }

  void _run() {
    if (state.mode == StorageMode.fragmentation) {
      _runFragmentation();
    } else {
      _runScheduling();
    }
  }

  void _runFragmentation() {
    if (state.ops.isEmpty) {
      state = state.copyWith(result: null);
      return;
    }
    final List<String?> disk = List.filled(kTotalDisk, null);
    final List<StorageStep> history = [];
    final Map<String, Color> fileColors = {};
    final random = Random();

    for (int i = 0; i < state.ops.length; i++) {
      final op = state.ops[i];
      fileColors.putIfAbsent(op.fileName, () => Color((random.nextDouble() * 0xFFFFFF).toInt()).withValues(alpha: 1.0));
      String msg = "";
      if (op.type == StorageOpType.delete) {
        for (int j = 0; j < kTotalDisk; j++) {
          if (disk[j] == op.fileName) {
            disk[j] = null;
          }
        }
        msg = "Deleted ${op.fileName}";
      } else {
        int need = op.size;
        int got = 0;
        for (int j = 0; j < kTotalDisk && got < need; j++) {
          if (disk[j] == null) {
            disk[j] = op.fileName;
            got++;
          }
        }
        msg = got < need ? "Failed: Disk Full" : "Allocated ${op.size} for ${op.fileName}";
      }
      history.add(StorageStep(stepIndex: i + 1, blocks: List.from(disk), fileColors: Map.from(fileColors), description: msg));
    }
    final files = <String, List<int>>{};
    for (int i = 0; i < kTotalDisk; i++) {
      if (disk[i] != null) {
        files.putIfAbsent(disk[i]!, () => []).add(i);
      }
    }
    int fragCount = 0;
    int fragSize = 0;
    int totalSize = 0;
    files.forEach((name, ids) {
      totalSize += ids.length;
      bool isFrag = false;
      for (int k = 0; k < ids.length - 1; k++) {
        if (ids[k + 1] != ids[k] + 1) {
          isFrag = true;
        }
      }
      if (isFrag) {
        fragCount++;
        fragSize += ids.length;
      }
    });
    state = state.copyWith(result: StorageResultModel(steps: history, fragmentedFilesRatio: files.isEmpty ? 0 : fragCount / files.length, fragmentedAreaRatio: totalSize == 0 ? 0 : fragSize / totalSize));
  }

  void _runScheduling() {
    if (state.diskRequests.isEmpty) {
      state = state.copyWith(headPath: []);
      return;
    }
    final List<int> path = [state.initialHead];
    final reqs = List<int>.from(state.diskRequests);

    switch (state.algorithm) {
      case DiskAlgorithm.fcfs:
        path.addAll(reqs);
        break;
      case DiskAlgorithm.scan:
        reqs.sort();
        final right = reqs.where((r) => r >= state.initialHead).toList();
        final left = reqs.where((r) => r < state.initialHead).toList().reversed.toList();
        path.addAll(right);
        if (right.isNotEmpty || left.isNotEmpty) {
          path.add(kMaxCylinders - 1);
        }
        path.addAll(left);
        break;
      case DiskAlgorithm.cScan:
        reqs.sort();
        final right = reqs.where((r) => r >= state.initialHead).toList();
        final left = reqs.where((r) => r < state.initialHead).toList();
        path.addAll(right);
        if (right.isNotEmpty || left.isNotEmpty) {
          path.add(kMaxCylinders - 1);
          path.add(0);
        }
        path.addAll(left);
        break;
    }
    state = state.copyWith(headPath: path);
  }
}

final storageProvider = StateNotifierProvider<StorageNotifier, StorageState>((ref) => StorageNotifier());
