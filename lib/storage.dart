import 'dart:math';
import 'package:flutter/material.dart';
import 'main.dart';
enum StorageAlgo { Run }

enum StorageOperationType { CREATE, ADD, DELETE }

const int DRIVE_SIZE = 48;

String getStorageData(DataChoice? choice) {
  switch (choice) {
    case DataChoice.First:
      return "A,1;B,2;A,-;C,3;B,+2;D,5;E,6;B,-;F,3";
    default:
      return "";
  }
}

Widget runStorageAlgo(StringBuffer log, List<StorageOperation> operations) {
  log.writeln('Started storage algo\n');
  int step = 0;
  HardDrive drive = HardDrive(log);
  List<TableRow> resultList = [];
  for (var operation in operations) {
    step++;
    log.writeln('Step $step:');
    if (operation.operationType == StorageOperationType.DELETE) {
      drive.deleteFile(operation.fileName);
    } else {
      if (!drive.addFile(operation.fileName, operation.size)) {
        resultList.add(rowFromDrive(drive, step, true, true));
        log.writeln('\nStorage algo failed!');
        return SingleChildScrollView(
          child: Column(
            children: [resultFromList(resultList)],
          ),
        );
      }
    }
    resultList.add(rowFromDrive(drive, step, false, false));
  }
  resultList.add(rowFromDrive(drive, step, true, false));
  var frags = drive.fragmentedFiles();
  log.writeln('\nStorage algo completed successfully!');
  return SingleChildScrollView(
    child: Column(
      children: [
        resultFromList(resultList),
        Center(
          child: Text(
            'Fragmented files: ${(frags[0] * 100).toStringAsFixed(2)}%',
            style: const TextStyle(fontFamily: 'Nutino'),
          ),
        ),
        Center(
          child: Text(
            'Fragmented area: ${(frags[1] * 100).toStringAsFixed(2)}%',
            style: const TextStyle(fontFamily: 'Nutino'),
          ),
        ),
      ],
    ),
  );
}

class HardDrive {
  final List<String?> blocks = List.generate(DRIVE_SIZE, (_) => null);
  final StringBuffer log;

  HardDrive(this.log);

  bool addFile(String? fileName, num size) {
    if (size > DRIVE_SIZE) {
      log.writeln('File size ($size) exceeds drive capacity ($DRIVE_SIZE)!');
      return false;
    }
    log.writeln('Allocating $size blocks for $fileName');
    int allocated = 0;
    for (int block = 0; block < blocks.length; block++) {
      if (blocks[block] == null) {
        blocks[block] = fileName;
        allocated++;
        if (allocated == size) {
          log.writeln('$fileName allocated successfully.');
          return true;
        }
      }
    }
    log.writeln('Failed to allocate $fileName, only allocated $allocated/$size blocks.');
    return false;
  }

  void deleteFile(String? fileName) {
    log.writeln('Deleting $fileName');
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i] == fileName) {
        log.write('($fileName)');
        blocks[i] = null;
      } else {
        log.write('${blocks[i] ?? ' '}');
      }
    }
    log.write('\n\n');
  }

  List<num> fragmentedFiles() {
    if (blocks.every((block) => block == null)) {
      return [0, 0];
    }

    List<String?> files = [];
    List<int> sizes = [];
    List<bool> fragmented = [];
    String? last = null;

    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i] == null) {
        last = null;
        continue;
      }
      int fileIndex = files.indexOf(blocks[i]);
      if (fileIndex == -1) {
        files.add(blocks[i]);
        sizes.add(1);
        fragmented.add(false);
      } else {
        if (last != blocks[i]) {
          fragmented[fileIndex] = true;
        }
        sizes[fileIndex]++;
      }
      last = blocks[i];
    }

    int fragmentedCount = 0;
    int fragmentedSize = 0;
    for (int i = 0; i < files.length; i++) {
      log.writeln(
        '${files[i]} size: ${sizes[i]}${fragmented[i] ? ', fragmented' : ''}',
      );
      if (fragmented[i]) {
        fragmentedCount++;
        fragmentedSize += sizes[i];
      }
    }

    int totalUsed = sizes.reduce((value, element) => value + element);
    return [
      fragmentedCount / files.length,
      fragmentedSize / totalUsed,
    ];
  }
}

class StorageOperation {
  String? fileName;
  StorageOperationType? operationType;
  late int size;

  StorageOperation(String input) {
    var split = input.split(',');
    fileName = split[0];
    if (split[1] == '-') {
      operationType = StorageOperationType.DELETE;
    } else if (RegExp(r'^\+[0-9]+$').hasMatch(split[1])) {
      operationType = StorageOperationType.ADD;
      size = int.parse(split[1].replaceAll('+', ''));
    } else if (RegExp(r'^[0-9]+$').hasMatch(split[1])) {
      operationType = StorageOperationType.CREATE;
      size = int.parse(split[1]);
    } else {
      throw Exception('Invalid operation format');
    }
  }
}

class StorageResult extends StatelessWidget {
  final List<TableRow> list;
  const StorageResult(this.list, {super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Horizontal scrolling restored
        child:
      IntrinsicHeight(
      child: Table(
        columnWidths: {
          0: FixedColumnWidth(60), // Increased step column width
          for (int i = 1; i <= DRIVE_SIZE; i++) i: FixedColumnWidth(50), // Uniform column width for all
        },
        children: list,
      ),
      ),
    );
  }
}

StorageResult resultFromList(List<TableRow> list) {
  List<TableCell> headerCellList = List.generate(
    DRIVE_SIZE,
        (index) => TableCell(
      verticalAlignment: TableCellVerticalAlignment.bottom,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Center(
          child: Text(
            (index + 1).toString(), // Proper numbering
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontFamily: 'Nutino'),
          ),
        ),
      ),
    ),
  );
  headerCellList.insert(
    0,
    TableCell(
      child: Container(),
    ),
  );
  list.insert(0, TableRow(children: headerCellList));
  return StorageResult(list);
}

TableRow rowFromDrive(HardDrive drive, int step, bool finalRow, bool failed) {
  Color? freeColor = Colors.blueGrey;
  if (finalRow) {
    freeColor = failed ? Colors.blue : Colors.green;
  }
  List<TableCell> cellList = List.generate(
    DRIVE_SIZE,
        (index) {
      var color = freeColor;
      if (!finalRow && drive.blocks[index] != null) {
        color = Color(
          (Random(drive.blocks[index]!.hashCode).nextDouble() * 0xFFFFFF).toInt(),
        ).withOpacity(0.7);
      }
      return TableCell(
        child: Container(
          color: color,
          alignment: Alignment.center,
          child: Center(
            child: Text(
              finalRow ? "" : drive.blocks[index] ?? '',
              style: const TextStyle(fontFamily: 'Nutino'),
            ),
          ),
        ),
      );
    },
  );
  cellList.insert(
    0,
    TableCell(
      child: Container(
        alignment: Alignment.centerRight,
        child: Center(
          child: Text(
            finalRow
                ? failed
                ? 'Fail'
                : 'Done'
                : 'Step $step',
            style: const TextStyle(fontFamily: 'Nutino'),
          ),
        ),
      ),
    ),
  );
  return TableRow(
    children: cellList,
    decoration: BoxDecoration(color: finalRow ? freeColor : Colors.transparent),
  );
}
