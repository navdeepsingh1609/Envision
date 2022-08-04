import 'package:flutter/material.dart';

class ElevatedCard2 extends StatefulWidget {
  ElevatedCard2({Key? key, required this.info_text}) : super(key: key);
  String info_text;

  @override
  State<ElevatedCard2> createState() => _ElevatedCard2State();
}

class _ElevatedCard2State extends State<ElevatedCard2> {
  @override
  Widget build(BuildContext context) {

    return Center(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 0,
            shape: const RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xff5f65bf),
                width: 3,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            borderOnForeground: true,
            // color: Colors.deepPurpleAccent,
            color: Color(0xffa29fd9),
            child: SizedBox(
              width: 500,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text(textAlign: TextAlign.center,'${widget.info_text}',style: TextStyle(fontFamily: 'Nutino', fontWeight: FontWeight.w800,fontSize: 15,color: Colors.white,))),
              ),
            ),

              ),
              ),
            ),
    );
  }
}

