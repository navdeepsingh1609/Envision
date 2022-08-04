import 'package:flutter/material.dart';

class ElevatedCard extends StatefulWidget {
  ElevatedCard({Key? key,required this.info_heading, required this.info_text}) : super(key: key);
  String info_heading;
  String info_text;
  @override
  State<ElevatedCard> createState() => _ElevatedCardState();
}

class _ElevatedCardState extends State<ElevatedCard> {
  @override
  Widget build(BuildContext context) {
    double width_box=500;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: InkWell(
          onTap: (){
            setState(){
              double temp=width_box;
              width_box=3*width_box;
              width_box=temp;
            };
          },
          child: Card(

            color: Colors.black54.withOpacity(0.4),
            child: SizedBox(
              width: width_box,
              child: Center(child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text('${widget.info_heading}',style: TextStyle(fontFamily: 'Nutino',fontWeight: FontWeight.bold, fontSize: 25,color: Colors.white),),
                    Divider(color: Colors.white,),
                    Text('${widget.info_text}',style: TextStyle(fontFamily: 'Nutino', fontSize: 18,color: Colors.white)),
                  ],
                ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

