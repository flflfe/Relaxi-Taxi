import 'dart:io';

import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:relaxi_driver/Configurations/configMaps.dart';
import 'package:relaxi_driver/DataHandler/appData.dart';
import 'package:relaxi_driver/Models/AllUsers.dart';
import 'package:relaxi_driver/Models/address.dart';
import 'package:relaxi_driver/Models/directionDetails.dart';
import 'package:geolocator/geolocator.dart';
import 'package:relaxi_driver/Assistants/requests.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
class Methods
{
  static Future<String> searchCoordinateAddress(Position position,context) async
  {
  String placeAddress="";

  String url= "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
  var response= await Requests.getRequest(url);

  if(response!= "failed")
    {

      placeAddress =
          response["results"][1]["address_components"][0]["short_name"]+", "+
          response["results"][1]["address_components"][1]["short_name"]+", "+
          response["results"][1]["address_components"][2]["short_name"];
      Address userPickUpAddress= new Address("","","",0.0,0.0);
      userPickUpAddress.longitude= position.longitude;
      userPickUpAddress.latitude= position.latitude;
      userPickUpAddress.placeName= placeAddress;
      Provider.of<AppData>(context, listen: false).updatePickUpLocation(userPickUpAddress);

    }
  return placeAddress;
}
  static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async
  {
    String directionUrl ="https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";
    var response= await Requests.getRequest(directionUrl);
    if(response == "failed")
    {
      return null;
    }
    if(response["status"]=="OK") {
      DirectionDetails directionDetails = new DirectionDetails(
          0, 0, "", "", "");
      directionDetails.durationValue =
      response["routes"][0]["legs"][0]["duration"]["value"];
      directionDetails.durationText =
      response["routes"][0]["legs"][0]["duration"]["text"];
      directionDetails.distanceValue =
      response["routes"][0]["legs"][0]["distance"]["value"];
      directionDetails.distanceText =
      response["routes"][0]["legs"][0]["distance"]["text"];
      directionDetails.encodedPoints =
      response["routes"][0]["overview_polyline"]["points"];
      return directionDetails;
    }
    return null;
  }
  static double calculateFares(DirectionDetails directionDetails)
  {
    double costPerMin= 0.2*(directionDetails.durationValue/60);
    double costPerKM= 1.3*(directionDetails.distanceValue/1000);
    double totalFare= 13.0+costPerKM+costPerMin;
    return  double.parse(totalFare.toStringAsFixed(2));

  }
  static void getCurrentOnlineUserInfo() async
  {
    firebaseUser = (await FirebaseAuth.instance.currentUser)!;
    String userId = firebaseUser!.uid;
    DatabaseReference reference= FirebaseDatabase.instance.reference().child("users").child(userId);
    reference.once().then((DataSnapshot dataSnapshot) {
      userCurrentInfo = Users.fromSnapshot(dataSnapshot);
    });

  }

  ///for image picker
  static UploadTask? uploadImage(String destination, File file){
    try {
      final ref= FirebaseStorage.instance.ref(destination);
      print('Successfully uploaded image');
      return ref.putFile(file);
    } on FirebaseException catch (e) {
      // TODO
      print('couldn\'t upload image: $e');
      return null;
    }
  }
  //////////////////
  static void disableHomeTabLocationLiveUpdate()
  {
      homeTabStreamSubscribtion!.pause();
      Geofire.removeLocation(currentFirebaseUser!.uid);

  }

  static void enableHomeTabLocationLiveUpdate()
  {
    homeTabStreamSubscribtion!.resume();
    Geofire.setLocation(currentFirebaseUser!.uid, currentPosition!.latitude,currentPosition!.longitude);

  }
}

