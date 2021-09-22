import 'dart:async';
import 'package:flutter_app/AllScreens/loginScreen.dart';
import 'package:flutter_app/AllScreens/searchScreen.dart';
import 'package:flutter_app/AllWidgets/dialogueBox.dart';
import 'package:flutter_app/AllWidgets/noDriverDialogue.dart';
import 'package:flutter_app/Assistants/geofireAssistant.dart';
import 'package:flutter_app/Assistants/mapKitAssistant.dart';
import 'package:flutter_app/Assistants/utils.dart';
import 'package:flutter_app/Configurations/configMaps.dart';
import 'package:flutter_app/DataHandler/appData.dart';
import 'package:flutter_app/Models/directionDetails.dart';
import 'package:flutter_app/Models/nearByAvailableDrivers.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/AllWidgets/buttons.dart';
import 'package:flutter_app/Assistants/methods.dart';
import 'package:flutter_app/constants/all_cons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const String id_screen="main";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(29.9481264, 30.9176703),
    zoom: 14.4746,
  );
  List<LatLng>pLineCoordinates=[];
  Set<Polyline> polyLineSet= {};
  Set<Marker> markers={};
  Set<Circle> circles= {};
  BitmapDescriptor? pickUpMarker;
  BitmapDescriptor? dropOffMarker;
  BitmapDescriptor? nearByIcon;
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  late Position currentPosition;
  var geoLocator = Geolocator();
  double rideDetailsContainer=0.0;
  double searchContainerHeight = 0.3;
  double bottomPaddingofMap = 0.3;
  double requestDriveHeight = 0.0;
  double driverDetailsHeight= 0.0;
  bool SearchIsSwitched=false;
  bool driversAvailableKeysLoaded = false;
  LatLng oldPos= LatLng(0,0);
  Marker? dropOffMark;
  Marker? pickUpMark;
  late DirectionDetails tripDirectionDetails= DirectionDetails(0, 0, "", "", "");
  void _addCustomMapMarker() async
  {
    pickUpMarker = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/pickUp.png');
    dropOffMarker= await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/dropOff.png');
  }
  void locatePosition()async
  {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    currentPosition = position;
    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(
      target: latLatPosition, zoom: 16
    );
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String address = await Methods.searchCoordinateAddress(position, context);
    print("This is your Address :: ${position.longitude} & ${position.latitude}");

    initGeoFireListener();

  }
  void displayDetailsContainer() async
  {
      await getPlacedDirection();
      setState(() {
        requestDriveHeight=0;
        searchContainerHeight= 0;
        rideDetailsContainer=0.35;
        driverDetailsHeight = 0.0;
        bottomPaddingofMap= 0.3;
        SearchIsSwitched= true;

      });
  }
  void displaySearchContainer()
  {
    locatePosition();
    setState(() {
      rideDetailsContainer=0;
      searchContainerHeight= 0.3;
      driverDetailsHeight = 0.0;
      bottomPaddingofMap= 0.3;
      requestDriveHeight= 0;
      SearchIsSwitched= false;
      markers.clear();
      circles.clear();
      polyLineSet.clear();
      pLineCoordinates.clear();
    });

  }
  void displayDriverInfoContainer()
  {

    setState(() {
      rideDetailsContainer=0;
      searchContainerHeight= 0;
      driverDetailsHeight = 0.4;
      bottomPaddingofMap= 0.4;
      requestDriveHeight= 0;
      SearchIsSwitched= true;
      /*markers.clear();
      circles.clear();
      polyLineSet.clear();
      pLineCoordinates.clear();*/
    });

  }
  bool isEconomy=true;
  bool isLuxury=false;
  bool isTaxi=false;
  double cash=0;
  DatabaseReference? rideRequestReference;
  List<NearByAvailableDrivers> availableDrivers=[];
  String state = "normal";
  StreamSubscription<Event>? rideStreamSubscription;
  bool isReqPosDetails= false;
  @override
  void initState()
  {
    // TODO: implement initState
    super.initState();
    _addCustomMapMarker();

    Methods.getCurrentOnlineUserInfo();
  }
  void saveRideRequest()
  {
    rideRequestReference= FirebaseDatabase.instance.reference().child("Ride Requests").push();
    var pickUp= Provider.of<AppData>(context,listen: false).pickUpLocation;
    var dropOff= Provider.of<AppData>(context,listen: false).dropOffLocation;

    Map pickUpLocMap =
        {
          "latitude":pickUp.latitude,
          "longitude":pickUp.longitude
        };
    Map dropOffLocMap =
    {
      "latitude":dropOff.latitude,
      "longitude":dropOff.longitude
    };

    Map rideInfoMap = {
      "driver_id":"waiting",
      "payment_method":"cash",
      "pickUp":pickUpLocMap,
      "dropOff":dropOffLocMap,
      "created_at":DateTime.now().toString(),
      "rider_name": userCurrentInfo.name,
      "rider_phone":userCurrentInfo.phone,
      "pickup_address":pickUp.placeName,
      "dropoff_address":dropOff.placeName
    };
    rideRequestReference!.set(rideInfoMap);
    rideStreamSubscription = rideRequestReference!.onValue.listen((event) {
      if(event.snapshot.value ==null)
        {
          return;
        }
      if(event.snapshot.value["status"]!=null)
        {
          if(statusRide != event.snapshot.value["status"].toString()) {
            setState(() {
              statusRide = event.snapshot.value["status"].toString();
              if (statusRide == "accepted") {
                setState(() {
                  pickUpMark = Marker(
                      icon: dropOffMarker!,
                      markerId: MarkerId("pickup"),
                      infoWindow: InfoWindow(title: Provider
                          .of<AppData>(context, listen: false)
                          .dropOffLocation
                          .placeName, snippet: "drop off location"),
                      position: LatLng(pickUp.latitude, pickUp.longitude)

                  );
                  markers.add(pickUpMark!);
                });
              }
              else if (statusRide == "onRide") {
                setState(() {
                  dropOffMark = Marker(
                      icon: dropOffMarker!,
                      markerId: MarkerId("dropoff"),
                      infoWindow: InfoWindow(title: Provider
                          .of<AppData>(context, listen: false)
                          .dropOffLocation
                          .placeName, snippet: "drop off location"),
                      position: LatLng(dropOff.latitude, dropOff.longitude)

                  );
                  markers.add(dropOffMark!);
                });
              }
              else if (statusRide == "arrived") {
                deleteGeoFireMarkers('pickup');
              }
            });
          }

        }
      if(event.snapshot.value["car_details"]!=null)
      {
        setState(() {
          driverCarDetails = event.snapshot.value["car_details"].toString();
        });
      }
      if(event.snapshot.value["driver_name"]!=null)
      {
        setState(() {
          driverName = event.snapshot.value["driver_name"].toString();
        });
      }
      if(event.snapshot.value["driver_phone"]!=null)
      {
        setState(() {
          driverPhone = event.snapshot.value["driver_phone"].toString();
        });
      }
      if(event.snapshot.value["driver_location"]!=null)
      {
        double driverLat = double.parse(event.snapshot.value["driver_location"]["latitude"].toString());
        double driverLng = double.parse(event.snapshot.value["driver_location"]["longitude"].toString());
        LatLng driverCurrentLatLng= LatLng(driverLat, driverLng);
        if(statusRide=="accepted" || statusRide=="tracking")
          {
            ////real time driver tracking
            updateDriverArrivalTimeToPickUp(driverCurrentLatLng);
            setState(() {
              oldPos = driverCurrentLatLng;
            });
          }
        else if(statusRide=="onRide")
          {
            updateDriverArrivalTimeToDropOff(driverCurrentLatLng);
            setState(() {
              oldPos = driverCurrentLatLng;
            });
          }
        else if(statusRide=="arrived")
          {
            setState(() {
              driverArrivalStatus = "Driver Has Arrived";
            });
          }
      }
      if(statusRide =="accepted")
        {
          displayDriverInfoContainer();
          //Geofire.stopListener();
        }


    });

  }
  void updateDriverArrivalTimeToPickUp(LatLng currentDriverLatLng) async
  {
    if (isReqPosDetails==false) {
      //not to spare requests
      isReqPosDetails = true;
      //
      var userPosLatLng= LatLng(currentPosition.latitude, currentPosition.longitude);
      DirectionDetails? details=await Methods.obtainPlaceDirectionDetails(currentDriverLatLng, userPosLatLng);
      if(details == null)
        {
          return;
        }
      setState(() {
        driverArrivalStatus="Driver is Coming in - "+details.durationText;
      });
      //get the encoded points and draw the polylines
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPolylines =polylinePoints.decodePolyline(details.encodedPoints);
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
        deleteGeoFireMarkers('car');
        var rot= MapKitAssistant.getMarkerRotation(oldPos.latitude, oldPos.longitude, currentDriverLatLng.latitude,  currentDriverLatLng.longitude);
        Marker mark=Marker(
            markerId: MarkerId('$driverName car'),
            icon: nearByIcon!,
            position: currentDriverLatLng,
            rotation: rot!

        );
        markers.add(mark);
      });
      isReqPosDetails = false;
    }


  }
  void updateDriverArrivalTimeToDropOff(LatLng currentDriverLatLng) async
  {
    if (isReqPosDetails==false) {
      //not to spare requests
      isReqPosDetails = true;
      //

      var userDropOffPosLatLng= LatLng(Provider.of<AppData>(context, listen: false).dropOffLocation.latitude,
          Provider.of<AppData>(context, listen: false).dropOffLocation.longitude);
      DirectionDetails? details=await Methods.obtainPlaceDirectionDetails(currentDriverLatLng, userDropOffPosLatLng);
      if(details == null)
      {
        return;
      }
      setState(() {
        driverArrivalStatus="You 'll arrive in - "+details.durationText;
      });
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPolylines =polylinePoints.decodePolyline(details.encodedPoints);
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
        deleteGeoFireMarkers('car');
        var rot= MapKitAssistant.getMarkerRotation(oldPos.latitude, oldPos.longitude, currentDriverLatLng.latitude,  currentDriverLatLng.longitude);

        Marker mark=Marker(
            markerId: MarkerId('$driverName car'),
            icon: nearByIcon!,
            position: currentDriverLatLng,
            rotation:rot!

        );
        markers.add(mark);
      });
      isReqPosDetails = false;
    }


  }
  void deleteGeoFireMarkers(String id)
  {
    setState(() {
      markers.removeWhere((element) => element.markerId.value.contains(id));
    });
  }
  void cancelRideRequest()
  {
    rideRequestReference!.remove();
    setState(() {
      state = "cancelled";
    });
  }
  @override
  Widget build(BuildContext context)
  {
    createCarIconMarkers();
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      drawer: SafeArea(
        child: Container(
          color: Colors.white,
          width: 0.7*_width,
          child: Drawer(
            child: Stack(
              children:[ ListView(
                children: [
                  //Header
                  Container(

                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [grad1, grad1,grad2],end:Alignment.topCenter,begin:Alignment.bottomCenter),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(0.25*_width),bottomRight: Radius.circular(0.25*_width)),
                        boxShadow: <BoxShadow>[BoxShadow(color: grey.withOpacity(0.5), blurRadius: 3, spreadRadius: 0, offset: Offset(1.0,0)),]),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.transparent,
                                foregroundImage: NetworkImage(
                                    "https://picsum.photos/200" //generate random images
                                ),
                              ),
                            ),
                            Text(
                              userCurrentInfo.name,
                              style: GoogleFonts.pacifico(
                                  fontSize: 24,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white),
                            ),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(Icons.phone_android,color: custom_grey,size: 15.0,),
                               SizedBox(width: 2.0,),
                               Text(userCurrentInfo.phone,
                               style: TextStyle(color: custom_grey),)],)
                          ],

                        ),
                      )
                    ,
                  ),
                  SizedBox(height: 20.0,),
                  //list
                  Divider(height: 2),
                  ListTile(
                    onTap: (){},
                    onLongPress: (){},
                    leading: Icon(Icons.history, color: grad1,),
                    title: Text('My Trips',style: GoogleFonts.overlock(
                      fontSize: 18,
                        color: custom_grey
                    ),),

                  ),
                  Divider(height: 2),
                  ListTile(
                    onTap: (){},
                    onLongPress: (){},
                    leading: Icon(Icons.person_outline, color: grad1,),
                    title: Text('My Profile',style: GoogleFonts.overlock(
                        fontSize: 18,
                        color: custom_grey
                    ),),

                  ),
                  Divider(height: 2,),
                  ListTile(
                    onTap: (){},
                    onLongPress: (){},
                    leading: Icon(Icons.info_outlined, color: grad1,),
                    title: Text('About',style: GoogleFonts.overlock(
                        fontSize: 18,
                        color: custom_grey
                    ),),

                  ),
                  Divider(height: 2),
                  ListTile(

                    onTap: (){
                      FirebaseAuth.instance.signOut();
                      Navigator.pushNamedAndRemoveUntil(context, LoginScreen.id_screen, (route) => false);
                    },
                    onLongPress: (){},
                    leading: Icon(Icons.logout, color: grad1,),
                    title: Text('Sign Out',style: GoogleFonts.overlock(
                        fontSize: 18,
                      color: custom_grey
                    ),),

                  ),
                  Divider(height: 2),
                  

                ],
              ),
                Positioned(
                bottom: 20.0,
                right: (0.7*_width)/2-0.5*0.35*_width,
                    child: Image.asset('assets/logo_title.png',width: 0.35*_width,))
              ]
            ),
          ),
        ),
      ),
      body:  SafeArea(
        child: Stack(
          children: [
            // map ui
            Positioned(
              child: GoogleMap(
                padding: EdgeInsets.only(bottom: bottomPaddingofMap*_height),
                mapType: MapType.normal,

                initialCameraPosition:_kGooglePlex,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                markers: markers,
                circles: circles,
                polylines: polyLineSet,
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
            // button for drawer
            Positioned(child:MapButton(heroTag:"topBtn",icon: SearchIsSwitched?Icon(Icons.close,color: Colors.red,):Icon(Icons.menu,color: grad1,),
                onPressed: (){
              if(SearchIsSwitched)
                {
                  displaySearchContainer();
                }
              else {scaffoldKey.currentState!.openDrawer();}}),
              top:30, left: 20,),
            // search ui
            Positioned(
                bottom: 0,
                child: AnimatedSize(
                  vsync: this,
                  duration: Duration(milliseconds: 160),
                  curve: Curves.easeInOut,
                  child: Container(
                    height: searchContainerHeight*_height,
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
                    child: Column(
                      children: [
                        //SizedBox(height:(((320/xd_height)*_height)/2)-80),
                        Icons_Map(width: _width,locate: locatePosition),
                        SizedBox(height: 10.0,),

                        Hi_There(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("From:  ", style: TextStyle(fontWeight: FontWeight.bold,color: grad1),),
                            Text(Provider.of<AppData>(context).pickUpLocation != null ?Provider.of<AppData>(context).pickUpLocation.placeName:" " ,
                            overflow: TextOverflow.fade,
                            style: GoogleFonts.overlock(),),
                          ],
                        ),
                        Divider(indent: 50.0,endIndent: 50.0,),
    GestureDetector(
    onTap: () async{

    var res = await Navigator.push(context,
    MaterialPageRoute(builder: (context)=>SearchScreen()));
    if (res== "obtainDirection")
    {
     displayDetailsContainer();
    }
    },
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Container(
    decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(
    color: yellow,
    width: 1,
    ),
    borderRadius: BorderRadius.circular(50)
    ),
    child: Padding(
    padding: const EdgeInsets.only(left: 5.0,right:20.0,),
    child: TextField(

    cursorColor: grad1,
    decoration: InputDecoration(
    prefixIcon: Icon(Icons.circle,size: 10.0,color: yellow,),
    prefixIconConstraints: BoxConstraints.tight(Size(25,25)),
    labelStyle: TextStyle(
    color: grey.withOpacity(0.8),

    ),
    labelText: 'Where To?',
    border: InputBorder.none,
    ),
    enabled: false,

    ),
    ),
    ),
    ),
    ),
                      ],
                    ),
                  ),
                )),
            // Ride Details ui
            Positioned(
                bottom: 0,
                child: AnimatedSize(
                  vsync: this,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.bounceIn,
                  child: Container(
                    height: rideDetailsContainer*_height,
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
                    child: Column(
                      children: [
                        Expanded(
                          flex:6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: ((90/xd_width)*_width),
                                  height: ((90/xd_height)*_height),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(color: (isEconomy==true)?grad1:Colors.grey.shade400, width: (isEconomy==true)?2.5:1.0)
                                  ),
                                  child: TextButton(
                                    style: ButtonStyle(

                                    ),
                                    onPressed: (){
                                      setState(() {
                                        isEconomy=true;
                                        isLuxury=false;
                                        isTaxi=false;
                                      });
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(flex:2,child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Image.asset('assets/economyCar.png',),
                                        )),
                                        Expanded(child: Text('Economy',style: GoogleFonts.openSans(fontSize:12.0,
                                            fontWeight: (isEconomy==true)?FontWeight.bold:FontWeight.normal,
                                            color: (isEconomy==true)?grad1:grey),))
                                      ],
                                    ),
                                  ),

                                ),
                              ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: ((90/xd_width)*_width),
                                    height: ((90/xd_height)*_height),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20.0),
                                        border: Border.all(color: (isLuxury==true)?grad1:Colors.grey.shade400, width: (isLuxury==true)?2.5:1.0)
                                    ),
                                    child: TextButton(
                                      style: ButtonStyle(

                                      ),
                                      onPressed: (){
                                        setState(() {
                                          isEconomy=false;
                                          isLuxury=true;
                                          isTaxi=false;
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(flex:2,child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Image.asset('assets/luxuryCar.png',),
                                          )),
                                          Expanded(child: Text('Luxury',style: GoogleFonts.openSans(fontSize:12.0,
                                              fontWeight: (isLuxury==true)?FontWeight.bold:FontWeight.normal,
                                              color: (isLuxury==true)?grad1:grey)))
                                        ],
                                      ),
                                    ),

                                  ),
                                ),
                                Padding(padding: EdgeInsets.all(8.0),
                                child: Container(
                                  width: ((90/xd_width)*_width),
                                  height: ((90/xd_height)*_height),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(color: (isTaxi==true)?grad1:Colors.grey.shade400, width: (isTaxi==true)?2.5:1.0)
                                  ),
                                  child: TextButton(
                                    style: ButtonStyle(

                                    ),
                                    onPressed: (){
                                      setState(() {
                                        isEconomy=false;
                                        isLuxury=false;
                                        isTaxi=true;
                                      });
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(flex:2,child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Image.asset('assets/taxiCar.png',),
                                        )),
                                        Expanded(child: Text('Taxi',style: GoogleFonts.openSans(fontSize:12.0,
                                            fontWeight: (isTaxi==true)?FontWeight.bold:FontWeight.normal,
                                            color: (isTaxi==true)?grad1:grey)))
                                      ],
                                    ),
                                  ),

                                ),
                                )

                            ],),
                          ),
                        ),
                        Divider(height:0.0,),
                        Expanded(
                          flex:2,
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0,left: 40.0,top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,

                                children: [
                                  Expanded(
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Distance: ${tripDirectionDetails.distanceText}',style: GoogleFonts.ubuntuMono(
                                            fontSize: 14.0,
                                            color: Colors.grey.shade700
                                        ),),
                                        Text('Duration: ${tripDirectionDetails.durationText}',style: GoogleFonts.ubuntuMono(
                                            fontSize: 14.0,
                                            color: Colors.grey.shade700
                                        ),),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text('Estimated fare: ${Methods.calculateFares(tripDirectionDetails)} £',style: GoogleFonts.ubuntuMono(
                                      fontSize: 14.0,
                                      color: Colors.grey.shade700
                                    ),),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(height: 0.0,),
                        Expanded(
                            flex:4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: SubmitButton(onPressed: (){
                              setState(() {
                                requestDriveHeight = _height;
                                state = "requesting";
                              });
                              saveRideRequest();
                              availableDrivers = GeofireAssistant.nearByAvailableDriversList;
                              searchNearestDriver();
                              },txt: "Send Request",),
                            ))

                      ],
                    ),
                  ),
                )),
            // Requesting or Cancelling ui
            Positioned(child: Center(child:
            AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 160),
              child: Container(color: Colors.black87,height:requestDriveHeight,child:
              Stack(children: [Positioned(child: Center(child: DialogueBox(message: "Finding A Driver"))),
              Positioned(
                bottom: 150.0,
                left: _width/2-20.0,
                child: SizedBox(height:40.0,width: 40.0,child: IconButton(icon: Icon(Icons.cancel, color: Colors.red,size: 40.0,),onPressed: (){
                  cancelRideRequest();
                  displaySearchContainer();
                },)),
              )])),
            ),)),
            // driver details ui
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: AnimatedSize(
                vsync: this,
                curve: Curves.elasticInOut,
                duration: Duration(milliseconds: 200),
                child: Container(
                    height:driverDetailsHeight*_height,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft:Radius.circular(_width/7),
                            topRight:Radius.circular(_width/7)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 15.0
                          )
                        ]

                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(driverArrivalStatus, style: GoogleFonts.pacifico(
                                      fontSize: 24,
                                      color: Colors.black,

                                    ),

                                    ),
                                    SizedBox(height: 5.0,),
                                    SpinKitPouringHourGlassRefined(color: Colors.black,strokeWidth: 1.5,)
                                  ],
                                ),
                              ),
                            Divider(height: 10.0,color: grad1.withOpacity(0.5), thickness: 1.5, indent: _width/8, endIndent: _width/8,),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: _width/8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(driverCarDetails, style: TextStyle(color: grey, fontSize: 14),),
                                  Text('Cap: $driverName', style: TextStyle(color: Colors.black, fontSize: 18.0),)
                                ],
                              ),
                            ),
                            Divider(height: 10.0,color: grad1.withOpacity(0.5), thickness: 1.5, indent: _width/8, endIndent: _width/8,),
                            Padding(padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: _width/8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Expanded(
                                  child: OutlinedButton(onPressed: (){
                                    launch("tel://$driverPhone");

                                  }, child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Icon(Icons.call, size:30.0, color: grad1,),
                                  ),style:
                                    ButtonStyle(
                                      side: MaterialStateProperty.all(BorderSide(color: Colors.black.withOpacity(0.5), width: 1.3)),
                                      shape: MaterialStateProperty.all(CircleBorder(),),
                                      overlayColor:  MaterialStateProperty.all(grad1.withOpacity(0.1))
                                      //fixedSize: MaterialStateProperty.all(Size(50.0,50.0))
                                    ),),
                                ),
                                Expanded(
                                  child: OutlinedButton(onPressed: (){}, child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Icon(Icons.menu_open, size:30.0, color: grad1,),
                                  ),style:
                                  ButtonStyle(
                                      side: MaterialStateProperty.all(BorderSide(color: Colors.black.withOpacity(0.5), width: 1.3)),
                                      shape: MaterialStateProperty.all(CircleBorder(),),
                                      overlayColor:  MaterialStateProperty.all(grad1.withOpacity(0.1))
                                    //fixedSize: MaterialStateProperty.all(Size(50.0,50.0))
                                  ),),
                                ),
                                Expanded(
                                  child: OutlinedButton(onPressed: (){}, child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Icon(CupertinoIcons.xmark, size:30.0, color: grad1,),
                                  ),style:
                                  ButtonStyle(
                                      side: MaterialStateProperty.all(BorderSide(color: Colors.black.withOpacity(0.5), width: 1.3)),
                                      shape: MaterialStateProperty.all(CircleBorder(),),
                                      overlayColor:  MaterialStateProperty.all(grad1.withOpacity(0.1))
                                    //fixedSize: MaterialStateProperty.all(Size(50.0,50.0))
                                  ),),
                                )
                              ],
                            ),
                            ),

                          ],
                        ),
                      ),
                    ),
                ),
              ),
            )

          ],
        ),
      )

    );
  }
  Future<void> getPlacedDirection() async
  {
    var initialPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;
    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(context: context ,
        barrierDismissible: false,
        builder: (BuildContext context)=> DialogueBox(message: "Getting Directions"));

    var details = await Methods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails= details!;
    });
    Navigator.pop(context);
    print("This Is Encoded Points :: ");
    print(details!.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylines =polylinePoints.decodePolyline(details.encodedPoints);
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
    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(latlngBounds, 100));


    Marker pickUpMarkerDefault = Marker(
      icon: pickUpMarker!,
      markerId: MarkerId("pickUpMark"),
      infoWindow: InfoWindow(title: initialPos.placeName, snippet: "my location"),
      position: pickUpLatLng,


    );

    Marker dropOffMarkerDefault = Marker(
      icon: dropOffMarker!,
      markerId: MarkerId("dropOffMark"),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "drop off location"),
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
      strokeWidth: 3,
      radius: 10.0,
      center: pickUpLatLng
    );

    Circle dropOffCircle = Circle(
        circleId: CircleId("dropOffCircle"),
        fillColor:grad1 ,
        strokeColor:Colors.black ,
        strokeWidth: 3,
        radius: 10.0,
        center: dropOffLatLng
    );

    setState(() {
      circles.add(pickUpCircle);
      circles.add(dropOffCircle);
    });

  }
  void initGeoFireListener()
  {
    Geofire.initialize("availableDrivers");
    //////////
    //parameters here are the position of the RIDER
    Geofire.queryAtLocation(currentPosition.latitude, currentPosition.longitude, 15)?.listen((map) {
      print(map); //getting nearby drivers in the console
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearByAvailableDrivers nearByAvailableDrivers= NearByAvailableDrivers();
            nearByAvailableDrivers.key= map['key'];
            nearByAvailableDrivers.latitude= map['latitude'];
            nearByAvailableDrivers.longitude= map['longitude'];
            GeofireAssistant.nearByAvailableDriversList.add(nearByAvailableDrivers);
            if(driversAvailableKeysLoaded==true)
              {
                updateDriverMarkersOnMap();
              }
            break;

          case Geofire.onKeyExited: //if the driver went offline
            GeofireAssistant.removeDriverFromList(map['key']);
            updateDriverMarkersOnMap();

            break;

          case Geofire.onKeyMoved: //if the driver moved
            NearByAvailableDrivers nearByAvailableDrivers= NearByAvailableDrivers();
            nearByAvailableDrivers.key= map['key'];
            nearByAvailableDrivers.latitude= map['latitude'];
            nearByAvailableDrivers.longitude= map['longitude'];
            GeofireAssistant.updateDriverLocationFromList(nearByAvailableDrivers);
            updateDriverMarkersOnMap();

            break;

          case Geofire.onGeoQueryReady:
            updateDriverMarkersOnMap();

            break;
        }
      }

      setState(() {});
    });
    /////////

  }
  void updateDriverMarkersOnMap()
  {

    setState(() {
      markers.clear();
    });

    Set<Marker> carMarkers= Set<Marker>();
    for(NearByAvailableDrivers driver in GeofireAssistant.nearByAvailableDriversList)
      {
        LatLng driverAvailablePosition = LatLng(driver.latitude!, driver.longitude!);
        Marker mark=Marker(
          markerId: MarkerId('car${driver.key}'),
          icon: nearByIcon!,
          position: driverAvailablePosition,
          rotation: Methods.createRandomNumber(360)

        );
        carMarkers.add(mark);
      }
    setState(() {
      markers= carMarkers;
    });

  }
  void createCarIconMarkers()
  {

    if(nearByIcon==null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
          context, size: Size(4, 4));
      BitmapDescriptor.fromAssetImage(imageConfiguration, 'assets/car_mark2.png')
          .then((value) {
        nearByIcon = value;
      });
    }

}
  void noDriverFound()
  {
  showDialog(context: context,
      barrierDismissible: false,
      builder:(BuildContext context){
        return NoDriverDialogue();
      });
}
  void searchNearestDriver()
  {
    if (availableDrivers.length==0)
      {
        cancelRideRequest();
        displaySearchContainer();
        noDriverFound();
        return;
      }
    var driver = availableDrivers[0];
    notifyDriver(driver);
    availableDrivers.removeAt(0);
  }
  void notifyDriver(NearByAvailableDrivers driver)
  {
    String token= "";
      driversRef.child(driver.key!).child("newRide").set(rideRequestReference!.key);
      driversRef.child(driver.key!).child("token").once().then((DataSnapshot snap) {
      if(snap.value !=null)
      {
          token = snap.value.toString();
          Methods.sendNotificationToDriver(token, context, rideRequestReference!.key);
      }
      else{
        return;
      }

      const oneSecPassed = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecPassed, (timer) {
        driverRequestTimeOut -=1;
        driversRef.child(driver.key!).child("newRide").onValue.listen((event) {
          if(state != "requesting")
            {
              driversRef.child(driver.key!).child("newRide").set("cancelled");
              driversRef.child(driver.key!).child("newRide").onDisconnect();
              driverRequestTimeOut = 40;
              timer.cancel();
              return;
            }
          if(event.snapshot.value.toString()=="accepted")
            {
              driversRef.child(driver.key!).child("newRide").onDisconnect();
              driverRequestTimeOut = 40;
              timer.cancel();
             return;
            }
        });
        if(driverRequestTimeOut ==0)
          {
            driversRef.child(driver.key!).child("newRide").set("timeout");
            driversRef.child(driver.key!).child("newRide").onDisconnect();
            driverRequestTimeOut = 40;
            timer.cancel();
            searchNearestDriver();


          }
      });
      });

  }
}



class Hi_There extends StatelessWidget {
  const Hi_There({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0,vertical: 8.0),
          child: Text(
            'Hi There!',
            style: GoogleFonts.caveat(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87
              )
            ),
          ),
        ),
      ],
    );
  }
}

class Icons_Map extends StatelessWidget {
  final VoidCallback locate;

  Icons_Map({
    Key? key,
    required double width, required this.locate
  }) : _width = width, super(key: key);

  final double _width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
        ),

        MapButton(icon: Icon(Icons.home,color: grad1,),heroTag:"homeBtn",onPressed: (){}),
        SizedBox(
          width: 15,
        ),
        MapButton(icon: Icon(Icons.work,color: grad1,),heroTag:"workBtn",onPressed: (){
        }),


        SizedBox(
          width: _width-(55+3*(50/xd_width)*_width),
        ),
        MapButton(icon: Icon(Icons.my_location,color: grad1,),heroTag:"locationBtn",
            onPressed: (){
              locate();
        }),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
