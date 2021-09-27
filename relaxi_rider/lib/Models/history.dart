import 'package:firebase_database/firebase_database.dart';

class History {
  DateTime? created_at;
  String? driver_name;
  String? driver_phone;
  String? rider_phone;
  String? rider_name;
  String?dropoff_address;
  String? pickup_address;
  double? fares;
  String?payment_method;
  String? car_details;
  String? duration;
  String? distance;
  History(
      {this.rider_name, this.rider_phone, this.driver_name, this.driver_phone,
        this.fares, this.dropoff_address, this.pickup_address, this.car_details, this.payment_method, this.created_at
      });

  History.fromSnapshot(DataSnapshot dataSnapshot)
  {
    rider_name = dataSnapshot.value['rider_name'].toString();
    driver_name = dataSnapshot.value['driver_name'].toString();
    created_at = DateTime.parse(dataSnapshot.value['created_at'].toString());
    rider_phone = dataSnapshot.value['rider_phone'].toString();
    dropoff_address = dataSnapshot.value['dropoff_address'].toString();
    pickup_address = dataSnapshot.value['pickup_address'].toString();
    fares = double.parse(dataSnapshot.value['fares'].toString());
    payment_method = dataSnapshot.value['payment_method'].toString();
    car_details = dataSnapshot.value['car_details'].toString();
    duration = dataSnapshot.value['duration'].toString();
    distance = dataSnapshot.value['distance'].toString();
  }
}