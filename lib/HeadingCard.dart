import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeadingCard extends StatelessWidget {
   HeadingCard({super.key, required this.sv, required this.Head});
   String sv;
   String Head;
   @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Card(
        color: const Color(0xffa29fd9),
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Color(0xff5f65bf),
              width: 4,
            ),
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          child: ListTile(
            leading: SvgPicture.asset(
            "assets/icons/$sv.svg",
            height: 40.0,
            width: 50.0,
            allowDrawingOutsideViewBox: true,
          ),
            title: Text(
              Head,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.teal.shade900,
                fontFamily: 'Source Sans Pro',
                fontSize: 20.0,
              ),
            ),
          )),
    );
  }
}
