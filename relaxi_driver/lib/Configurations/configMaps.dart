import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:relaxi_driver/Models/AllUsers.dart';
import 'package:relaxi_driver/Models/drivers.dart';


String mapKey= 'AIzaSyAPNzBqVfnM1BN5BWSFvTA_szJhR6gu9mY';
StreamSubscription<Position>? homeTabStreamSubscribtion;
StreamSubscription<Position>? rideScreenStreamSubscribtion;
final assetsAudioPlayer = AssetsAudioPlayer();
User? firebaseUser;
Users userCurrentInfo= new Users("", "", "", "");
User? currentFirebaseUser;
bool? hasCompletedProf;
Position? currentPosition;
Drivers? driversInfo;
bool?isFirstTimeBool;