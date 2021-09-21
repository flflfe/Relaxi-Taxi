
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:relaxi_driver/Configurations/configMaps.dart';
import 'package:relaxi_driver/Models/rideDetails.dart';
import 'package:relaxi_driver/Notifications/notificationDialogue.dart';
import 'package:relaxi_driver/main.dart';
import 'dart:io' show Platform;
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    "High Importance Notifcations",
    "This channel is used important notification",
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationplugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message : ${message.messageId}");

}



class FirebaseNotifcation {
    initialize(context) async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await flutterLocalNotificationplugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    var intializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
    InitializationSettings(android: intializationSettingsAndroid);

    flutterLocalNotificationplugin.initialize(initializationSettings);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      retrieveRideRequestInfo(getRideReqId(message.data),context);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      retrieveRideRequestInfo(getRideReqId(message.data),context);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {

        AndroidNotificationDetails notificationDetails =
        AndroidNotificationDetails(
            channel.id, channel.name, channel.description,
            importance: Importance.max,
            priority: Priority.high,
            groupKey: channel.groupId);
        NotificationDetails notificationDetailsPlatformSpefics =
        NotificationDetails(android: notificationDetails);
        flutterLocalNotificationplugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            notificationDetailsPlatformSpefics);
      }

      List<ActiveNotification> ?activeNotifications =
      await flutterLocalNotificationplugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.getActiveNotifications();
      if (activeNotifications!.length > 0) {
        List<String> lines =
        activeNotifications.map((e) => e.title.toString()).toList();
        InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
            lines,
            contentTitle: "${activeNotifications.length - 1} messages",
            summaryText: "${activeNotifications.length - 1} messages");
        AndroidNotificationDetails groupNotificationDetails =
        AndroidNotificationDetails(
            channel.id, channel.name, channel.description,
            styleInformation: inboxStyleInformation,
            setAsGroupSummary: true,
            groupKey: channel.groupId);

        NotificationDetails groupNotificationDetailsPlatformSpefics =
        NotificationDetails(android: groupNotificationDetails);
        await flutterLocalNotificationplugin.show(
            0, '', '', groupNotificationDetailsPlatformSpefics);
      }
    });
  }

  Future<String?> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('This is token :: $token');
    driversRef.child(currentFirebaseUser!.uid).child("token").set(token);
    await FirebaseMessaging.instance.subscribeToTopic("alldrivers");
    await FirebaseMessaging.instance.subscribeToTopic("allusers");

    return token;
  }

    String getRideReqId(Map<String, dynamic> message)
    {
      String rideRequestId="";
      if(Platform.isAndroid)
      {

        rideRequestId = message["ride_request_id"];


      }
      else
      {
        rideRequestId = message['ride_request_id'];


      }
      return rideRequestId;

    }

  void retrieveRideRequestInfo(String rideReqId, BuildContext context)
  {
    newReqRef.child(rideReqId).once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value != null)
        {

          assetsAudioPlayer.open(Audio('sounds/taxi_whistle.mp3'));
          assetsAudioPlayer.play();
          //print(dataSnapshot.value['pickUp']['latitude']);
          double pickUpLocLat= double.parse(dataSnapshot.value['pickUp']['latitude'].toString());
          double pickUpLocLon= double.parse(dataSnapshot.value['pickUp']['longitude'].toString());
          String pickUpAddress = dataSnapshot.value['pickup_address'].toString();
          double dropOffLocLat= double.parse(dataSnapshot.value['dropOff']['latitude'].toString());
          double dropOffLocLon= double.parse(dataSnapshot.value['dropOff']['longitude'].toString());
          String dropOffAddress = dataSnapshot.value['dropoff_address'].toString();
          String paymentMethod = dataSnapshot.value['payment_method'].toString();
          ////////////////////////////////////////////////
          String rider_name = dataSnapshot.value["rider_name"];
          String rider_phone = dataSnapshot.value["rider_phone"];

          RideDetails rideDetails = RideDetails();
          rideDetails.ride_request_id=rideReqId;
          rideDetails.pickup_address=pickUpAddress;
          rideDetails.dropoff_address=dropOffAddress;
          rideDetails.dropOff= LatLng(dropOffLocLat,dropOffLocLon);
          rideDetails.pickUp= LatLng(pickUpLocLat,pickUpLocLon);
          rideDetails.payment_method= paymentMethod;
          rideDetails.rider_name=rider_name;
          rideDetails.rider_phone=rider_phone;
          print("Information :: ");
          print(rideDetails.pickup_address);
          print(rideDetails.dropoff_address);

          showDialog(context: context,barrierDismissible: false,
              builder:(BuildContext contexr)=> NotificationDialogue(rideDetails: rideDetails,));

        }
    });


  }

}
