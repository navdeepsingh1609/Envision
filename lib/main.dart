import 'package:flutter/material.dart';
import 'package:envision/cpu.dart';
import 'package:envision/memory.dart';
import 'package:envision/storage.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'info.dart';
import 'dart:ui';
import 'ElevatedCard2.dart';

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Envision',
    theme: ThemeData(
      primaryColor: Colors.white,
      primaryColorDark: Colors.white,
      highlightColor: Colors.white,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: const AlgoApp()));

enum DataChoice { First, Second, Third, Own }

enum Component { CPU, Memory, Storage }

class AlgoApp extends StatefulWidget {
  const AlgoApp({super.key});

  @override
  _AlgoAppState createState() => _AlgoAppState();
}

class _AlgoAppState extends State<AlgoApp> {
  DataChoice? dataChoice = DataChoice.First;
  Component? component = Component.CPU;
  TextEditingController? _controller;
  late List<bool> selectedAlgo;
  bool hasResult = false;
  bool error = false;
  String choiceText = "";
  int curr_idx = 0;
  Widget? resWidget;
  FocusNode focus = FocusNode(); //Keyboard EVENTS MANAGEMENT
  int timeQuantum = 2;
  bool isRR = false;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      curr_idx = 0;
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const info()),
        );
      } else if (index == 1) {
        component = Component.CPU;
      } else if (index == 2) {
        component = Component.Memory;
      } else if (index == 3) {
        component = Component.Storage;
      }
      resWidget = const Padding(
        padding: EdgeInsets.all(50.0),
      );
      setSelectedAlgoList();
    });
  }

  String InputFormat() {
    if (component == Component.CPU) {
      return '''
<Process1, Length1; Process1, Length1; >
0,2;3,8;4,5;6,9;8,3''';
    } else if (component == Component.Memory) {
      return '''
 <Memory1, Length1; Memory2, Length2; ... >
1,6; 21,6; 3,6; 4,2; 1,4; 3,2; 1,2; 4,1; 22,3''';
    } else if (component == Component.Storage) {
      return '''
A,1; B,2; A,-; C,3; B,+2; D,5; E,6; B,-; F,3
<Process, Size/Operation;>
+ implies Create
- implies Delete''';
    } else {
      return "";
    }
  }

  @override
  void initState() {
    setSelectedAlgoList();
    _controller = TextEditingController(text: choiceText);
    resWidget = const Padding(padding: EdgeInsets.all(50.0));
    focus.addListener(() {
      if (focus.hasFocus) setState(() => dataChoice = DataChoice.Own);
    });
    super.initState();
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFrag = component == Component.Storage;

    Widget buildSectionTitle(String title) {
      return Container(
        width: 250,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black54.withOpacity(0.5),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Nutino',
            ),
          ),
        ),
      );
    }

    Widget buildProcessTable() {
      List processes;
      if (choiceText.isEmpty && dataChoice == DataChoice.Own) {
        return const TableErrorContainer(text: "Enter List For Output");
      }
      try {
        if (component == Component.Storage) {
          processes = parseStorageOperations();
        } else {
          processes = parseComputationProcesses();
          processes[processes.length - 1][1];
        }
      } catch (e) {
        return const TableErrorContainer(text: "Invalid Input");
      }
      switch (component) {
        case Component.CPU:
          return ProcessTable.fromProcessList(
            processes as List<List<num>>,
            "Arrival time",
            "Length",
            (int index) => "P${index + 1}",
          );
        case Component.Memory:
          return ProcessTable.fromProcessList(
            processes as List<List<num>>,
            "Memory",
            "Length",
            (int index) => MemoryProcess.generateName(index),
          );
        case Component.Storage:
          return ProcessTable.fromStorageList(
            processes as List<StorageOperation>,
          );
        default:
          return const TableErrorContainer(text: "No Component Selected");
      }
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xff654ea3), Color(0xffeaafc8)],
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AppBar(
                backgroundColor: Colors.black54.withOpacity(0.7),
                elevation: 0,
                title: Center(
                  child: Text(
                    isFrag
                        ? 'File Fragmentation'
                        : '${component.toString().split(".")[1]} Scheduling',
                    style: const TextStyle(fontFamily: 'Nutino',color: Colors.white,fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          preferredSize: Size(
            double.infinity,
            56.0,
          ),
        ),
        body: Stack(children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(height:  2*kToolbarHeight,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buildSectionTitle("Choose Algorithm:"),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) =>
                        buildAlgoToggle(constraints),
                  ),
                  IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(height: 20.0),
                        Column(
                          children: [
                            buildSectionTitle("Input Format & List:"),
                            ElevatedCard2(info_text: InputFormat()),
                            buildSectionTitle("Create Your Process List:"),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                              child: generateDataInputList(),
                            ),
                            Visibility(
                              visible: isRR,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: TextFormField(
                                  initialValue: "2",
                                  keyboardType: TextInputType.number,
                                  onChanged: (s) {
                                    setState(() {
                                      if (s.isNotEmpty) {
                                        timeQuantum = int.parse(s);
                                        for (int i = 0;
                                            i < selectedAlgo.length;
                                            i++) {
                                          if (selectedAlgo[i]) runAlgo(i);
                                        }
                                      }
                                    });
                                  },
                                  cursorColor: Colors.white,
                                  decoration: InputDecoration(
                                    icon: const Icon(
                                      Icons.alarm_add,
                                      color: Colors.black26,
                                    ),
                                    border: const OutlineInputBorder(),
                                    labelText: 'Enter Time Quantum Here',
                                    errorText:
                                        error ? "Enter Valid Input" : null,
                                    labelStyle: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                const SizedBox(height: 20.0),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: buildSectionTitle("Process Table:"),
                                ),
                                const SizedBox(height: 10.0),
                                Flexible(child: buildProcessTable()),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buildSectionTitle("Output:"),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: IntrinsicHeight(child: resWidget!),
                  ),
                  const SizedBox(height: 2*kToolbarHeight+5,),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: BottomNavigationBar(
                    selectedLabelStyle: const TextStyle(fontFamily: 'Nutino'),
                    items: [
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          "assets/icons/INFO.svg",
                          height: 40.0,
                          width: 50.0,
                          allowDrawingOutsideViewBox: true,
                        ),
                        label: 'INFO',
                        backgroundColor: Colors.black54.withOpacity(0.3),
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          "assets/icons/CPU.svg",
                          height: 40.0,
                          width: 50.0,
                          allowDrawingOutsideViewBox: true,
                        ),
                        label: 'CPU',
                        backgroundColor: Colors.black54.withOpacity(0.3),
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          "assets/icons/RAM.svg",
                          height: 40.0,
                          width: 50.0,
                          allowDrawingOutsideViewBox: true,
                        ),
                        label: 'Memory',
                        backgroundColor: Colors.black54.withOpacity(0.3),
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          "assets/icons/SSD.svg",
                          height: 40.0,
                          width: 50.0,
                          allowDrawingOutsideViewBox: true,
                        ),
                        label: 'Storage',
                        backgroundColor: Colors.black54.withOpacity(0.3),
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    onTap: _onItemTapped,
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget buildAlgoToggle(BoxConstraints constraints) {
    List algoEnum = getComponentAlgoEnum()!;
    return ToggleSwitch(
      key: ValueKey(_selectedIndex),
      activeBorders: List.generate(
        algoEnum?.length ?? 0,
        (index) => Border.all(
          color: const Color(0xff5f65bf),
          width: 3.0,
        ),
      ),
      activeFgColor: Colors.white,
      inactiveFgColor: Colors.white,
      isVertical: true,
      minWidth: 200.0,
      radiusStyle: true,
      cornerRadius: 20.0,
      initialLabelIndex: curr_idx,
      activeBgColors: List.generate(
        algoEnum?.length ?? 0, // Match number of options
        (index) => [const Color(0xffa29fd9)],
      ),
      labels: algoEnum
              ?.map((algo) =>
                  algo.toString().split('.').last) // Use dynamic labels
              .toList() ??
          [], // Fallback to empty list
      onToggle: (index) {
        if (index != null && selectedAlgo[index]) {
          setState(() {});
        } else {
          setState(() {
            curr_idx = index!;
          });
          setState(() {
            if (component == Component.CPU && index == 2) {
              isRR = true;
            } else {
              isRR = false;
            }
          });
          runAlgo(index!);
        }
        print('switched to: $index');
      },
    );
  }

  Widget generateDataInputList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
      child: TextFormField(
        cursorColor: Colors.white,
        focusNode: focus,
        controller: _controller,
        decoration: InputDecoration(
          icon: const Icon(
            Icons.data_array_sharp,
            color: Colors.black26,
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff5f65bf)),
          ),
          labelText: 'Enter Input Array Here',
          errorText: error ? "Enter Vaild Input" : null,
          labelStyle: const TextStyle(
            color: Colors.black54,
          ),
        ),
        onChanged: (s) {
          setState(() {
            choiceText = s;
            for (int i = 0; i < selectedAlgo.length; i++) {
              if (selectedAlgo[i]) runAlgo(i);
            }
          });
        },
      ),
    );
  }

  List? getComponentAlgoEnum() {
    List? algoEnum;
    switch (component) {
      case Component.CPU:
        algoEnum = CpuAlgo.values;
        break;
      case Component.Memory:
        algoEnum = MemoryAlgo.values;
        break;
      case Component.Storage:
        algoEnum = StorageAlgo.values;
        break;
      case null:
        algoEnum = [];
        break;
    }
    // Debugging: Log algoEnum to verify its content
    print('Current algoEnum: $algoEnum for component: $component');
    return algoEnum;
  }

  void setSelectedAlgoList() {
    setState(() {
      selectedAlgo =
          List.generate(getComponentAlgoEnum()!.length, (index) => false);
    });
  }

  String getData(DataChoice? choice) {
    if (choice == DataChoice.Own) {
      return choiceText;
    }
    switch (component) {
      case Component.CPU:
        return getCpuData(choice);
      case Component.Memory:
        return getMemoryData(choice);
      case Component.Storage:
        return getStorageData(choice);
      default:
        return "";
    }
  }

  List<List<num>> parseComputationProcesses() {
    var rawInput = getData(dataChoice).split(";");
    return List.generate(rawInput.length, (i) {
      var str = rawInput[i].split(",");
      return [int.parse(str[0]), int.parse(str[1])];
    });
  }

  List<StorageOperation> parseStorageOperations() {
    var rawInput = getData(dataChoice).split(';');
    return List.generate(
        rawInput.length, (index) => StorageOperation(rawInput[index]));
  }

  void runAlgo(int algoIndex) {
    StringBuffer log = StringBuffer();
    log.writeln("Parsing input");
    try {
      Widget? algoResult;
      switch (component) {
        case Component.CPU:
          algoResult = runCpuAlgo(CpuAlgo.values[algoIndex], log,
              parseComputationProcesses(), timeQuantum);
          break;
        case Component.Memory:
          algoResult = runMemoryAlgo(
              MemoryAlgo.values[algoIndex], log, parseComputationProcesses());
          break;
        case Component.Storage:
          algoResult = runStorageAlgo(log, parseStorageOperations());
          break;
        case null:
          break;
      }
      setState(() {
        resWidget = AlgoResult(algoResult, log);
        error = false;
        for (int i = 0; i < selectedAlgo.length; i++) {
          selectedAlgo[i] = i == algoIndex;
        }
      });
    } catch (e, s) {
      setState(() {
        print("$e\n$s");
        error = true;
        resWidget = AlgoResult(Container(), log);
      });
    }
  }
}

