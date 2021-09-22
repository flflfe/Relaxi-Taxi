import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constants/all_cons.dart';
import 'package:google_fonts/google_fonts.dart';


class CollectCashDialogue extends StatelessWidget {
  final String? paymentMethod;
  final double? fareAmount;
  const CollectCashDialogue({Key? key,  this.paymentMethod,this.fareAmount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return Dialog(
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.only(left: 50.0,right: 50.0),
      elevation: 0.0,
      child: SizedBox(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top:50.0,bottom: 50.0),
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
                  children: [
                    SizedBox(height: 60.0,),
                    Text('Trip Fare',
                      style: GoogleFonts.lobster(
                          fontSize: 20.0,
                          color: Colors.black
                      ),),

                    Padding(padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                        [
                          Text('$fareAmount',
                            style: GoogleFonts.adventPro(
                                fontSize: 38.0,
                                color: Colors.black
                            ),),
                          SizedBox(width: 5.0,),
                          Icon(CupertinoIcons.money_pound, size: 30.0,)
                        ],
                      ),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 18.0),
                      child: Text('please pay the driver this amount of cash and make sure to take the change',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceMono(
                            fontSize: 12.0,
                            color: grey
                        ),),
                    ),
                    Divider(),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 20.0),
                      child: ElevatedButton(onPressed: (){
                        Navigator.pop(context, "close");
                      },

                        style: ButtonStyle(
                            fixedSize: MaterialStateProperty.all(Size(_width,50.0)),
                            backgroundColor: MaterialStateProperty.all(Colors.lightGreen),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(color: Colors.lightGreen)
                            ))
                        ),
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pay $paymentMethod',
                              style: TextStyle(fontSize: 16.0,color: Colors.white),
                            ),
                            Icon(CupertinoIcons.money_euro_circle,color: Colors.white,)
                          ],
                        ), ))
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,

              child: Image.asset('assets/pay_cash.png',width: 100.0,),
            )
          ],
        ),
      ),
    );
  }


}
