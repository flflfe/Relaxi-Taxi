
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/AllScreens/loginScreen.dart';
import 'package:flutter_app/AllScreens/mainscreen.dart';
import 'package:flutter_app/AllWidgets/buttons.dart';
import 'package:flutter_app/AllWidgets/dialogueBox.dart';
import 'package:flutter_app/constants/all_cons.dart';
import 'package:flutter_app/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
class RegistrationScreen extends StatelessWidget {

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController phoneTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  RegistrationScreen({Key? key}) : super(key: key);
  static const String id_screen="register";


  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    void ValidateInput(){
      if(nameTextEditingController.text.trim().length<4)
      {
        displayToastMsg("User name must be at least 3 characters",context);
      }
      else if(!emailTextEditingController.text.contains('@'))
      {
        displayToastMsg( "Email address is not valid", context);

      }
      else if(passwordTextEditingController.text.trim().length<9)
      {
        displayToastMsg( "Password must be at least 8 characters", context);

      }
      else if(phoneTextEditingController.text.trim().length!=11)
      {
        displayToastMsg( "Invalid Phone number", context);

      }
      else
      {
        RegisterNewUser(context);
      }
    }
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
                        "Register as a Rider",
                        style: GoogleFonts.montserrat(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: grey),
                      ),
                      SizedBox(height: 25.0),
                      TextField(
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.name,
                        controller: nameTextEditingController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.person, color: yellow,),
                          labelText: "User Name",
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
                        keyboardType: TextInputType.emailAddress,
                        controller: emailTextEditingController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.email_outlined, color: yellow,),
                          labelText: "Email Address",
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
                        keyboardType: TextInputType.phone,
                        controller: phoneTextEditingController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.phone_enabled_outlined, color: yellow,),
                          labelText: "Phone Number",
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
                        controller: passwordTextEditingController,
                        obscureText: true,
                        decoration: InputDecoration(
                          icon: Icon(Icons.vpn_key_outlined, color: yellow,),
                          labelText: "Password",
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

                      SubmitButton(onPressed: ValidateInput,txt: "Sign Up",),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: grey),

                          ),
                          TextButton(
                            onPressed: (){
                              Navigator.pushNamedAndRemoveUntil(context, LoginScreen.id_screen, (route) => false);

                            },
                            child:Text('Sign In',
                              style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,
                                  color: grad1),
                            ),

                          ),
                        ],
                      )


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


void RegisterNewUser (BuildContext context)async
{
  showDialog(context: context,
      barrierDismissible: false,
    builder:(BuildContext context){
    return DialogueBox(message: "Registering",);
  });
  final User? firebaseUser = (await _firebaseAuth.createUserWithEmailAndPassword(
      email: emailTextEditingController.text,
      password: passwordTextEditingController.text).catchError((errMsg){
        Navigator.pop(context);
        displayToastMsg("ERROR!! "+errMsg.toString(), context);
  }) ).user;
if(firebaseUser != null)
  {
    //save user info to db

    Map userDataMap= {
      "name": nameTextEditingController.text.trim(),
      "email":emailTextEditingController.text.trim(),
      "phone":phoneTextEditingController.text.trim(),
      "total_trips":"0",

    };
    userRef.child(firebaseUser.uid).set(userDataMap);
    displayToastMsg("Successfully Created a New User !",context);
    Navigator.pushNamedAndRemoveUntil(context, MainScreen.id_screen, (route) => false);

  }
else{
  //error message
  Navigator.pop(context);
  displayToastMsg("Failed to Create New User",context);
    }
  }
}
displayToastMsg(String Message, BuildContext context){

  Fluttertoast.showToast(msg: Message);
}