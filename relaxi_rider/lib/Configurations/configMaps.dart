import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/Models/AllUsers.dart';
String mapKey= 'AIzaSyAPNzBqVfnM1BN5BWSFvTA_szJhR6gu9mY';
User? firebaseUser;
Users userCurrentInfo= new Users(
id: "",
name: "",
total_trips: 0,
phone: "",
email: "",
);
String serverToken = "key=AAAAQl7TJ3M:APA91bGy2AVPEP7I9X9N4q4Sl5di9uz7EUQZiy3g0sArt6ptgQv_jLxaBNbuUrfenstL28Lqk4s58qoGsuQtZHRzc8GhYfMTjkhMKJ0kfReAv7DS03RpalrqtHT6cGCW3pFTHs-clO-B";
int driverRequestTimeOut= 40;
String statusRide="";
String driverName="";
String driverPhone="";
String driverCarDetails="";
String driverArrivalStatus="Driver is on his way...";
