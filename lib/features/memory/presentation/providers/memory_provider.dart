import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/memory_model.dart';

enum MemoryMode { allocation, paging }
enum MemoryAlgorithm { firstFit, nextFit, bestFit, worstFit }
enum PagingAlgorithm { fifo, lru }

const int kMemorySize = 50;
const int kFrameCount = 4;

class MemoryState {
  final List<MemoryProcessModel> requests;
  final List<int> pageReferenceString;
  final MemoryMode mode;
  final MemoryAlgorithm algorithm;
  final PagingAlgorithm pagingAlgorithm;
  final List<MemorySnapshot> snapshots;
  final List<PagingStep> pagingHistory;
  final String? error;

  MemoryState({
    this.requests = const [],
    this.pageReferenceString = const [],
    this.mode = MemoryMode.allocation,
    this.algorithm = MemoryAlgorithm.firstFit,
    this.pagingAlgorithm = PagingAlgorithm.fifo,
    this.snapshots = const [],
    this.pagingHistory = const [],
    this.error,
  });

  MemoryState copyWith({
    List<MemoryProcessModel>? requests,
    List<int>? pageReferenceString,
    MemoryMode? mode,
    MemoryAlgorithm? algorithm,
    PagingAlgorithm? pagingAlgorithm,
    List<MemorySnapshot>? snapshots,
    List<PagingStep>? pagingHistory,
    String? error,
  }) {
    return MemoryState(
      requests: requests ?? this.requests,
      pageReferenceString: pageReferenceString ?? this.pageReferenceString,
      mode: mode ?? this.mode,
      algorithm: algorithm ?? this.algorithm,
      pagingAlgorithm: pagingAlgorithm ?? this.pagingAlgorithm,
      snapshots: snapshots ?? this.snapshots,
      pagingHistory: pagingHistory ?? this.pagingHistory,
      error: error ?? this.error,
    );
  }
}

class PagingStep {
  final int page;
  final List<int?> frames;
  final bool isFault;
  PagingStep({required this.page, required this.frames, required this.isFault});
}

class MemoryNotifier extends StateNotifier<MemoryState> {
  MemoryNotifier() : super(MemoryState()) {
    // Default allocation data
    addRequest(size: 15, duration: 5);
    addRequest(size: 10, duration: 3);
    addRequest(size: 20, duration: 8);
    // Default paging data
    state = state.copyWith(pageReferenceString: [7, 0, 1, 2, 0, 3, 0]);
    _runSimulation();
  }

  void setMode(MemoryMode mode) {
    state = state.copyWith(mode: mode);
    _runSimulation();
  }

  void setAlgorithm(MemoryAlgorithm algo) {
    state = state.copyWith(algorithm: algo);
    _runSimulation();
  }

  void setPagingAlgorithm(PagingAlgorithm algo) {
    state = state.copyWith(pagingAlgorithm: algo);
    _runSimulation();
  }

  void addRequest({required int size, required int duration}) {
    final random = Random();
    final newRequest = MemoryProcessModel(
      id: String.fromCharCode(65 + state.requests.length),
      size: size,
      duration: duration,
      color: Color((random.nextDouble() * 0xFFFFFF).toInt()).withValues(alpha: 1.0),
    );
    state = state.copyWith(requests: [...state.requests, newRequest]);
    _runSimulation();
  }

  void addPageRef(int page) {
    state = state.copyWith(pageReferenceString: [...state.pageReferenceString, page]);
    _runSimulation();
  }

  void clearAll() {
    state = MemoryState(mode: state.mode);
  }

  void _runSimulation() {
    if (state.mode == MemoryMode.allocation) {
      _runAllocation();
    } else {
      _runPaging();
    }
  }

