import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/Configurations/configMaps.dart';
import 'package:flutter_app/Models/address.dart';
import 'package:flutter_app/Models/history.dart';

import '../main.dart';
class AppData extends ChangeNotifier
{
 Address pickUpLocation = new Address("", "", "", 0.0, 0.0);
 Address dropOffLocation = new Address("", "", "", 0.0, 0.0);
 Address? homeLocation;
 Address? workLocation;
 List<History> tripCards=[];
 int total_trips=0;
 void updatePickUpLocation(Address pickupAddress)
 {
   pickUpLocation= pickupAddress;
   notifyListeners();
 }
 Future<void>? updateHomeLocation(Address home)
 {
   homeLocation= home;
   notifyListeners();
 }
 Future<void>? updateWorkLocation(Address work)
 {
   workLocation= work;
   notifyListeners();
 }
 void updateDropOffLocation(Address dropOffAddress)
 {
   dropOffLocation= dropOffAddress;
   notifyListeners();
 }
 void clearTripHistoryList()
 {
   tripCards.clear();
   notifyListeners();

 }
 Future<void> updateTripHistoryList(History trip)
 async {
       tripCards.add(trip);
       notifyListeners();

 }

 void updateTripCount()
 {
   total_trips++;
   notifyListeners();
 }
 void initializeTotalTrips(int count)
 {
   total_trips= count;
   notifyListeners();
 }


}