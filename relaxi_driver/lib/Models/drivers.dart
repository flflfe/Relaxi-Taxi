import 'package:firebase_database/firebase_database.dart';

class Drivers{
  String? name;
  String? phone;
  String? email;
  String? id;
  String? car_number;
  String? car_model;
  String? car_color;
  Drivers({
    this.name,
    this.phone,
    this.email,
    this.id,
    this.car_number,
    this.car_model,
    this.car_color
});

  Drivers.fromSnapshot(DataSnapshot dataSnapshot)
  {
    id=dataSnapshot.key;
    name= dataSnapshot.value["name"];
    email= dataSnapshot.value["email"];
    phone= dataSnapshot.value["phone"];
    car_number= dataSnapshot.value["carDetails"]["car_number"];
    car_model= dataSnapshot.value["carDetails"]["car_model"];
    car_color= dataSnapshot.value["carDetails"]["car_color"];
  }
}