  void _runAllocation() {
    if (state.requests.isEmpty) {
      state = state.copyWith(snapshots: []);
      return;
    }
    final queue = List<MemoryProcessModel>.from(state.requests.map((r) => MemoryProcessModel(id: r.id, size: r.size, duration: r.duration, color: r.color)));
    final List<MemoryProcessModel> active = [];
    final List<String?> ram = List.filled(kMemorySize, null);
    final Map<String, Color> colors = {for (var r in queue) r.id: r.color};
    final List<MemorySnapshot> history = [];
    int time = 0;
    int lastPos = 0;

    while (queue.isNotEmpty || active.isNotEmpty) {
      time++;
      final finished = active.where((p) => p.remainingDuration <= 1).toList();
      for (var p in finished) {
        for (int i = p.startAddress!; i <= p.endAddress!; i++) {
          ram[i] = null;
        }
        active.remove(p);
      }
      for (var p in active) {
        p.remainingDuration--;
      }
      if (queue.isNotEmpty) {
        final p = queue[0];
        final start = _findHole(ram, p.size, lastPos);
        if (start != null) {
          p.startAddress = start;
          p.endAddress = start + p.size - 1;
          for (int i = p.startAddress!; i <= p.endAddress!; i++) {
            ram[i] = p.id;
          }
          active.add(p);
          queue.removeAt(0);
          if (state.algorithm == MemoryAlgorithm.nextFit) {
            lastPos = (p.endAddress! + 1) % kMemorySize;
          }
        }
      }
      history.add(MemorySnapshot(time: time, slots: List.from(ram), processColors: Map.from(colors)));
      if (time > 100) {
        break;
      }
    }
    state = state.copyWith(snapshots: history);
  }

  int? _findHole(List<String?> ram, int size, int last) {
    final holes = <MapEntry<int, int>>[];
    int? current;
    for (int i = 0; i < kMemorySize; i++) {
      if (ram[i] == null) {
        current ??= i;
      } else if (current != null) {
        holes.add(MapEntry(current, i - current));
        current = null;
      }
    }
    if (current != null) {
      holes.add(MapEntry(current, kMemorySize - current));
    }
    if (holes.isEmpty) {
      return null;
    }

    switch (state.algorithm) {
      case MemoryAlgorithm.firstFit:
        for (var h in holes) {
          if (size <= h.value) {
            return h.key;
          }
        }
        break;
      case MemoryAlgorithm.nextFit:
        final rotated = [...holes.where((h) => h.key >= last), ...holes.where((h) => h.key < last)];
        for (var h in rotated) {
          if (size <= h.value) {
            return h.key;
          }
        }
        break;
      case MemoryAlgorithm.bestFit:
        holes.sort((a, b) => a.value.compareTo(b.value));
        for (var h in holes) {
          if (size <= h.value) {
            return h.key;
          }
        }
        break;
      case MemoryAlgorithm.worstFit:
        holes.sort((a, b) => b.value.compareTo(a.value));
        for (var h in holes) {
          if (size <= h.value) {
            return h.key;
          }
        }
        break;
    }
    return null;
  }

  void _runPaging() {
    if (state.pageReferenceString.isEmpty) {
      state = state.copyWith(pagingHistory: []);
      return;
    }
    final List<int?> frames = List.filled(kFrameCount, null);
    final List<PagingStep> history = [];
    final List<int> usageOrder = [];

    for (var page in state.pageReferenceString) {
      bool isFault = false;
      if (!frames.contains(page)) {
        isFault = true;
        if (frames.contains(null)) {
          int idx = frames.indexOf(null);
          frames[idx] = page;
          usageOrder.add(page);
        } else {
          if (state.pagingAlgorithm == PagingAlgorithm.fifo) {
            int old = usageOrder.removeAt(0);
            int idx = frames.indexOf(old);
            frames[idx] = page;
            usageOrder.add(page);
          } else {
            // LRU
            int lruPage = usageOrder.removeAt(0);
            int idx = frames.indexOf(lruPage);
            frames[idx] = page;
            usageOrder.add(page);
          }
        }
      } else if (state.pagingAlgorithm == PagingAlgorithm.lru) {
        usageOrder.remove(page);
        usageOrder.add(page);
      }
      history.add(PagingStep(page: page, frames: List.from(frames), isFault: isFault));
    }
    state = state.copyWith(pagingHistory: history);
  }
}

final memoryProvider = StateNotifierProvider<MemoryNotifier, MemoryState>((ref) => MemoryNotifier());
