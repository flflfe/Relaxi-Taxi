import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/AllScreens/RegistrationScreen.dart';
import 'package:flutter_app/AllScreens/addHomeWorkScreen.dart';
import 'package:flutter_app/AllScreens/loginScreen.dart';
import 'package:flutter_app/AllScreens/mainscreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/AllScreens/phoneVerification.dart';
import 'package:flutter_app/AllScreens/profilePage.dart';
import 'package:flutter_app/AllScreens/splashScreen.dart';
import 'package:flutter_app/AllScreens/tripHistoryPage.dart';
import 'package:flutter_app/AllWidgets/dialogueBox.dart';
import 'package:flutter_app/Configurations/configMaps.dart';
import 'package:flutter_app/DataHandler/appData.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AllScreens/introOnBoardingScreen.dart';
import 'Assistants/utils.dart';
import 'constants/all_cons.dart';
StreamSubscription? subscription;

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
  var isFirstTime = prefs.getBool('firstOpen');
  if (isFirstTime != null && !isFirstTime) {
    prefs.setBool('firstOpen', false);
    return false;
  } else {
    prefs.setBool('firstOpen', false);
    return true;
  }
}
void main() async{
  runZonedGuarded(() async{
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    await Firebase.initializeApp();
    firebaseUser= await FirebaseAuth.instance.currentUser;
    hasCompletedProf=await hasCompletedProfile();
    isFirstTimeBool=await isFirstTime();
    print("first time? $isFirstTimeBool");
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
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription= Connectivity().onConnectivityChanged.listen(showConnectivitySnackBar);

  }
  @override
  Widget build(BuildContext context) {

    return OverlaySupport(
        child:ChangeNotifierProvider(
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
          TripHistoryPage.id_screen: (context)=>TripHistoryPage(),
          PhoneVerification.id_screen:(context)=>PhoneVerification(),
          IntroOnBoardingScreen.id_screen:(context)=>IntroOnBoardingScreen()

        },
        debugShowCheckedModeBanner: false,
      ),
    ));
  }
  void showConnectivitySnackBar(ConnectivityResult result)
  {
    final hasInternet= result!=ConnectivityResult.none;
    final message= hasInternet?
    'You are connected to internet now':
    'you have no internet, most of the app functions wont work';
    final color= hasInternet ? Colors.green: Colors.red;
    Utils.showTopSnackBar(context, message, color);
  }
}

