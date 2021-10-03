import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app/Configurations/configMaps.dart';
import 'package:flutter_app/DataHandler/appData.dart';
import 'package:flutter_app/Models/AllUsers.dart';
import 'package:flutter_app/Models/address.dart';
import 'package:flutter_app/Models/directionDetails.dart';
import 'package:flutter_app/Models/history.dart';
import 'package:flutter_app/Models/placePredictions.dart';
import 'package:flutter_app/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/Assistants/requests.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
class Methods {
  static Future<String> searchCoordinateAddress(Position position,
      context) async
  {
    String placeAddress = "";

    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position
        .latitude},${position.longitude}&key=$mapKey";
    var response = await Requests.getRequest(url);

    if (response != "failed") {
      placeAddress =
          response["results"][1]["address_components"][0]["short_name"] + ", " +
              response["results"][1]["address_components"][1]["short_name"] +
              ", " +
              response["results"][1]["address_components"][2]["short_name"];
      Address userPickUpAddress = new Address("", "", "", 0.0, 0.0);
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;
      Provider.of<AppData>(context, listen: false).updatePickUpLocation(
          userPickUpAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async
  {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition
        .latitude},${initialPosition.longitude}&destination=${finalPosition
        .latitude},${finalPosition.longitude}&key=$mapKey";
    var response = await Requests.getRequest(directionUrl);
    if (response == "failed") {
      return null;
    }
    if (response["status"] == "OK") {
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

  static double calculateFares(DirectionDetails directionDetails) {
    double costPerMin = 0.2 * (directionDetails.durationValue / 60);
    double costPerKM = 1.3 * (directionDetails.distanceValue / 1000);
    double totalFare = 13.0 + costPerKM + costPerMin;
    return double.parse(totalFare.toStringAsFixed(2));
  }

  static Future<void> getCurrentOnlineUserInfo() async
  {

    firebaseUser = await FirebaseAuth.instance.currentUser!;
    String userId = firebaseUser!.uid;
    DatabaseReference reference = FirebaseDatabase.instance.reference().child(
        "users").child(userId);
    userCurrentInfo=await reference.once().then((DataSnapshot dataSnapshot) {
      return Users.fromSnapshot(dataSnapshot);
    });
  }

  static double createRandomNumber(int num) {
    var random = Random();
    int number = random.nextInt(num);
    return number.toDouble();
  }

  static sendNotificationToDriver(String token, context, String rideReqID) async
  {
    var pickup = Provider
        .of<AppData>(context, listen: false)
        .pickUpLocation;
    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverToken
    };

    Map notificationMap = {
      'body': 'hey there! can u pick me up?\n from ${pickup.placeName}?',
      'title': 'New Ride Request!'
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "ride_request_id": rideReqID
    };

    Map sendNotificationMap = {
      "notification": notificationMap,
      "data": dataMap,
      "priority": "high",
      "to": token
    };
    var res = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: headerMap,
      body: jsonEncode(sendNotificationMap),
    );
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
  static Future<void> retrieveHistoryInfo (context) async
  {
    //retrieve trip history
    await getCurrentOnlineUserInfo();
    await userRef.child(userCurrentInfo.id!).child('history').once().then((DataSnapshot snap) async{
      if(snap.value == null)
        {

        }
      else
        {
          Map <dynamic,dynamic> keys= snap.value;
          List<String>keysList= [];
          keys.forEach((key, value) {keysList.add(key);});
          List<History> tripsList=[];
          Provider.of<AppData>(context,listen: false).clearTripHistoryList();
          for(String key in keysList)
          {
            await rideRef.child(key).once().then((DataSnapshot snap) async{
              print(snap.value.toString());
              if(snap.value!=null)
              {
                History history= History.fromSnapshot(snap);
                print(history.dropoff_address.toString());
                tripsList.add(history);
                await Provider.of<AppData>(context,listen: false).updateTripHistoryList(history);

              }
            });

          }

        }
    });
  }
  static void updateHomeAddress (Address address)
  {
    //retrieve trip history
    userRef.child(userCurrentInfo.id!).once().then((DataSnapshot snap){
      if(snap.value != null)
          {
            Map<String, String> homeAddress=
            {
            "place_name":address.placeName,
            "place_formatted_address":address.placeFormattedAddress,
            "longitude":address.longitude.toString(),
            "latitude":address.latitude.toString()
            };
            userRef.child(userCurrentInfo.id!).child('home').set(homeAddress);
        }
    });
  }

  static void updateWorkAddress (Address address)
  {
    //retrieve trip history
    userRef.child(userCurrentInfo.id!).once().then((DataSnapshot snap){
      if(snap.value != null)
      {
        Map<String, String> workAddress=
        {
          "place_name":address.placeName,
          "place_formatted_address":address.placeFormattedAddress,
          "longitude":address.longitude.toString(),
          "latitude":address.latitude.toString()
        };
        userRef.child(userCurrentInfo.id!).child('work').set(workAddress);

      }
    });
  }


}

