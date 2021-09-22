import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constants/all_cons.dart';
import 'package:google_fonts/google_fonts.dart';

class RateDriver extends StatefulWidget {
  final String? driverId;
  const RateDriver({Key? key,this.driverId}) : super(key: key);

  @override
  _RateDriverState createState() => _RateDriverState();
}

class _RateDriverState extends State<RateDriver> with TickerProviderStateMixin{
  int? rate;
  bool chose=false;
  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Colors.transparent,
      //insetPadding: EdgeInsets.only(left: 50.0,right: 50.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0)
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/rate.png', width: _width/2,),
              SizedBox(height: 10.0,),
              Text('How Was The Ride?', style: GoogleFonts.pacifico(color: Colors.black),textScaleFactor: 1.6,),
              SizedBox(height: 5.0,),
              Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: (rate==1)?5:4,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: GestureDetector(
                        child: Column(
                          children: [
                            Opacity(opacity:(rate==1)?1:0.2,child: Image.asset('assets/very_bad.png')),
                            Text('Very Bad', style: TextStyle(color: Color(0xFF78A7FF), fontWeight: FontWeight.bold, fontSize: rate==1?12.0:0),
                            )
                          ],
                        ),
                        onTap: (){
                          setState(() {
                            rate=1;//very bad
                            if(chose==false)
                            {
                              setState(() {
                                chose = true;
                              });
                            }
                          });
                        },
                      ),
                    ),

                  ),
                  Expanded(
                    flex: (rate==2)?5:4,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: GestureDetector(
                        child: Column(
                          children: [
                            Opacity(opacity:(rate==2)?1:0.2,child: Image.asset('assets/bad.png')),
                            Text('Bad', style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: rate==2?12.0:0),
                            )
                          ],
                        ),
                        onTap: (){
                          setState(() {
                            rate=2;//excellent
                            if(chose==false)
                            {
                              setState(() {
                                chose = true;
                              });
                            }
                          });
                        },
                      ),
                    ),

                  ),
                  Expanded(
                    flex: (rate==3)?5:4,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: GestureDetector(
                        child: Column(
                          children: [
                            Opacity(opacity:(rate==3)?1:0.2,child: Image.asset('assets/ok.png')),
                            Text('Ok', style: TextStyle(color: Colors.brown,
                                fontWeight: FontWeight.bold,
                                fontSize: rate==3?12.0:0),
                            )
                          ],
                        ),
                        onTap: (){
                          setState(() {
                            rate=3;//ok
                            if(chose==false)
                            {
                              setState(() {
                                chose = true;
                              });
                            }
                          });
                        },
                      ),
                    ),

                  ),
                  Expanded(
                    flex: (rate==4)?5:4,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: GestureDetector(
                        child: Column(
                          children: [
                            Opacity(opacity:(rate==4)?1:0.2,child: Image.asset('assets/good.png')),
                            Text('Good', style: TextStyle(color: Colors.lightGreen,
                                fontWeight: FontWeight.bold, fontSize: rate==4?12.0:0),
                            )
                          ],
                        ),
                        onTap: (){
                          setState(() {
                            rate=4;//excellent
                            if(chose==false)
                            {
                              setState(() {
                                chose = true;
                              });
                            }
                          });
                        },
                      ),
                    ),

                  ),
                  Expanded(
                    flex: (rate==5)?5:4,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: GestureDetector(
                        child: Column(
                          children: [
                            Opacity(opacity:(rate==5)?1:0.2,child: Image.asset('assets/very_good.png')),
                            Text('Excellent', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: rate==5?12.0:0),
                            )
                          ],
                        ),
                        onTap: (){
                          setState(() {
                            rate=5;//excellent
                            if(chose==false)
                              {
                                setState(() {
                                  chose = true;
                                });
                              }
                          });
                        },
                      ),
                    ),

                  ),

                ],
              ),
              ),
              AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 200),
                curve: Curves.elasticInOut,
                child: OutlinedButton(onPressed: ()async
                {
                  DatabaseReference driverRatingRef = FirebaseDatabase.instance.reference().
                  child("drivers").
                  child(widget.driverId!).
                  child("total_rating");
                  DatabaseReference driverAvgRatingRef = FirebaseDatabase.instance.reference().
                  child("drivers").
                  child(widget.driverId!).
                  child("avg_rating");
                  DatabaseReference tripCountRef = FirebaseDatabase.instance.reference().
                  child("drivers").
                  child(widget.driverId!).
                  child("total_rated_trips");
                  double totalRatedTrips=1;
                  double totalRatings= rate!.toDouble();
                  tripCountRef.once().then((DataSnapshot dataSnapshot){
                    if(dataSnapshot.value!=null)
                    {
                      totalRatedTrips+= double.parse(dataSnapshot.value.toString());

                      tripCountRef.set(totalRatedTrips.toString());
                    }
                    else
                    {
                      tripCountRef.set("1");
                    }
                  });
                  driverRatingRef.once().then((DataSnapshot dataSnapshot){
                    if(dataSnapshot.value!=null)
                      {
                        totalRatings+=double.parse(dataSnapshot.value.toString());
                        driverRatingRef.set(totalRatings.toString());
                      }
                    else
                      {
                        driverRatingRef.set(totalRatings.toString());
                      }
                  });
                  driverAvgRatingRef.once().then((DataSnapshot dataSnapshot){
                    if(dataSnapshot.value!=null)
                    {
                      double average= totalRatings/totalRatedTrips;
                      driverAvgRatingRef.set(average.toString());
                    }
                    else
                    {
                      driverAvgRatingRef.set(totalRatings.toString());
                    }
                  });
                  Navigator.pop(context);
                },
                    child:Text('submit', textScaleFactor: 1.2, style: GoogleFonts.montserrat(color: Colors.black),),
                    style: ButtonStyle(
                      fixedSize: chose?MaterialStateProperty.all(Size(_width/4,50)):MaterialStateProperty.all(Size(0, 0)),
                      minimumSize: MaterialStateProperty.all(Size(0, 0)),
                      overlayColor: MaterialStateProperty.all(grad1.withOpacity(0.2))

                    ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
