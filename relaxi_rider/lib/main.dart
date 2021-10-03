import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/AllScreens/RegistrationScreen.dart';
import 'package:flutter_app/AllScreens/addHomeWorkScreen.dart';
import 'package:flutter_app/AllScreens/loginScreen.dart';
import 'package:flutter_app/AllScreens/mainscreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/AllScreens/profilePage.dart';
import 'package:flutter_app/AllScreens/splashScreen.dart';
import 'package:flutter_app/AllScreens/tripHistoryPage.dart';
import 'package:flutter_app/AllWidgets/dialogueBox.dart';
import 'package:flutter_app/Configurations/configMaps.dart';
import 'package:flutter_app/DataHandler/appData.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/all_cons.dart';

Future<bool?> hasCompletedProfile() async
{
  firebaseUser= FirebaseAuth.instance.currentUser;
  if(firebaseUser!=null)
  {
    bool is_completed=await FirebaseDatabase.instance.reference().child("users").child(firebaseUser!.uid).once().then((snap) {
      if(snap.value!=null)
      {
        if(snap.value["phone"]==null)
        {
          return false;
        }
        else
        {
          print('doneee');

          return true;
        }
      }
      else{
        return false;
      }
    });
    return is_completed;
  }
  return false;
}
Future<bool> isFirstTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var isFirstTime = prefs.getBool('first_time');
  if (isFirstTime != null && !isFirstTime) {
    prefs.setBool('first_time', false);
    return false;
  } else {
    return true;
  }
}
void main() async{
  runZonedGuarded(() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    firebaseUser= await FirebaseAuth.instance.currentUser;
    hasCompletedProf=await hasCompletedProfile();
    isFirstTimeBool=await isFirstTime();
    print(hasCompletedProf);
    runApp(MyApp());
  }, (Object error, StackTrace stack) {

  });

}

DatabaseReference userRef= FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversRef= FirebaseDatabase.instance.reference().child("drivers");
DatabaseReference rideRef= FirebaseDatabase.instance.reference().child("Ride Requests");

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create:(context)=>AppData(),
      child: MaterialApp(
        title: 'Relaxi',
        theme: ThemeData(

          primarySwatch: Colors.blue,
          splashColor: grad1,
        ),

        initialRoute: SplashScreen.id_screen,
        routes: {
          SplashScreen.id_screen:(context)=>SplashScreen(),
          RegistrationScreen.id_screen: (context)=> RegistrationScreen(),
          LoginScreen.id_screen: (context)=> LoginScreen(),
          MainScreen.id_screen: (context)=> MainScreen(),
          ProfilePage.id_screen: (context)=>ProfilePage(),
          TripHistoryPage.id_screen: (context)=>TripHistoryPage()

        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

