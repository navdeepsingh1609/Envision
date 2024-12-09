import 'package:flutter/material.dart';

class ElevatedCard extends StatefulWidget {
  ElevatedCard({super.key,required this.info_heading, required this.info_text});
  String info_heading;
  String info_text;
  @override
  State<ElevatedCard> createState() => _ElevatedCardState();
}

class _ElevatedCardState extends State<ElevatedCard> {
  @override
  Widget build(BuildContext context) {
    double widthBox=500;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
          onTap: (){
            setState(){
              double temp=widthBox;
              widthBox=3*widthBox;
              widthBox=temp;
            }
          },
          child: Card(

            color: Colors.black54.withOpacity(0.4),
            child: SizedBox(
              width: widthBox,
              child: Center(child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(widget.info_heading,style: const TextStyle(fontFamily: 'Nutino',fontWeight: FontWeight.bold, fontSize: 25,color: Colors.white),),
                    const Divider(color: Colors.white,),
                    Text(widget.info_text,style: const TextStyle(fontFamily: 'Nutino', fontSize: 18,color: Colors.white)),
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

