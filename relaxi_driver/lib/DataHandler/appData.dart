import 'package:flutter/cupertino.dart';
import 'package:relaxi_driver/Models/address.dart';
import 'package:relaxi_driver/Models/drivers.dart';
import 'package:relaxi_driver/Models/history.dart';
class AppData extends ChangeNotifier
{
 Address pickUpLocation = new Address("", "", "", 0.0, 0.0);
 Address dropOffLocation = new Address("", "", "", 0.0, 0.0);
 bool isDriverOnline=false;
 List<History> tripCards=[];
 Drivers? driverDetails;
 Future<void> updateDriverDetails(Drivers driver) async
 {
   driverDetails= driver;
   notifyListeners();
 }
 void updatePickUpLocation(Address pickupAddress)
 {
   pickUpLocation= pickupAddress;
   notifyListeners();
 }
 void updateDropOffLocation(Address dropOffAddress)
 {
   dropOffLocation= dropOffAddress;
   notifyListeners();
 }
 void updateDriverOnlineStatus(bool state)
 {
   isDriverOnline = state;
   notifyListeners();
 }
 void updateTripHistoryList(History trip)
 {
   tripCards.add(trip);
   notifyListeners();

 }

 Future<void> clearTripHistoryList()async
 {
   tripCards.clear();
   notifyListeners();

 }
}