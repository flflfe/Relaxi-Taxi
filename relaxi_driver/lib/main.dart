import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:relaxi_driver/AllScreens/RegistrationScreen.dart';
import 'package:relaxi_driver/AllScreens/loginScreen.dart';
import 'package:relaxi_driver/AllScreens/mainscreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:relaxi_driver/AllScreens/phoneVerification.dart';
import 'package:relaxi_driver/AllScreens/splashScreen.dart';
import 'package:relaxi_driver/AllWidgets/dialogueBox.dart';
import 'package:relaxi_driver/Configurations/configMaps.dart';
import 'package:relaxi_driver/DataHandler/appData.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:relaxi_driver/Notifications/notificationDialogue.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AllScreens/introOnBoardingScreen.dart';
import 'Assistants/utils.dart';
StreamSubscription? subscription;
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
Future<bool?> hasCompletedProfile() async
{
  currentFirebaseUser= FirebaseAuth.instance.currentUser;
  if(currentFirebaseUser!=null)
    {
      bool is_completed=await FirebaseDatabase.instance.reference().child("drivers").child(currentFirebaseUser!.uid).once().then((snap) {
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
Future<void> main() async{
  runZonedGuarded(() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp();
  currentFirebaseUser = FirebaseAuth.instance.currentUser;
  hasCompletedProf=await hasCompletedProfile();
  isFirstTimeBool=await isFirstTime();
  print(hasCompletedProf);
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
class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void isCompleted()async
  {
    hasCompletedProf=await hasCompletedProfile();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription= Connectivity().onConnectivityChanged.listen(showConnectivitySnackBar);
  }
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: ChangeNotifierProvider(
        create:(context)=>AppData(),
        child: MaterialApp(
          title: 'Relaxi Drivers',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(grad1),
              trackColor: MaterialStateProperty.all(grey),
            )
          ),

          initialRoute: SplashScreen.id_screen,
          routes: {
           SplashScreen.id_screen:(context)=>SplashScreen(),
           RegistrationScreen.id_screen: (context)=> RegistrationScreen(),
           LoginScreen.id_screen: (context)=> LoginScreen(),
           MainScreen.id_screen: (context)=> MainScreen(),
           PhoneVerification.id_screen:(context)=>PhoneVerification(),
           IntroOnBoardingScreen.id_screen:(context)=>IntroOnBoardingScreen()
         },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
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

