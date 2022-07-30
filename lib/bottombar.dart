import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
    Text(
      'Index 3: Settings',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavigationBar Sample'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/HELP.svg",
              height: 40.0,
              width: 50.0,
              allowDrawingOutsideViewBox: true,
            ),
            label: 'INFO',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/CPU.svg",
              height: 40.0,
              width: 50.0,
              allowDrawingOutsideViewBox: true,
            ),
            label: 'CPU',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/RAM.svg",
              height: 40.0,
              width: 50.0,
              allowDrawingOutsideViewBox: true,
            ),
            label: 'Memory',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/SSD.svg",
              height: 40.0,
              width: 50.0,
              allowDrawingOutsideViewBox: true,
            ),
            label: 'Storage',
            backgroundColor: Colors.black,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    ));
  }
}
