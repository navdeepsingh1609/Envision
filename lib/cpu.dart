import 'dart:collection';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'main.dart';

enum CpuAlgo { First_Come_First_Serve, Shortest_Job_First, Round_Robin}

int TimeQuantum = 2;

String getCpuData(DataChoice? choice) {
  switch (choice) {
    case DataChoice.First:
      return "0,2;3,8;4,5;6,9;8,3";
    default:
      return "";
  }
}

Widget runCpuAlgo(CpuAlgo algo, StringBuffer log, List<List<num>> processes,int n) {
  TimeQuantum=n;
  //print("=============RECIEVED=======$TimeQuantum");
  switch (algo) {
    case CpuAlgo.First_Come_First_Serve:
      return FCFS(processes, log);
    case CpuAlgo.Shortest_Job_First:
      return SJF(processes, log);
    case CpuAlgo.Round_Robin:
      return RR(processes, log, TimeQuantum);
  }
}

Widget FCFS(List<List<num>> processes, StringBuffer log) {
  log.write("Starting First Come First Serve with $processes");
  num totalTime = 0;
  num count = 1;
  num totalWait = 0;
  List<CpuProcessBar> resList = [];
  for (var process in processes) {
    if (process[0] > totalTime) {
      int time = process[0] - totalTime as int;
      log.write("\nWaiting for $time");
      resList.add(new CpuProcessBar(totalTime as int, totalTime + time, "", Colors.grey));
      totalTime += time;
    }

    var color = Colors.green;
    if (process[0] < totalTime) {
      log.write("\nP$count is waiting for ${totalTime - process[0]}");
      totalWait += totalTime - process[0];
      color = Colors.orange;
    }
    log.write("\nRunning P$count");
    resList.add(CpuProcessBar(totalTime as int, totalTime + (process[1] as int), "P$count", color));
    totalTime += process[1] as int;
    count += 1;
  }

  log.write("\nFinished FCFS");
  return CpuResult(totalWait / processes.length, resList);
}

