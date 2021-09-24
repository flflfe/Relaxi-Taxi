import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:relaxi_driver/main.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({Key? key}) : super(key: key);

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  String pheobe="very_good_driver";
  double avgRate = 0;
  Color txtColor = Colors.black;
  String driverLabel="";
  List<Icon> stars=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getRate();
  }
  @override
  Widget build(BuildContext context) {

    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    double? heightTop= _height/2 - 50.0;
    return SafeArea(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomRight:Radius.circular(_width/3) ,bottomLeft: Radius.circular(_width/3)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey, blurRadius: 10.0
                )
              ]
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: _width/8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('your average rate:',textScaleFactor: 1.2,),
                    SizedBox(height: 8.0,),
                    Text(avgRate.toString(), style: GoogleFonts.lobsterTwo(fontWeight: FontWeight.bold),textScaleFactor:4.0,),
                    Divider(height: 30.0,thickness: 0.5,color: Colors.grey,indent: _width/4,endIndent: _width/4,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:stars,
                    )
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Padding(
                padding: const EdgeInsets.only(top:40.0, bottom: 30.0,left: 20,right: 20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(driverLabel, style: GoogleFonts.lobster(color: txtColor, fontWeight: FontWeight.bold),textScaleFactor: 2.5,),
                    Text(' Driver',style: GoogleFonts.lobster(color: Colors.black, ),textScaleFactor: 2.5,)
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: grey, blurRadius: 10.0
                        )
                      ]
                  ),
                  child: Image.asset('assets/$pheobe.gif', width: _width/2,),
                ),
              )


            ],
          )
        ],
      )
    );
  }
  void getStars(double rate,double size,{bool showText:true })
  {

    int index=rate.toInt();
    for(int i=0;i<index;i++)
    {
      setState(() {
        stars.add(Icon(CupertinoIcons.star_fill, color: grad1,size: size,));
      });

    }
    if(rate>index.toDouble())
    {
      setState(() {
        stars.add(Icon(CupertinoIcons.star_lefthalf_fill,size: size,color: grad1,));
      });
      for(int i=0;i<5-(rate+1);i++)
        {
          setState(() {
            stars.add(Icon(CupertinoIcons.star,size: size,color: grad1,));
          });
        }
      return;
    }
    for(int i=0;i<5-rate;i++)
    {
      setState(() {
        stars.add(Icon(CupertinoIcons.star,size: size,color: grad1,));
      });
    }

  }
  void _getRate()async
  {
    await currentDriverRef.once().then((DataSnapshot dataSnapshot) {
      if(dataSnapshot.value!= null)
        {
          if(dataSnapshot.value["avg_rating"]==null)
            {
              setState(() {
                avgRate= 5.0;
              });
            }
          else
            {
              setState(() {
                avgRate= double.parse(dataSnapshot.value["avg_rating"].toString());
              });
            }

          if(avgRate>=1 && avgRate <2)
            {
              setState(() {
                txtColor=Colors.red;
                driverLabel='very Bad';
                pheobe = 'very_bad_driver';
              });
            }
          else if(avgRate>=2 && avgRate <3)
          {
            setState(() {
              txtColor=Colors.deepOrange;
              driverLabel='Bad';
              pheobe = 'bad_driver';
            });
          }
          else if(avgRate>=3 && avgRate <4)
          {
            setState(() {
              txtColor=Colors.red;
              driverLabel='Average';
              pheobe = 'ok_driver';
            });
          }
          else if(avgRate>=4 && avgRate <4.5)
          {
            setState(() {
              txtColor=Colors.green;
              driverLabel='Good';
              pheobe = 'good_driver';
            });
          }
          else if(avgRate>=4.5 )
          {
            setState(() {
              txtColor=Colors.lightGreenAccent;
              driverLabel='very Good';
              pheobe = 'very_good_driver';
            });
          }

          getStars(avgRate, 30.0 ,showText: false);
        }
      else
        {
          setState(() {
            avgRate = 0;
          });
        }
    });
  }
}
