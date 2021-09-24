import 'package:flutter/cupertino.dart';
import 'package:relaxi_driver/Models/address.dart';
class AppData extends ChangeNotifier
{
 Address pickUpLocation = new Address("", "", "", 0.0, 0.0);
 Address dropOffLocation = new Address("", "", "", 0.0, 0.0);
 bool isDriverOnline=false;
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
}