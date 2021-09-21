import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:relaxi_driver/AllScreens/RegistrationScreen.dart';
import 'package:relaxi_driver/AllWidgets/collectCash.dart';
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
              padding: EdgeInsets.only(top: 100.0),
              initialCameraPosition:HomePage._kGooglePlex,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,

              onMapCreated: (GoogleMapController controller)
              {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                locatePosition();
              }
              ,
            ),
          ),
          Container(
            height:0.1*_height ,
            color: Colors.black38,
            child: Center(
              child: RollingSwitch.icon(
                circularColor: Colors.white,
                rollingInfoRight: const RollingIconInfo(
                  icon: Icons.close,
                  text: Text('online',style: TextStyle(color: Colors.white, fontSize: 16.0,fontStyle: FontStyle.italic,letterSpacing: 0.5)),
                  backgroundColor: Colors.lightGreen,
                  iconColor: Colors.black87
                ),
                rollingInfoLeft: const RollingIconInfo(
                  icon: Icons.check,
                  iconColor: Colors.lightGreen,
                  backgroundColor: Colors.black87,
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
            )
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