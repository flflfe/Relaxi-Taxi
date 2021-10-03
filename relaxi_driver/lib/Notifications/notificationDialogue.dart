import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relaxi_driver/AllScreens/RegistrationScreen.dart';
import 'package:relaxi_driver/AllScreens/newRideScreen.dart';
import 'package:relaxi_driver/Assistants/methods.dart';
import 'package:relaxi_driver/Configurations/configMaps.dart';
import 'package:relaxi_driver/Models/rideDetails.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:relaxi_driver/main.dart';

class NotificationDialogue extends StatelessWidget {
  final RideDetails? rideDetails;
  const NotificationDialogue({Key? key, this.rideDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        backgroundColor: Colors.transparent,
        //elevation: 1.0,
        child: Container(
          margin: EdgeInsets.all(5.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30.0,),
              Image.asset(rideDetails!.rider_gender=='Female'?'assets/female.png':'assets/male.png',width: 200,),
              SizedBox(height: 20.0,),
              Text('New Ride Request!',
              style: GoogleFonts.jua(
                fontSize: 22.0,
                color: Colors.black
              ),),

              Padding(padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 15.0),
                      Icon(Icons.home,color: grad1,),
                      SizedBox(width: 15.0,),
                      Expanded(child: Text("${rideDetails!.pickup_address}",style: TextStyle(fontSize: 15.0,color: grey),))
                    ],
                  ),
                  SizedBox(height: 15.0,),
                  Row(
                    children: [
                      SizedBox(width: 15.0),
                      Icon(Icons.location_on,color: grad1,),
                      SizedBox(width: 15.0,),
                      Expanded(child: Text("${rideDetails!.dropoff_address}",style: TextStyle(fontSize: 15.0,color: grey),))
                    ],
                  ),

                ],
              ),),

              Divider(),

              Padding(padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: (){
                    assetsAudioPlayer.stop();
                    Navigator.pop(context);
                  },
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(Size(90.0,36.0)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.black)
                        )),
                        overlayColor: MaterialStateProperty.all(Colors.black26),
                      ),
                      child:Text(
                        'Reject',
                        style: TextStyle(fontSize: 14.0,color: Colors.black),
                      ) ),
                  SizedBox(width: 30.0,),
                  ElevatedButton(onPressed: (){
                    assetsAudioPlayer.stop();
                    checkRideAvailability(context);
                  },

                      style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(Size(90.0,36.0)),
                      backgroundColor: MaterialStateProperty.all(grad1),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: grad1)
                      ))
                  ),
                      child:Text(
                        'Accept',
                        style: TextStyle(fontSize: 14.0,color: Colors.white),
                      ), )
                ],
              ),)
            ],
          ),

        ),
    );
  }

  void checkRideAvailability(context)
  {
    tripReqRef.once().then((DataSnapshot dataSnapshot){
    Navigator.pop(context);
      String theRideId="";
      if(dataSnapshot.value != null)
        {
          theRideId= dataSnapshot.value.toString();
        }
      else{
        displayToastMsg('Ride not exists', context);
      }
      if(theRideId == rideDetails!.ride_request_id)
        {

          tripReqRef.set("accepted");
          Methods.disableHomeTabLocationLiveUpdate();
          Navigator.push(context, MaterialPageRoute(builder: (context)=>NewRideScreen(rideDetails: rideDetails)));
        }
      else if(theRideId=="cancelled")
        {
          displayToastMsg('Ride has Been Cancelled', context);
        }
      else if(theRideId=="timeout")
      {
        displayToastMsg('Ride has timed out', context);
      }
      else
        {
          displayToastMsg('Ride not exists', context);

        }
    });
  }
}
