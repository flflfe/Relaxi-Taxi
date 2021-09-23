import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:relaxi_driver/AllScreens/RegistrationScreen.dart';
import 'package:relaxi_driver/AllWidgets/collectCash.dart';
import 'package:relaxi_driver/Assistants/utils.dart';
import 'package:relaxi_driver/Configurations/configMaps.dart';
import 'package:relaxi_driver/Models/drivers.dart';
import 'package:relaxi_driver/Notifications/pushNotificationService.dart';
import 'package:relaxi_driver/main.dart';
import 'package:switcher_button/switcher_button.dart';
import 'package:relaxi_driver/Assistants/methods.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:rolling_switch/rolling_switch.dart';
class HomePage extends StatefulWidget {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(29.9481264, 30.9176703),
    zoom: 14.4746,
  );

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseNotifcation? firebaseNotifcation;
  handleAsync() async {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser;
    driversRef.child(currentFirebaseUser!.uid).once().then((DataSnapshot dataSnapshot) {
     if(dataSnapshot.value!=null)
     {
       driversInfo= Drivers.fromSnapshot(dataSnapshot);
     }
    });
    await firebaseNotifcation?.initialize(context);
    String? token = await firebaseNotifcation?.getToken();

    print("Firebase token : $token");
  }


  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController? newGoogleMapController;


  var geoLocator = Geolocator();


  void locatePosition()async
  {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );
    currentPosition = position;
    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(
        target: latLatPosition, zoom: 14
    );
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    //String address = await Methods.searchCoordinateAddress(position, context);
    print("This is your Address :: ${position.longitude} & ${position.latitude}");
  }
  bool isOnline=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firebaseNotifcation = FirebaseNotifcation();
    handleAsync();
  }
  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return SafeArea(
      child: Center(
        child: Stack(
          children: [Positioned(
            child: GoogleMap(

              mapType: MapType.normal,

              initialCameraPosition:HomePage._kGooglePlex,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,

              onMapCreated: (GoogleMapController controller)
              {
                controller.setMapStyle(Utils.mapStyle);
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                locatePosition();
              }
              ,
            ),
          ),
          Column(
            //mainAxisSize: MainAxisSize.min,
            //mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0,left: 8.0),
                child: RollingSwitch.icon(

                  circularColor: Colors.white,
                  rollingInfoRight: const RollingIconInfo(
                    icon: Icons.close,
                    text: Text('online',style: TextStyle(color: Colors.white, fontSize: 16.0,fontStyle: FontStyle.italic,letterSpacing: 0.5)),
                    backgroundColor: Color(0xffFBDF00),
                    iconColor: Colors.grey
                  ),
                  rollingInfoLeft: const RollingIconInfo(
                    icon: Icons.check,
                    iconColor: Color(0xffFBDF00),
                    backgroundColor: Colors.grey,
                    text: Text('offline', style: TextStyle(color: Colors.white, fontSize: 16.0,fontStyle: FontStyle.italic,letterSpacing: 0.5),),
                  ),
                  onChanged: (bool state ) {
                    if(state) {
                      setState(() {
                        isOnline=true;
                      });

                      makeDriverOnlineNow();
                      getLiveLocationUpdates();
                      displayToastMsg("you are online now!", context);
                    }
                    else
                      {
                        setState(() {
                          isOnline=false;
                        });
                        makeDriverOfflineNow();
                        displayToastMsg("you're offline now", context);

                      }
                      },
                ),
              ),
              IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      color: Colors.white70,
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          VerticalDivider(
                            //width: 5.0,
                            endIndent: 4,
                            indent: 4,
                            color: grad1,
                            thickness: 4.0,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(isOnline?'You are online now 🚕':'You are offline now 😴', style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,

                                    ),
                                    ),
                                  ),
                                  SizedBox(height: 5.0,),
                                  Expanded(
                                    child: Text(isOnline?'your location is now visible to nearby Relaxi users and you can receive ride request.':
                                    'your location isn\'t visible to other users and you can\'t receive ride requests.',
                                      overflow: TextOverflow.clip, style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey[700],

                                    ),

                                    ),
                                  ),
                                  SizedBox(height: 10.0,),


                                ],
                              ),
                            ),
                          )
                        ],
                      )

                  ),
                ),
              )
            ],
          )
          ],

        ),
      ),
    );
  }

  void makeDriverOnlineNow()async
  {

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );
    currentPosition = position;
      Geofire.initialize("availableDrivers");
      Geofire.setLocation(currentFirebaseUser!.uid, currentPosition!.latitude, currentPosition!.longitude);
      tripReqRef.set("searching");
      tripReqRef.onValue.listen((event) {

      });
  }

  void getLiveLocationUpdates()
  {
    homeTabStreamSubscribtion = Geolocator.getPositionStream().listen((Position position) {
      currentPosition= position;
      if(isOnline){Geofire.setLocation(currentFirebaseUser!.uid, position.latitude, position.longitude);}
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOfflineNow()
  {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    tripReqRef.onDisconnect();
    tripReqRef.remove();

  }
}