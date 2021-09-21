import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relaxi_driver/AllScreens/RegistrationScreen.dart';
import 'package:relaxi_driver/AllScreens/mainscreen.dart';
import 'package:relaxi_driver/AllWidgets/buttons.dart';
import 'package:relaxi_driver/Configurations/configMaps.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:relaxi_driver/main.dart';

class CarInfoScreen extends StatelessWidget {
static const String idScreen = "carInfo";
TextEditingController carModelTextEditingController= TextEditingController();
TextEditingController carNumberTextEditingController= TextEditingController();
TextEditingController carColorTextEditingController= TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0,vertical: 20.0),
            child: Center(
              child: Column(
                mainAxisSize:MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Image.asset('assets/logo_image.png',width: 0.25*_width,),
                  SizedBox(height: 0.15*_height,),
                  Column(
                    mainAxisSize:MainAxisSize.min,

                    children: [
                      Text(
                        "Enter Car Details",
                        style: GoogleFonts.montserrat(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: grey),
                      ),
                      SizedBox(height: 25.0),
                      TextField(
                        controller: carModelTextEditingController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.person, color: yellow,),
                          labelText: "Car Model",
                          labelStyle: GoogleFonts.montserrat(
                            fontSize: 14,
                            textStyle: TextStyle(color: grey ),

                          ),
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: 10.0,
                            textStyle: TextStyle(color: grey ),),
                        ),
                      ),
                      SizedBox(height: 25.0),
                      TextField(
                        controller: carNumberTextEditingController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.email_outlined, color: yellow,),
                          labelText: "Car Number",
                          labelStyle: GoogleFonts.montserrat(
                            fontSize: 14,
                            textStyle: TextStyle(color: grey ),
                          ),
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: 10.0,
                            textStyle: TextStyle(color: grey ),),
                        ),
                      ),
                      SizedBox(height: 25.0),
                      TextField(
                        controller: carColorTextEditingController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.phone_enabled_outlined, color: yellow,),
                          labelText: "Car Color",
                          labelStyle: GoogleFonts.montserrat(
                            fontSize: 14,
                            textStyle: TextStyle(color: grey ),
                          ),
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: 10.0,
                            textStyle: TextStyle(color: grey ),),
                        ),
                      ),
                      SizedBox(height: (55/xd_height)*_height,),

                      SubmitButton(onPressed: (){validateInput(context);},txt: "Next ->",),


                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  void saveCarInfo(context)
  {
    String userId= currentFirebaseUser!.uid;
    Map carInfoMap={
      "car_color":carColorTextEditingController.text,
      "car_number":carNumberTextEditingController.text,
      "car_model":carModelTextEditingController.text
    };
    driversRef.child(userId).child("carDetails").set(carInfoMap);
    Navigator.pushNamedAndRemoveUntil(context, MainScreen.id_screen, (route) => false);

  }
  void validateInput(context){
   if(carModelTextEditingController.text.isEmpty||
   carNumberTextEditingController.text.isEmpty||
   carColorTextEditingController.text.isEmpty)
     {
       displayToastMsg("please fill all the required information", context);
     }
   else{
     saveCarInfo(context);
   }
  }

}
