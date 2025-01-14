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
import 'package:provider/provider.dart';
import 'package:relaxi_driver/AllWidgets/collectCash.dart';
import 'package:relaxi_driver/AllWidgets/dialogueBox.dart';
import 'package:relaxi_driver/Assistants/mapKitAssistant.dart';
import 'package:relaxi_driver/Assistants/methods.dart';
import 'package:relaxi_driver/Assistants/utils.dart';
import 'package:relaxi_driver/Configurations/configMaps.dart';
import 'package:relaxi_driver/DataHandler/appData.dart';
import 'package:relaxi_driver/Models/directionDetails.dart';
import 'package:relaxi_driver/Models/drivers.dart';
import 'package:relaxi_driver/Models/history.dart';
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

class _NewRideScreenState extends State<NewRideScreen>  with TickerProviderStateMixin{
  ////needed for drawing polylines/////
  Set<Marker> markers={};
  Set<Circle> circles= {};
  List<LatLng>pLineCoordinates=[];
  Set<Polyline> polyLineSet= {};
  PolylinePoints polylinePoints=PolylinePoints();
  BitmapDescriptor? pickUpMarker;
  BitmapDescriptor? dropOffMarker;
  BitmapDescriptor? pickUpPersonMarker;
  void _addCustomMapMarker() async{
    pickUpMarker = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/pickUp.png');
    pickUpPersonMarker = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/rider.png');
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
  String destanceText="";
  double fareAmount=0.0;
  bool isRequestingDirection= false;
  bool is_tracking=false;
  bool isExpanding=false;
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
        child: Stack(
          alignment: Alignment.center,
          children: [
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
              await getPlacedDirection(current_LatLng, pickup_LatLng!, pickUp: true);
              getRideLiveLocUpdates();
            }
            ,
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedSize(
            duration: Duration(milliseconds: 300),
            vsync: this,
            child: Visibility(
              visible: status=="accepted"?false:true,
              child: Stack(
                alignment: Alignment.center,
                children: [

                  Padding(
                    padding: const EdgeInsets.only(right: 18.0,left:18.0,bottom: 20.0, top: 60.0),
                    child: Container(

                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: Colors.grey, blurRadius: 5.0)
                        ],
                        borderRadius: BorderRadius.circular(15.0)
                      ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top:10.0,
                          right: 20.0,
                          child: Visibility(
                            visible: (status=="onRide")?true:false,
                            child: TextButton(
                            child: Icon(CupertinoIcons.rectangle_expand_vertical, color: Colors.black,),
                            style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(grad1.withOpacity(0.5))
                            ),
                            onPressed: (){
                              setState(() {
                                isExpanding= !isExpanding;
                              });
                            },

                        ),
                          )),
                        Padding(
                          padding: const EdgeInsets.only(right: 18.0,left:18.0,bottom: 20.0, top: 50.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.rideDetails!.rider_name!, style: GoogleFonts.lobsterTwo(fontSize: 24.0,fontWeight:FontWeight.bold,color: Colors.black,),),
                              SizedBox(height:2.0),
                              Text(durationText,style: TextStyle(fontSize: 14.0,color: grey),),
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    VerticalDivider(width: 10.0,thickness:2.5,color: Colors.black,endIndent: 15.0,
                                    indent: 5.0,),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children:[
                                              Icon(CupertinoIcons.location_solid,color: grad1,size: 20.0,),SizedBox(width: 5.0),Text('From:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),), SizedBox(width: 5.0,),
                                              Expanded(child: Text(status=="tracking"?
                                              'your location':widget.rideDetails!.pickup_address!,overflow: TextOverflow.clip,))],),
                                          ),
                                          SizedBox(height: 10.0,),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children:[Icon(CupertinoIcons.location,color: grad1,size: 20.0,),SizedBox(width: 5.0),Text('To:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),), SizedBox(width: 5.0,),
                                              Expanded(child: Text(status=="tracking"?widget.rideDetails!.pickup_address!:
                                              widget.rideDetails!.dropoff_address!,overflow: TextOverflow.clip,))],),

                                          ),
                                          SizedBox(height: 10.0,)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: isExpanding,
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      VerticalDivider(width: 15.0,thickness:2.5,color: Colors.black,endIndent: 1.0,
                                        indent: 45.0,),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(height: 10.0,),
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text('Trip Fare',
                                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16.0),),
                                            ),
                                            Divider(thickness: 2.0,endIndent: _width-150,color: grad1,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('💲 total estimated fares:'),
                                                Text('${fareAmount.toString()} £', style: TextStyle(
                                                  color: grad1,
                                                  fontWeight: FontWeight.bold
                                                ),),
                                              ],
                                            ),
                                            SizedBox(height: 5.0,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('🚕 estimated distance:'),
                                                Text(destanceText, style: TextStyle(
                                                    color: grad1,
                                                    fontWeight: FontWeight.bold
                                                ),),

                                              ],
                                            ),
                                            SizedBox(height: 5.0,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('⏱️ estimated Duration:'),
                                                Text(durationText, style: TextStyle(
                                                    color: grad1,
                                                    fontWeight: FontWeight.bold
                                                ),),
                                            ],),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 0.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex:3,
                                      child: ElevatedButton(onPressed: ()async
                                      {
                                        String rideReqId= widget.rideDetails!.ride_request_id!;
                                        if(status=="tracking") {
                                            setState(() {
                                              is_tracking=false;
                                              is_arrived = true;
                                              btnTitle="Start Ride";
                                              //btnBGColor=Colors.purpleAccent;
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
                                          fixedSize: MaterialStateProperty.all(Size(_width,60))
                                        //elevation: MaterialStateProperty.all(is_arrived?0:null)
                                      ),
                                      ),
                                    ),
                                    SizedBox(width: 5.0,),
                                    Visibility(
                                      visible: (status!="tracking")?false:true,
                                      child: Expanded(
                                        flex: 1,
                                        child: ElevatedButton(onPressed: (){
                                          launch("tel://${widget.rideDetails!.rider_phone!}");
                                        },
                                            style: ButtonStyle(
                                                overlayColor: MaterialStateProperty.all(grad1.withOpacity(0.4)),
                                              fixedSize: MaterialStateProperty.all(Size(_width,60)),
                                              backgroundColor: MaterialStateProperty.all(Colors.black),

                                            )

                                            , child: Icon(CupertinoIcons.phone_solid,color: grad1,size: 30.0,)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                  Positioned(
                    top:20,
                    child:CircleAvatar(
                     // backgroundColor: Colors.black,
                      backgroundImage: AssetImage(widget.rideDetails!.rider_gender! == 'Female'? 'assets/female_rider.png':'assets/male_rider.png'),
                      radius: 40.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20.0,
          left: 0,
          right: 0,
          child: AnimatedSize(
          vsync: this,
          duration: Duration (milliseconds: 300),
          child: Visibility(
            visible: (status=="accepted")?true:false,
            child:Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8.0),
              child: ElevatedButton(onPressed: ()async
              {
                if(status=="accepted") {
                  setState(() {
                    is_tracking=true;
                    btnTitle = "Pick Up";
                    btnBGColor = grad1;
                    btnFGColor = Colors.black;
                    status = "tracking";
                  });
                }

              },

                 child: Text(
                      'Go to Pick Up',textScaleFactor: 1.4,
                  ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(btnBGColor),
                  foregroundColor:  MaterialStateProperty.all(btnFGColor),
                  fixedSize: MaterialStateProperty.all(Size(_width,60))
                  //elevation: MaterialStateProperty.all(is_arrived?0:null)
                ),
              ),
            ),
          ),
        ))

        ],),
      ),
    );
  }
  Future<void> getPlacedDirection(LatLng pickUpLatLng, LatLng dropOffLatLng, {bool showDialogue=true, bool pickUp=false}) async
  {
    if(showDialogue) {
      showDialog(context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              DialogueBox(message: "Getting Directions"));
    }
    var details = await Methods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);
    setState(() {
      fareAmount=Methods.calculateFares(details as DirectionDetails);
    });
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
        icon: pickUp?pickUpPersonMarker!:dropOffMarker!,
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
            destanceText= directionDetails.distanceText;
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

    setState(() {
      fareAmount=Methods.calculateFares(directionalDetails as DirectionDetails);
    });
    String rideReqId= widget.rideDetails!.ride_request_id!;
    newReqRef.child(rideReqId).child("fares").set(fareAmount.toString());
    newReqRef.child(rideReqId).child("status").set("ended");
    rideScreenStreamSubscribtion!.cancel();
    await showDialog(context: context,
        barrierDismissible: false,
        builder:(BuildContext context){
          return CollectCashDialogue(fareAmount: fareAmount,
          paymentMethod: widget.rideDetails!.payment_method,
          );
        });
    showDialog(context: context,
        barrierDismissible: false,
        builder:(BuildContext context){
          return DialogueBox(message: "Saving Trip",);
        });
    saveEarnings(fareAmount);
    saveTrip();
    updateProfile();
    if(Provider.of<AppData>(context,listen: false).tripCards.length==0)
      {await Methods.retrieveHistoryInfo(context);}
    else
      {
        await newReqRef.child(rideReqId).once().then((DataSnapshot snap) async{
          //print(snap.value.toString());
          if(snap.value!=null)
          {
            History history= History.fromSnapshot(snap);
            Provider.of<AppData>(context,listen: false).updateTripHistoryList(history);

          }

        });
      }
    Navigator.pop(context);
    Navigator.pop(context);
    Methods.enableHomeTabLocationLiveUpdate();

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

  void saveTrip()
  {
    driversRef.child(currentFirebaseUser!.uid).child("total_trips").once().then((DataSnapshot dataSnapshot) {
      if(dataSnapshot.value!=null)
      {
        int total_trips= 1+int.parse(dataSnapshot.value.toString());
        driversRef.child(currentFirebaseUser!.uid).child("total_trips").set(total_trips.toString());
      }
      else{
        driversRef.child(currentFirebaseUser!.uid).child("total_trips").set(1.toString());
      }

    });
  }

  void updateProfile() async{
    await driversRef.child(currentFirebaseUser!.uid).once().then((
        DataSnapshot dataSnapshot) {
      if(dataSnapshot.value!=null) {
        Drivers driver= Drivers.fromSnapshot(dataSnapshot);
        Provider.of<AppData>(context,listen: false).updateDriverDetails(driver);
      }
    });
  }
}
