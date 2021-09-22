import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:relaxi_driver/AllWidgets/collectCash.dart';
import 'package:relaxi_driver/AllWidgets/dialogueBox.dart';
import 'package:relaxi_driver/Assistants/mapKitAssistant.dart';
import 'package:relaxi_driver/Assistants/methods.dart';
import 'package:relaxi_driver/Assistants/utils.dart';
import 'package:relaxi_driver/Configurations/configMaps.dart';
import 'package:relaxi_driver/Models/directionDetails.dart';
import 'package:relaxi_driver/Models/rideDetails.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:relaxi_driver/main.dart';
import 'package:url_launcher/url_launcher.dart';
class NewRideScreen extends StatefulWidget {
  final RideDetails? rideDetails;
  const NewRideScreen({Key? key,this.rideDetails}) : super(key: key);
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(29.9481264, 30.9176703),
    zoom: 14.4746,
  );
  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  ////needed for drawing polylines/////
  Set<Marker> markers={};
  Set<Circle> circles= {};
  List<LatLng>pLineCoordinates=[];
  Set<Polyline> polyLineSet= {};
  PolylinePoints polylinePoints=PolylinePoints();
  BitmapDescriptor? pickUpMarker;
  BitmapDescriptor? dropOffMarker;
  void _addCustomMapMarker() async{
    pickUpMarker = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/pickUp.png');
    dropOffMarker= await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/dropOff.png');
  }
  /////////////////////////////////////
  ////needed for drawing map/////
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newRideGoogleMapController;
  /////////////////////////////////////
  /////updating the driver location live//////
  var geoLocator= Geolocator();
  var locationOptions= LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
  BitmapDescriptor? animatingMarkerIcon;
  Position? myPosition;
  void createCarIconMarkers(){

    if(animatingMarkerIcon==null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
          context, size: Size(1, 1));
      BitmapDescriptor.fromAssetImage(imageConfiguration, 'assets/car_mark2.png')
          .then((value) {
        animatingMarkerIcon = value;
      });
    }

  }
  void getRideLiveLocUpdates() {
    LatLng oldPos= LatLng(0,0);
    rideScreenStreamSubscribtion = Geolocator.getPositionStream().listen((Position position) async{
      currentPosition= position;
      myPosition =position;
      LatLng mPosition =LatLng(position.latitude, position.longitude);
      var rot= MapKitAssistant.getMarkerRotation(oldPos.latitude, oldPos.longitude, mPosition.latitude,  mPosition.longitude);
      Marker animatingMarker = Marker(
        markerId: MarkerId('animating'),
        position: mPosition,
        icon:animatingMarkerIcon!,
        rotation: rot!,
        infoWindow: InfoWindow(
          title: "Current Location"
        )

      );
      if(is_tracking) {
        setState(() {
          CameraPosition cameraPosition = new CameraPosition(
              target: mPosition, zoom: 15.0);
          newRideGoogleMapController!.animateCamera(
              CameraUpdate.newCameraPosition(cameraPosition));
          markers.removeWhere((marker) => marker.markerId.value == "animating");
          markers.add(animatingMarker);
        });
      }
      oldPos= mPosition;
      updateRideDetails();
      String rideReqId= widget.rideDetails!.ride_request_id!;

      Map driverLoc={
        "latitude":currentPosition!.latitude.toString(),
        "longitude":currentPosition!.longitude.toString()
      };
      newReqRef.child(rideReqId).child("driver_location").set(driverLoc);
    });

  }
  /////////////////////////////////////
  ////needed for updating ride details/////
  String status="accepted";
  String durationText ="";
  bool isRequestingDirection= false;
  bool is_tracking=false;
  /////////////////////////////////////////
  ////needed for updating ride status/////
  bool is_arrived=false;
  String btnTitle="Start Tracking";
  Color btnBGColor=Colors.black;
  Color btnFGColor=grad1;
  Timer? timer;
  int durationCount=0;
  /////////////////////////////////////////

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _addCustomMapMarker();
    acceptRideReq();
  }
  @override
  Widget build(BuildContext context) {
    createCarIconMarkers();
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
        GoogleMap(

            mapType: MapType.normal,
            padding: EdgeInsets.only(bottom: _height/3-40),
            initialCameraPosition:NewRideScreen._kGooglePlex,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            markers: markers,
            circles: circles,
            polylines: polyLineSet,
            onMapCreated: (GoogleMapController controller) async
            {
              controller.setMapStyle(Utils.mapStyle);
              _controllerGoogleMap.complete(controller);
              newRideGoogleMapController = controller;
              var current_LatLng= LatLng(currentPosition!.latitude,currentPosition!.longitude);
              var pickup_LatLng = widget.rideDetails!.pickUp;
              await getPlacedDirection(current_LatLng, pickup_LatLng!);
              getRideLiveLocUpdates();
            }
            ,
          ),
        Positioned(
          bottom: 0.0,
          child: Container(
            height: _height/3,
            width: _width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white,
                    Colors.white.withOpacity(0)
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter
              ),
            ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0,horizontal: 18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(
                  child: Column(
                    children: [
                      //SizedBox(height: 20.0,),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(widget.rideDetails!.rider_name!, style: GoogleFonts.comfortaa(fontSize: 18.0,fontWeight:FontWeight.bold,color: Colors.black,),),
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextButton(onPressed: (){
                                    launch("tel://${widget.rideDetails!.rider_phone!}");
                                  },
                                  style: ButtonStyle(
                                    overlayColor: MaterialStateProperty.all(grad1.withOpacity(0.4))
                                  )

                                  , child: Text(widget.rideDetails!.rider_phone!,
                                          style: GoogleFonts.ubuntuMono(
                                              fontSize: 16.0,
                                              fontWeight:FontWeight.bold,
                                              color: Colors.black,
                                              decoration: TextDecoration.underline
                                          ))),
                                  SizedBox(width: 0.0,),
                                  Icon(CupertinoIcons.device_phone_portrait,color: Colors.black,size: 20.0,),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height:2.0),
                      Expanded(child: Text(durationText,style: TextStyle(fontSize: 14.0,color: grey),)),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(children:[Icon(CupertinoIcons.location_solid,color: grad1,size: 20.0,),SizedBox(width: 5.0),Text('From:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),), SizedBox(width: 5.0,),
                          Expanded(child: Text(widget.rideDetails!.pickup_address!,overflow: TextOverflow.ellipsis,))],),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(children:[Icon(CupertinoIcons.location,color: grad1,size: 20.0,),SizedBox(width: 5.0),Text('To:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),), SizedBox(width: 5.0,),
                          Expanded(child: Text(widget.rideDetails!.dropoff_address!,overflow: TextOverflow.ellipsis,))],),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20.0),
                    child: ElevatedButton(onPressed: ()async
                    {
                      String rideReqId= widget.rideDetails!.ride_request_id!;
                      if(status=="accepted") {
                        setState(() {
                          is_tracking=true;
                          btnTitle = "Arrive";
                          btnBGColor = grad1;
                          btnFGColor = Colors.black;
                          status = "tracking";
                        });
                      }
                        else if(status=="tracking") {
                          setState(() {
                            is_tracking=false;
                            is_arrived = true;
                            btnTitle="Start Ride";
                            btnBGColor=Colors.purpleAccent;
                            btnFGColor= Colors.white;
                            status= "arrived";
                          });

                          newReqRef.child(rideReqId).child("status").set(status);
                          showDialog(context: context,
                              barrierDismissible: false,
                              builder:(BuildContext context){
                                return DialogueBox(message: "Getting drop off directions",);
                              });
                          await getPlacedDirection(widget.rideDetails!.pickUp!, widget.rideDetails!.dropOff!);
                          Navigator.pop(context);
                        }
                        else if(status=="arrived") {

                          setState(() {
                            is_tracking=true;
                            is_arrived = true;
                            btnTitle="End Ride";
                            btnBGColor=Colors.redAccent;
                            btnFGColor= Colors.black;
                            status= "onRide";
                          });
                          newReqRef.child(rideReqId).child("status").set(status);
                          initTimer();

                        }
                        else if(status=="onRide") {
                          is_tracking=false;
                          endTheTrip();

                        }

                    }, child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          btnTitle
                        ),
                        Icon(CupertinoIcons.car_detailed)
                      ],
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(btnBGColor),
                      foregroundColor:  MaterialStateProperty.all(btnFGColor),
                      //elevation: MaterialStateProperty.all(is_arrived?0:null)
                    ),
                    ),
                  ),
                ),

              ],
            ),
          ),
          ),
        )
        ],),
      ),
    );
  }
  Future<void> getPlacedDirection(LatLng pickUpLatLng, LatLng dropOffLatLng, {bool showDialogue=true}) async
  {
    if(showDialogue) {
      showDialog(context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              DialogueBox(message: "Getting Directions"));
    }
    var details = await Methods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);

    if(showDialogue) {Navigator.pop(context);}
    /*print("This Is Encoded Points :: ");
    print(details!.encodedPoints);*/

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylines =polylinePoints.decodePolyline(details!.encodedPoints);
    pLineCoordinates.clear();
    if(decodedPolylines.isNotEmpty)
    {
      decodedPolylines.forEach((PointLatLng pointLatLng) {
        pLineCoordinates.add(LatLng(pointLatLng.latitude,pointLatLng.longitude));

      });
    }
    polyLineSet.clear();
    setState(() {
      Polyline polyline=Polyline(
          color: Colors.black,
          polylineId: PolylineId("polylineID"),
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true

      );
      polyLineSet.add(polyline);
    });
    LatLngBounds latlngBounds;
    if(pickUpLatLng.latitude>dropOffLatLng.latitude&& pickUpLatLng.longitude>dropOffLatLng.longitude)
    {
      latlngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);

    }
    else if(pickUpLatLng.latitude>dropOffLatLng.latitude)
    {
      latlngBounds = LatLngBounds(southwest: LatLng(dropOffLatLng.latitude,pickUpLatLng.longitude), northeast: LatLng(pickUpLatLng.latitude,dropOffLatLng.longitude));
    }
    else if(pickUpLatLng.longitude>dropOffLatLng.longitude)
    {
      latlngBounds = LatLngBounds(southwest: LatLng(pickUpLatLng.latitude,dropOffLatLng.longitude), northeast: LatLng(dropOffLatLng.latitude,pickUpLatLng.longitude));
    }
    else{
      latlngBounds = LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);

    }
    if(showDialogue) {
      newRideGoogleMapController!.animateCamera(
          CameraUpdate.newLatLngBounds(latlngBounds, 100));
    }

    if (showDialogue) {
      Marker pickUpMarkerDefault = Marker(
        icon: pickUpMarker!,
        markerId: MarkerId("pickUpMark"),

        position: pickUpLatLng,


      );

      Marker dropOffMarkerDefault = Marker(
        icon: dropOffMarker!,
        markerId: MarkerId("dropOffMark"),

        position: dropOffLatLng,

      );
      setState(() {
        markers.add(pickUpMarkerDefault);
        markers.add(dropOffMarkerDefault);
      });
      Circle pickUpCircle = Circle(
          circleId: CircleId("pickUpCircle"),
          fillColor:grad1 ,
          strokeColor:Colors.black ,
          strokeWidth: 1,
          radius: 2.0,
          center: pickUpLatLng
      );

      Circle dropOffCircle = Circle(
          circleId: CircleId("dropOffCircle"),
          fillColor:grad1 ,
          strokeColor:Colors.black ,
          strokeWidth: 1,
          radius: 2.0,
          center: dropOffLatLng
      );

      setState(() {
        circles.add(pickUpCircle);
        circles.add(dropOffCircle);
      });
    }

  }
  void acceptRideReq()
  {
    String rideReqId= widget.rideDetails!.ride_request_id!;
    newReqRef.child(rideReqId).child("status").set("accepted");
    newReqRef.child(rideReqId).child("driver_name").set(driversInfo!.name);
    newReqRef.child(rideReqId).child("driver_phone").set(driversInfo!.phone);
    newReqRef.child(rideReqId).child("driver_id").set(driversInfo!.id);
    newReqRef.child(rideReqId).child("car_details").set("${driversInfo!.car_model} - ${driversInfo!.car_color} - ${driversInfo!.car_number}");

    Map driverLoc={
      "latitude":currentPosition!.latitude.toString(),
      "longitude":currentPosition!.longitude.toString()
    };
    newReqRef.child(rideReqId).child("driver_location").set(driverLoc);

    driversRef.child(currentFirebaseUser!.uid).child("history").child(rideReqId).set(true);
  }
  ///to display rider info
  void updateRideDetails() async
  {
    if (isRequestingDirection==false) {
      isRequestingDirection = true;
      if(myPosition==null)
        {
          return;
        }
      var posLatLng = LatLng(
        myPosition!.latitude,myPosition!.longitude
      );
      LatLng? destinationLatLng;
      if(status=="accepted"||status=="tracking")
        {
          destinationLatLng=widget.rideDetails!.pickUp!;
        }
      else
        {
          destinationLatLng=widget.rideDetails!.dropOff!;
        }
      if(is_tracking){await getPlacedDirection(posLatLng, destinationLatLng,showDialogue: false);}

      var directionDetails = await Methods.obtainPlaceDirectionDetails(posLatLng, destinationLatLng);
      if(directionDetails!=null)
        {
          setState(() {
            durationText= directionDetails.durationText;
          });
        }
      isRequestingDirection = false;

    }
  }
  void initTimer()
  {
    const interval= Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCount+=1;
    });
  }
  void endTheTrip() async
  {
    timer!.cancel();
    showDialog(context: context,
        barrierDismissible: false,
        builder:(BuildContext context){
          return DialogueBox(message: "Ending Trip",);
        });
    var currentLatLng= LatLng(myPosition!.latitude,myPosition!.longitude);
    var directionalDetails= await Methods.obtainPlaceDirectionDetails(widget.rideDetails!.pickUp!, currentLatLng);
    Navigator.pop(context);

    double fareAmount=Methods.calculateFares(directionalDetails as DirectionDetails);
    String rideReqId= widget.rideDetails!.ride_request_id!;
    newReqRef.child(rideReqId).child("fares").set(fareAmount.toString());
    newReqRef.child(rideReqId).child("status").set("ended");
    rideScreenStreamSubscribtion!.cancel();
    showDialog(context: context,
        barrierDismissible: false,
        builder:(BuildContext context){
          return CollectCashDialogue(fareAmount: fareAmount,
          paymentMethod: widget.rideDetails!.payment_method,
          );
        });
    saveEarnings(fareAmount);


  }
  void saveEarnings(double fareAmount)
  {
    driversRef.child(currentFirebaseUser!.uid).child("earnings").once().then((DataSnapshot dataSnapshot) {
      if(dataSnapshot.value!=null)
        {
          double total_earnings= fareAmount+double.parse(dataSnapshot.value.toString());
          driversRef.child(currentFirebaseUser!.uid).child("earnings").set(total_earnings.toStringAsFixed(2));
        }
      else{
        driversRef.child(currentFirebaseUser!.uid).child("earnings").set(fareAmount.toStringAsFixed(2));
      }

    });
  }
}
