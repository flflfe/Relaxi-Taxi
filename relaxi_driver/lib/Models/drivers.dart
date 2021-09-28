import 'package:firebase_database/firebase_database.dart';

class Drivers{
  String? name;
  String? phone;
  String? email;
  String? id;
  String? car_number;
  String? car_model;
  String? car_color;
  double? avg_rating;
  double? earnings;
  int? total_trips;

  Drivers({
    this.name,
    this.phone,
    this.email,
    this.id,
    this.car_number,
    this.car_model,
    this.car_color,
    this.total_trips,
    this.earnings,
    this.avg_rating,
});

  Drivers.fromSnapshot(DataSnapshot dataSnapshot)
  {

    id=dataSnapshot.key;
    print("doneeeeeeeeeeeeeeeeeee $id");
    name= dataSnapshot.value["name"];
    email= dataSnapshot.value["email"];
    phone= dataSnapshot.value["phone"];
    car_number= dataSnapshot.value["carDetails"]["car_number"];
    car_model= dataSnapshot.value["carDetails"]["car_model"];

    car_color= dataSnapshot.value["carDetails"]["car_color"];
    total_trips=dataSnapshot.value['total_trips']!=null?int.parse(dataSnapshot.value['total_trips'].toString()):0;
    earnings=dataSnapshot.value['earnings']!=null?double.parse(dataSnapshot.value['earnings'].toString()):0;
    avg_rating=dataSnapshot.value['avg_rating']!=null?double.parse(dataSnapshot.value['avg_rating'].toString()):0;


  }
}