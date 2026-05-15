import 'package:flutter/material.dart';

enum StorageOpType { create, add, delete }

class StorageOperationModel {
  final String fileName;
  final StorageOpType type;
  final int size;

  StorageOperationModel({
    required this.fileName,
    required this.type,
    required this.size,
  });
}

class StorageStep {
  final int stepIndex;
  final List<String?> blocks;
  final Map<String, Color> fileColors;
  final String description;

  StorageStep({
    required this.stepIndex,
    required this.blocks,
    required this.fileColors,
    required this.description,
  });
}

class StorageResultModel {
  final List<StorageStep> steps;
  final double fragmentedFilesRatio;
  final double fragmentedAreaRatio;

  StorageResultModel({
    required this.steps,
    required this.fragmentedFilesRatio,
    required this.fragmentedAreaRatio,
  });
}