class TableErrorContainer extends StatelessWidget {
  const TableErrorContainer({
    super.key,
    this.text,
  });

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white.withOpacity(0.5),
      width: 200,
      height: 20,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.5)),
      alignment: Alignment.center,
      child: Text(
        text!,
        style:
            const TextStyle(fontFamily: 'Nutino', fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TableCellPadded extends StatelessWidget {
  final EdgeInsets? padding;
  final Widget child;
  final TableCellVerticalAlignment? verticalAlignment;

  const TableCellPadded(
      {super.key, this.padding, required this.child, this.verticalAlignment});

  @override
  TableCell build(BuildContext context) => TableCell(
      verticalAlignment: verticalAlignment,
      child:
          Padding(padding: padding ?? const EdgeInsets.all(5.0), child: child));
}

class ProcessTable extends StatelessWidget {
  final List<TableRow> rows;
  static const TextStyle heading = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontSize: 15,
    fontFamily: 'Nutino',
  );

  static ProcessTable fromProcessList(List<List<num>> processes,
      String firstProperty, String secondProperty, Function generateID) {
    List<TableRow> rowList = List.generate(
      processes.length,
      (index) {
        List<TableCellPadded> cellList = List.generate(
            processes[index].length,
            (secondIndex) => TableCellPadded(
                child: Center(
                    child: Text(processes[index][secondIndex].toString()))));
        cellList.insert(
            0,
            TableCellPadded(
                child: Center(
              child: Text(
                generateID(index),
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Nutino',
                ),
              ),
            )));
        return TableRow(
          children: cellList,
        );
      },
    );
    rowList.insert(
        0,
        TableRow(
          children: [
            const TableCellPadded(
              child: Center(
                child: Text(
                  "ID",
                  style: heading,
                ),
              ),
            ),
            TableCellPadded(
              child: Center(
                child: Text(
                  firstProperty,
                  style: heading,
                ),
              ),
            ),
            TableCellPadded(
              child: Center(
                child: Text(
                  secondProperty,
                  style: heading,
                ),
              ),
            ),
          ],
        ));
    return ProcessTable(rows: rowList);
  }

  static ProcessTable fromStorageList(List<StorageOperation> operations) {
    List<TableRow> rowList = List.generate(
      operations.length,
      (index) {
        var operation = operations[index];
        List<TableCellPadded> cellList = [
          TableCellPadded(
              child: Center(
                  child: Text(
            (index + 1).toString(),
            style: const TextStyle(
              fontFamily: 'Nutino',
            ),
          ))),
          TableCellPadded(
              child: Center(
                  child:
                      Text(operation.operationType.toString().split('.')[1]))),
          TableCellPadded(
              child: Center(
                  child: Text(operation.fileName!,
                      style: const TextStyle(
                        fontFamily: 'Nutino',
                      )))),
        ];
        if (operation.operationType == StorageOperationType.DELETE) {
          cellList.add(const TableCellPadded(
              child: Center(
                  child: Text('Entire file',
                      style: TextStyle(
                        fontFamily: 'Nutino',
                      )))));
        } else {
          cellList.add(TableCellPadded(
              child: Center(
                  child: Text(operation.size.toString(),
                      style: const TextStyle(
                        fontFamily: 'Nutino',
                      )))));
        }
        return TableRow(
          children: cellList,
        );
      },
    );
    rowList.insert(
        0,
        const TableRow(
          children: [
            TableCellPadded(
              child: Center(
                child: Text(
                  'Step',
                  style: heading,
                ),
              ),
            ),
            TableCellPadded(
              child: Center(
                child: Text(
                  'Operation',
                  style: heading,
                ),
              ),
            ),
            TableCellPadded(
              child: Center(
                child: Text(
                  "Filename",
                  style: heading,
                ),
              ),
            ),
            TableCellPadded(
              child: Center(
                child: Text(
                  'Size',
                  style: heading,
                ),
              ),
            ),
          ],
        ));
    return ProcessTable(rows: rowList);
  }

  const ProcessTable({
    super.key,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.5),
      child: Table(
        border: TableBorder.all(),
        children: rows,
      ),
    );
  }
}

class AlgoResult extends StatelessWidget {
  final Widget? resultWidget;
  final StringBuffer log;
  const AlgoResult(this.resultWidget, this.log, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white.withOpacity(0.25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 20.0),
              child: resultWidget!),
        ],
      ),
    );
  }
}
