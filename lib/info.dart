import 'package:flutter/material.dart';
import 'ElevatedCard.dart';
import 'HeadingCard.dart';

class info extends StatefulWidget {
  const info({Key? key}) : super(key: key);

  @override
  State<info> createState() => _infoState();
}

class _infoState extends State<info> {
  String head1="First Come First Serve";
  String para1='''
1) Jobs are executed on first come,first serve basis.
2) It is a non-preemptive, pre-emptive scheduling algorithm.
3) Easy to understand and implement.
4) It's implementation is based on FIFO queue.
5) Poor in performance as average wait time is high.''';
  String head2="Shortest Job First";
  String para2=''' 
1) It schedules the processes according to their burst time.
2) The process with lowest burst time, among the list of available processes in the ready queue, is going to be scheduled next.
3) Maximum throughput.
4) Minimum average waiting and turnaround time.
5) May suffer with the problem of starvation.
6) It is not implementable because the exact Burst time for a process can't be known in advance.''';
  String head3="Round Robin";
  String para3='''
1) Round Robin is the preemptive process scheduling algorithm.
2) Each process is provided a fix time to execute, it is called a quantum.
3) Once a process is executed for a given time period, it is preempted and other process executes for a given time period.
4) Context switching is used to save states of preempted processes.
''';
  String head4="First Fit";
  String para4=''' 
It's carried out as follows: 
1) Input the blocks and the processes in an array.
2) Set all the memory blocks to free.
3) Check if the size of process <= memory block then allocate the process to a memory block.
4) Else keep traversing the other blocks until the size of process <= memory block will not hold true.''';
  String head5="Next Fit";
  String para5='''
1) Next fit is a modified version of ‘first fit’. It begins as the first fit to find a free partition but when called next time it starts searching from where it left off, not from the beginning. 
2) This policy makes use of a roving pointer. The pointer moves along the memory chain to search for a next fit. This helps in, to avoid the usage of memory always from the head (beginning) of the free block chain.
3) Next fit is a very fast searching algorithm and is also comparatively faster than First Fit and Best Fit Memory Management Algorithms.
''';
  String head6="Best Fit";
  String para6=''' 
1) This algorithm tries to find out smallest hole possible in the list that can accommodate the size requirement of the process.
2) It is slower as it scans the entire list every time.
3) Due to the fact that the difference b/w the hole size and the process size is very small, the holes produced will be as small as it cannot be used to load any process and therefore it remains useless.
''';
  String head7="Worst Fit";
  String para7=''' 
1) The worst fit algorithm scans the entire list every time and tries to find out the biggest hole in the list which can fulfill the requirement of the process.
2) Despite of the fact that this algorithm produces the larger holes to load the other processes, this is not the better approach due to the fact that it is slower because it searches the entire list every time again and again.''';
  String head8="File Fragmentation";
  String para8='''
1) File fragmentation is a term that describes a group of files that are scattered throughout a hard drive platter instead of one continuous location. 
2) Fragmentation is caused when information is deleted from a hard drive and small gaps are left behind to be filled by new data.
3) As new data is saved to the computer, it is placed in these gaps. If the gaps are too small, the remainder of what needs to be saved is stored in other available gaps.''';
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: double.infinity,
        height: 3400,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xff654ea3), Color(0xffeaafc8)])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black54.withOpacity(0.7),
            elevation: 2,
            centerTitle: true,
            title:  const Text("Information",style: TextStyle(fontFamily: 'Nutino',),),

          ),
          body: Column(
            children: <Widget>[
              HeadingCard(sv: 'CPU',Head: 'CPU SCHEDULING',),
              const Spacer(),
              ElevatedCard(info_heading: head1, info_text:para1),
              const Spacer(),
              ElevatedCard(info_heading: head2, info_text:para2),
              const Spacer(),
              ElevatedCard(info_heading: head3, info_text:para3),
              const Spacer(),
              HeadingCard(sv:'RAM',Head: 'MEMORY SCHEDULING',),
              ElevatedCard(info_heading: head4, info_text:para4),
              const Spacer(),
              ElevatedCard(info_heading: head5, info_text:para5),
              const Spacer(),
              ElevatedCard(info_heading: head6, info_text:para6),
              const Spacer(),
              ElevatedCard(info_heading: head7, info_text:para7),
              const Spacer(),
              HeadingCard(sv: 'SSD',Head: 'STORAGE FRAGMENTATION',),
              ElevatedCard(info_heading: head8, info_text:para8),
            ],
          ),
        ),
      ),
    ));
  }
}
