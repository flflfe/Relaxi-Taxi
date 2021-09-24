import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:relaxi_driver/AllScreens/RegistrationScreen.dart';
import 'package:relaxi_driver/AllScreens/mainscreen.dart';
import 'package:relaxi_driver/AllWidgets/dialogueBox.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:relaxi_driver/AllWidgets/buttons.dart';
import '../main.dart';

class LoginScreen extends StatelessWidget {

  LoginScreen({Key? key}) : super(key: key);
  static const String id_screen="login";
  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    void ValidateInput(){
      if(!emailTextEditingController.text.contains('@'))
      {
        displayToastMsg( "Email address is not valid", context);

      }
      else if(passwordTextEditingController.text.isEmpty){
        displayToastMsg( "Password is missing", context);

      }
      else{
        LoginAndAuthenticateUser(context);
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
                Center(
                  child: Column(
                    mainAxisSize:MainAxisSize.min,

                    children: [
                  Text(
                    "Login as a Driver",
                    style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: grey),
                  ),
                  SizedBox(height: 25.0),
                  TextField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
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
                  SubmitButton(onPressed: ValidateInput,txt: "Sign In",),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Doesn't have an account?",
                        style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: grey),

                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pushNamedAndRemoveUntil(context, RegistrationScreen.id_screen, (route) => false);
                        },
                        child:Text('Sign Up',
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
                ),







              ],
            ),
          ),
        ),
      ),
    ),
    );

  }
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  LoginAndAuthenticateUser(BuildContext context) async{
    showDialog(context: context,
        barrierDismissible: false
        ,builder:(BuildContext context)
    {
      return DialogueBox(message: "Authenticating");
    });
    final User? firebaseUser = (await _firebaseAuth.signInWithEmailAndPassword(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text).catchError((errMsg){
          Navigator.pop(context);
      displayToastMsg("ERROR!! "+errMsg.toString(), context);
    }) ).user;

    if(firebaseUser != null)
    {
      //save user info to db

      driversRef.child(firebaseUser.uid).once().then((DataSnapshot snap){
      if(snap.value!= null)
        {


          Navigator.pushNamedAndRemoveUntil(context, MainScreen.id_screen, (Route<dynamic> route) => false);
          displayToastMsg("Welcome Back ^_^",context);


        }
      else{
        Navigator.pop(context);
        _firebaseAuth.signOut();
        displayToastMsg("Your Email or Password is Wrong, Try again",context);

      }
      });


    }
    else{
      //error message
      Navigator.pop(context);
      displayToastMsg("Failed to Sign in, Try again later",context);
    }
  }
}
