import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:relaxi_driver/AllWidgets/speedDialCustom.dart';
import 'package:relaxi_driver/Assistants/methods.dart';
import 'package:relaxi_driver/Configurations/configMaps.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:relaxi_driver/main.dart';
import 'ratingPage.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UploadTask? task;
  String? imageUrl;
  File? image;
  double avgRate = 0;
  int total_trips = 0;
  double earnings =0;
  String car_color='';
  String car_number='';
  String car_model='';
  String phoneNumber='';
  String name='';

  Future pickImage() async
  {
    try {
      final image =await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image==null) return;
      final tempImage = File(image.path);
      final fileName = basename(tempImage.path);
      final destination='files/$fileName';
      task= Methods.uploadImage(destination, tempImage);
      if (task == null) return;
      final snapShot = await task!.whenComplete((){});
      final String urlDownload = await snapShot.ref.getDownloadURL();
      setState(() {
        this.imageUrl=urlDownload;
        this.image= tempImage;
      } );

    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }


  }
  bool? is_expanded=false;
  Image? pickedImage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDriverDetails();
  }
  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    double? height_top= _height/2 - 50.0;


    return SafeArea(
      child: Column(
        //overflow: Overflow.visible,
        children: [
          Container(
            width: _width+200,

            height: _height/2-60,
            decoration: new BoxDecoration(
              color: Colors.white,
              image: new DecorationImage(
                image: new ExactAssetImage('assets/profile_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(

              children: [

                Positioned(
                  bottom:60,
                  left: ((_width/2) -116)/2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.grey.shade400, blurRadius: 2.0
                          )
                        ],
                        borderRadius: BorderRadius.circular(100.0)
                      ),
                      child: CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Colors.grey,
                      foregroundImage: imageUrl!=null?NetworkImage(imageUrl!) :
                      AssetImage('assets/user.png') as ImageProvider
                      ),
                    ),
                  ),
                ),
                Positioned(bottom: 10.0,
                  child: Container(
                    width: _width/2,
                    child: Center(
                      child: Text(
                      name,overflow: TextOverflow.fade, style: GoogleFonts.lobster(color: grad1),textAlign: TextAlign.center,
                      textScaleFactor: 1.7,
                ),
                    ),
                  ),),
                Positioned(
                top: 20,
                right: 20.0,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationX(math.pi),
                  child: SpeedDialFabWidget(
                    secondaryIconsList: [
                      Icons.rate_review,
                      Icons.edit,
                      Icons.logout,
                    ],
                    secondaryIconsText: [
                      "review our app",
                      "edit password",
                      "log out",

                    ],
                    secondaryIconsOnPress: [
                          () => {},
                          () => {},
                          () => {},
                    ],
                    secondaryBackgroundColor: Colors.grey[900],
                    secondaryForegroundColor: Colors.white,
                    primaryBackgroundColor: Colors.grey[900],
                    primaryForegroundColor: grad1,
                  ),

                )),


              ],

            ),

          ),
          Expanded(
            child: Container(
              child: SingleChildScrollView(
               // physics: NeverScrollableScrollPhysics(),

                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personal Info.', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),textScaleFactor: 1.1,),
                      Divider(height: 15.0,thickness: 4.0,color: grad1,endIndent: 0.6*_width,),
                      SizedBox(height: 5.0,),
                      Text('phone number:',style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: grey)),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14.0,color: grad1),
                          SizedBox(width: 5.0,),
                          Text(phoneNumber, style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w400, color: Colors.black)),
                        ],
                      ),
                      SizedBox(height: 5.0,),
                      Text('Email Address:',style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: grey)),
                      Row(
                        children: [
                          Icon(Icons.email, size: 14.0,color: grad1,),
                          SizedBox(width: 5.0,),
                          Text(currentFirebaseUser!.email!, style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w400, color: Colors.black)),
                        ],
                      ),
                      SizedBox(height: 20.0,),
                      Text('Car Info.', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),textScaleFactor: 1.1,),
                      Divider(height: 15.0,thickness: 4.0,color: grad1,endIndent: 0.6*_width,),
                      SizedBox(height: 5.0,),
                      Text('Car Model:',style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: grey)),
                      Row(
                        children: [
                          Icon(CupertinoIcons.car_detailed, size: 14.0,color: grad1),
                          SizedBox(width: 5.0,),
                          Text(car_model, style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w400, color: Colors.black)),
                        ],
                      ),
                      Text('Car Number:',style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: grey)),
                      Row(
                        children: [
                          Icon(CupertinoIcons.number_square_fill, size: 14.0,color: grad1),
                          SizedBox(width: 5.0,),
                          Text(car_number, style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w400, color: Colors.black)),
                        ],
                      ),
                      SizedBox(height: 5.0,),
                      Text('Car Color:',style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: grey)),
                      Row(
                        children: [
                          Icon(Icons.color_lens, size: 14.0,color: grad1,),
                          SizedBox(width: 5.0,),
                          Text(car_color, style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w400, color: Colors.black)),
                        ],
                      ),
                      SizedBox(height: 20.0,),
                      Text('Trips Info.', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),textScaleFactor: 1.1,),
                      Divider(height: 15.0,thickness: 4.0,color: grad1,endIndent: 0.6*_width,),
                      SizedBox(height: 5.0,),
                      Text('Total completed trips:',style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: grey)),
                      Row(
                        children: [
                          Icon(CupertinoIcons.location_fill, size: 14.0,color: grad1),
                          SizedBox(width: 5.0,),
                          Text(total_trips.toString(), style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w400, color: Colors.black)),
                        ],
                      ),
                      Text('Average Rate:',style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: grey)),
                      Row(
                        children: [
                          Icon(CupertinoIcons.star_fill, size: 14.0,color: grad1),
                          SizedBox(width: 5.0,),
                          Text(avgRate.toString(), style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w400, color: Colors.black)),
                        ],
                      ),
                      SizedBox(height: 5.0,),
                      Text('Total Earnings:',style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: grey)),
                      Row(
                        children: [
                          Icon(CupertinoIcons.creditcard_fill, size: 14.0,color: grad1,),
                          SizedBox(width: 5.0,),
                          Text(earnings.toString(), style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w400, color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )



        ],
      ),
    );
  }

  void _getDriverDetails()async
  {
    await currentDriverRef.once().then((DataSnapshot dataSnapshot)
    {
      if(dataSnapshot.value!= null) {
        if (dataSnapshot.value["avg_rating"] == null) {
          setState(() {
            avgRate = 5.0;
          });
        }
        else if (dataSnapshot.value["avg_rating"] != null) {
          setState(() {
            avgRate = double.parse(dataSnapshot.value["avg_rating"].toString());
          });
        }

        if (dataSnapshot.value["total_trips"] == null) {
          setState(() {
            total_trips = 0;
          });
        }
        else if (dataSnapshot.value["total_trips"] != null) {
          setState(() {
            total_trips =
                int.parse(dataSnapshot.value["total_trips"].toString());
          });
        }

        if (dataSnapshot.value["phone"] == null) {
          setState(() {
            phoneNumber = 'not defined';
          });
        }
        else if (dataSnapshot.value["phone"] != null) {
          setState(() {
            phoneNumber = dataSnapshot.value["phone"].toString();
          });
        }

        if (dataSnapshot.value["name"] == null) {
          setState(() {
            name = 'undefined';
          });
        }
        else if (dataSnapshot.value["name"] != null) {
          setState(() {
            name = dataSnapshot.value["name"].toString();
          });
        }

        if (dataSnapshot.value["earnings"] == null) {
          setState(() {
            earnings = 0.0;
          });
        }
        else if (dataSnapshot.value["earnings"] != null) {
          setState(() {
            earnings = double.parse(dataSnapshot.value["earnings"].toString());
          });
        }

        if (dataSnapshot.value["carDetails"] == null) {
          setState(() {
            car_number = 'not defined';
            car_model = 'not defined';
            car_color = 'not defined';
          });
        }
        else if (dataSnapshot.value["carDetails"] != null) {
          if (dataSnapshot.value["carDetails"]["car_number"] != null) {
            setState(() {
              car_number =
                  dataSnapshot.value["carDetails"]["car_number"].toString();
            });
          }
          else {
            setState(() {
              car_number = 'undefined';
            });
          }

          if (dataSnapshot.value["carDetails"]["car_model"] != null) {
            setState(() {
              car_model =
                  dataSnapshot.value["carDetails"]["car_model"].toString();
            });
          }
          else {
            setState(() {
              car_model = 'undefined';
            });
          }

          if (dataSnapshot.value["carDetails"]["car_number"] != null) {
            setState(() {
              car_color =
                  dataSnapshot.value["carDetails"]["car_color"].toString();
            });
          }
          else {
            setState(() {
              car_color = 'undefined';
            });
          }
        }
      }
      else
      {
        setState(() {
          avgRate = 0;
          total_trips= 0;
          phoneNumber = 'not defined';
          name = 'not defined';
          car_color='not defined';
          car_model='not defined';
          car_number='not defined';
          earnings =0;
        });
      }
    });
  }

}

