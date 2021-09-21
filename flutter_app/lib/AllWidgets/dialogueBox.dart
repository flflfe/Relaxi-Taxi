import 'dart:async';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constants/all_cons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
class DialogueBox extends StatefulWidget {
  String message;
  DialogueBox({Key? key ,required this.message}) : super(key: key);

  @override
  _DialogueBoxState createState() => _DialogueBoxState();
}


class _DialogueBoxState extends State<DialogueBox> {
  bool end= true;
  double position =0;
  bool isFlipped= false;
  bool isStarted= false;
  @override
  void initState() {
    // TODO: implement initState
    if(!mounted) return;
    super.initState();

      Timer.periodic(Duration(milliseconds: 600), (timer) {
        if(mounted) {setState(() {
          if (isFlipped == true) {
            position -= 50;
            if (position < -250) {
              isFlipped = false;
            }
          }
          else {
            position += 50;
            if (position > 450) {
              isFlipped = true;
            }
          }
        });}
      });



  }


  @override
  Widget build(BuildContext context) {

    @override

    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return Dialog(

      backgroundColor: Colors.white,

        child: SizedBox(
          height: 300,
          child: Stack
          (
            children: [
              Positioned(child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 40,),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: AnimatedTextKit(
                        repeatForever: true,
                        animatedTexts:[WavyAnimatedText(
                          widget.message,
                        textStyle: GoogleFonts.shrikhand(
                          textStyle: TextStyle(
                            fontSize: 26.0,
                            //fontWeight: FontWeight.w500,
                            //fontStyle: FontStyle.italic,
                            color: grad1,
                          )
                        ),
                      ),]
                    ),),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('please wait',textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntuMono(
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              color: Colors.black,
                            )
                        )),
                        SizedBox(
                          width: 8.0,
                        ),
                        SpinKitThreeBounce(
                          color: grad1.withOpacity(0.6),
                          size: 12.0,
                        )

                      ],
                    )
                  ],
                ),
              )),
              Positioned
              (
                  bottom: 40,
                  child: Image.asset("assets/road.png",)
              ),
              AnimatedPositioned(

              bottom: 81,
              left: position,
              duration: Duration(seconds: 1),
              onEnd: (){
                if(mounted){
                  setState(() {
                  if(position>=_width)
                  {
                    isFlipped=true;
                  }
                });
                }
                },
              child: Image.asset(
                isFlipped?"assets/flipped_taxi.gif":"assets/taxi.gif",
                width: (110/xd_width)*_width,),
              ),

            ]
        ))
    );
  }
}
