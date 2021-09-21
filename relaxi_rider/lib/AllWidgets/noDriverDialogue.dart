import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constants/all_cons.dart';
import 'package:google_fonts/google_fonts.dart';

class NoDriverDialogue extends StatelessWidget {
  const NoDriverDialogue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return Dialog(
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.only(left: 50.0,right: 50.0, bottom: 50.0),
      elevation: 0.0,
      child: SizedBox(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Container(

                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0
                    )
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                  //border: Border.all(color: Colors.black26,width: 3.0)
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: 20.0,),
                    Image.asset('assets/no_driver.png',width: 100.0,),
                    SizedBox(height: 20.0,),
                    Text('We\'re very sorry',
                      style: GoogleFonts.lobster(
                          fontSize: 16.0,
                          color: Colors.black
                      ),),

                    Padding(padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:
                        [
                          Expanded(
                            child: Text('There are no available drivers now',overflow: TextOverflow.clip, textAlign: TextAlign.center,
                              style: GoogleFonts.quantico(
                                  fontSize: 20.0,
                                  color: Colors.redAccent
                              ),),
                          ),

                        ],
                      ),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 18.0),
                      child: Text('try again later ...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceMono(
                            fontSize: 12.0,
                            color: grey
                        ),),
                    ),


                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: IconButton(
              splashRadius: 17,
              padding: EdgeInsets.all(0),
              icon:Icon(CupertinoIcons.xmark_circle_fill, size: 40,color: Colors.red,),
              onPressed: (){
                Navigator.pop(context);
              },
            ))
          ],
        ),
      ),
    );
  }
}
