import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/Models/address.dart';
class Users{
  String? name;
  String? id;
  String? phone;
  String? email;
  int? total_trips;
  Address? home;
  Address? work;
  Users(
  {   this.id,
      this.email,
      this.name,
      this.phone,
      this.total_trips,
      this.work,
      this.home
  }

      );
  Users.fromSnapshot(DataSnapshot dataSnapshot)
  {
    id=dataSnapshot.key!.toString();
    email= dataSnapshot.value['email'].toString();
    name= dataSnapshot.value['name'].toString();
    phone=dataSnapshot.value['phone'].toString();
    total_trips = int.parse(dataSnapshot.value['total_trips'].toString());
    if(dataSnapshot.value['home']!=null) {
      home= new Address("", "", "", 0.0, 0.0);
      home?.placeName = dataSnapshot.value['home']['place_name'].toString();
      home?.placeFormattedAddress =
      dataSnapshot.value['home']['place_formatted_address'].toString();
      home?.longitude = double.parse(dataSnapshot.value['home']['longitude'].toString());
      home?.latitude = double.parse(dataSnapshot.value['home']['latitude'].toString());
    }
    if(dataSnapshot.value['work']!=null) {
      work= new Address("", "", "", 0.0, 0.0);
      work?.placeName = dataSnapshot.value['work']['place_name'].toString();
      work?.placeFormattedAddress =
      dataSnapshot.value['work']['place_formatted_address'].toString();
      work?.longitude = double.parse(dataSnapshot.value['work']['longitude'].toString());
      work?.latitude = double.parse(dataSnapshot.value['work']['latitude'].toString());
    }
  }
}