Widget SJF(List<List<num>> processes, StringBuffer log) {
  log.write("Starting Shortest Job First with $processes");
  num totalTime = 0;
  num count = 0;
  num totalWait = 0;
  List<CpuProcessBar> resList = [];
  List<Color> colors = List.generate(processes.length, (index) => Color((Random(index).nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0));
  var delayProcess = [0, double.infinity, -1];

  List<num> currentProcess = delayProcess;
  num currentWork = 0;
  Queue<List<num>> backlog = new Queue();
  while (true) {
    if (currentProcess[1] == 0) {
      resList.add(CpuProcessBar(totalTime - currentWork as int, totalTime as int, currentProcess[2] != -1 ? "P${currentProcess[2] + 1}" : "", currentProcess[2] != -1 ? colors[currentProcess[2] as int] : Colors.grey));
      log.write("\nFinished P${currentProcess[2] + 1}, saving work ($currentWork) in bar");
      currentWork = 0;
      if (backlog.isNotEmpty) {
        currentProcess = backlog.removeLast();
        log.write("\n   Starting P${currentProcess[2] + 1} again");
      } else {
        log.write("\n   Queue, is empty, starting delay task");
        currentProcess = delayProcess;
      }
    }

    if (count <= processes.length - 1) {
      while (processes[count as int][0] <= totalTime) {
        log.write("\nStarting process P${count + 1} ${processes[count]} at time $totalTime");
        processes[count].add(count);
        if (processes[count][1] < currentProcess[1]) {
          if (currentWork != 0) {
            resList
                .add(CpuProcessBar(totalTime - currentWork as int, totalTime as int, currentProcess[2] != -1 ? "P${currentProcess[2] + 1}" : "", currentProcess[2] != -1 ? colors[currentProcess[2] as int] : Colors.grey));
          }
          log.write("\n   New process is shorter than existing, saving work ($currentWork) in bar and starting P${count + 1}");
          currentWork = 0;

          if (currentProcess[2] != -1) backlog.add(currentProcess);
          currentProcess = processes[count];
        } else {
          log.write("\n   New process is longer than existing, adding to queue");
          backlog.add(processes[count]);
        }
        count++;
        if (count > processes.length - 1) break;
      }
    }

    if (currentProcess[2] == -1 && count >= processes.length) {
      log.write("\nFinished SJF");
      break;
    }

    currentProcess[1]--;
    currentWork++;
    totalTime++;
    backlog.forEach((element) => totalWait++);
    log.write("\n#######P${currentProcess[2] + 1} $currentProcess, currentWork: $currentWork, time: $totalTime, totalWait: $totalWait, count $count, backlog: $backlog");
  }

  return CpuResult(totalWait / processes.length, resList);
}

Widget RR(List<List<num>> processes, StringBuffer log, int n) {
  log.write("Starting Round Robin ($n) with $processes");
  num totalTime = 0;
  num count = 0;
  num totalWait = 0;
  List<CpuProcessBar> resList = [];
  List<Color> colors = List.generate(processes.length, (index) => Color((Random(index).nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0));
  var delayProcess = [0, double.infinity, -1];

  List<num> currentProcess = delayProcess;
  num currentWork = 0;
  Queue<List<num>> backlog = new Queue();
  Queue<List<num>> queue = new Queue();
  while (true) {
    if (count <= processes.length - 1) {
      while (processes[count as int][0] <= totalTime) {
        log.write("\nQueueing process P${count + 1} ${processes[count]} at time $totalTime");
        processes[count].add(count);
        queue.add(processes[count]);
        count++;
        if (count > processes.length - 1) break;
      }
    }

    if (currentProcess[1] == 0 || currentWork == n || (currentProcess[2] == -1 && (backlog.isNotEmpty || queue.isNotEmpty))) {
      if (currentWork != 0)
        resList.add(CpuProcessBar(totalTime - currentWork as int, totalTime as int, currentProcess[2] != -1 ? "P${currentProcess[2] + 1}" : "", currentProcess[2] != -1 ? colors[currentProcess[2] as int] : Colors.grey));
      log.write("\nStopping P${currentProcess[2] + 1}, saving work ($currentWork) in bar");
      if (currentProcess[1] != 0 && currentProcess[2] != -1) {
        log.write("\n   Backlogged P${currentProcess[2] + 1}");
        backlog.add(currentProcess);
      } else {
        log.write("\n   Finished P${currentProcess[2] + 1}");
      }

      currentWork = 0;
      if (queue.isNotEmpty) {
        log.write("\n   Starting P${queue.last[2] + 1} from queue $queue");
        currentProcess = queue.removeFirst();
      } else if (backlog.isNotEmpty) {
        log.write("\n   Starting P${backlog.last[2] + 1} from backlog $backlog");
        currentProcess = backlog.removeFirst();
      } else {
        if (count >= processes.length) break;
        log.write("\n   Queue, is empty, starting delay task");
        currentProcess = delayProcess;
      }
    }

    currentProcess[1]--;
    currentWork++;
    totalTime++;
    backlog.forEach((element) => totalWait++);
    queue.forEach((element) => totalWait++);
    log.write("\n#######P${currentProcess[2] + 1} $currentProcess, currentWork: $currentWork, time: $totalTime, totalWait: $totalWait, count $count, backlog: $backlog");
  }
  log.write("\nFinished RR$n");
  return CpuResult(totalWait / processes.length, resList);
}

class CpuResult extends StatelessWidget {
  final double avgWait;
  final List<CpuProcessBar> list;
  const CpuResult(this.avgWait, this.list);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            "Average wait: ${avgWait.toStringAsFixed(2)}",
            style: const TextStyle(fontFamily: 'Nutino',),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 50,
          child: Row(
            children: list,
          ),
        ),
      ],
    );
  }
}

class CpuProcessBar extends StatelessWidget {
  final int start;
  final int end;
  final String text;
  final Color color;

  const CpuProcessBar(this.start, this.end, this.text, this.color);

  @override
  Widget build(BuildContext context) {

    return Flexible(
      flex: end - start,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border(
            right: const BorderSide(),
            left: BorderSide(color: Colors.white.withAlpha(start == 0 ? 255 : 0)),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nutino',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: -20,
              child: Center(
                child: Text(
                  end.toString(),
                  style: TextStyle(color: Colors.white,fontFamily: 'Nutino',),
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: -20,
              child: Center(
                child: Text(
                  start == 0 ? '0' : '',
                  style: TextStyle(color: Colors.white, fontFamily: 'Nutino',),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




