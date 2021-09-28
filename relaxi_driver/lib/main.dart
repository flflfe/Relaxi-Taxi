import 'dart:async';

import 'package:flutter/material.dart';
import 'package:relaxi_driver/AllScreens/RegistrationScreen.dart';
import 'package:relaxi_driver/AllScreens/carInfoScreen.dart';
import 'package:relaxi_driver/AllScreens/loginScreen.dart';
import 'package:relaxi_driver/AllScreens/mainscreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:relaxi_driver/AllScreens/splashScreen.dart';
import 'package:relaxi_driver/AllWidgets/dialogueBox.dart';
import 'package:relaxi_driver/Configurations/configMaps.dart';
import 'package:relaxi_driver/DataHandler/appData.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:relaxi_driver/Notifications/notificationDialogue.dart';
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print('A bg message just showed up :  ${message.messageId}');
}

Future<void> main() async{
  runZonedGuarded(() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  currentFirebaseUser = FirebaseAuth.instance.currentUser;
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp());
  }, (Object error, StackTrace stack) {

  });
}

DatabaseReference userRef= FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversRef= FirebaseDatabase.instance.reference().child("drivers");
DatabaseReference newReqRef= FirebaseDatabase.instance.reference().child("Ride Requests");
DatabaseReference tripReqRef= FirebaseDatabase.instance.reference().child("drivers").child(currentFirebaseUser!.uid).child("newRide");
DatabaseReference currentDriverRef= FirebaseDatabase.instance.reference().child("drivers").child(currentFirebaseUser!.uid);
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create:(context)=>AppData(),
      child: MaterialApp(
        title: 'Relaxi Drivers',
        theme: ThemeData(

          primarySwatch: Colors.blue,
        ),

        initialRoute: FirebaseAuth.instance.currentUser==null?LoginScreen.id_screen:MainScreen.id_screen,
        routes: {
         SplashScreen.id_screen:(context)=>SplashScreen(),
          RegistrationScreen.id_screen: (context)=> RegistrationScreen(),
         LoginScreen.id_screen: (context)=> LoginScreen(),
         MainScreen.id_screen: (context)=> MainScreen(),
         CarInfoScreen.idScreen: (context)=>CarInfoScreen()
       },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

