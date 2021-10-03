import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:relaxi_driver/AllScreens/RegistrationScreen.dart';
import 'package:relaxi_driver/AllScreens/mainscreen.dart';
import 'package:relaxi_driver/AllWidgets/dialogueBox.dart';
import 'package:relaxi_driver/AllWidgets/errorDialogue.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:relaxi_driver/AllWidgets/buttons.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {

  LoginScreen({Key? key}) : super(key: key);
  static const String id_screen="login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();
  bool started_typing_email=false;
  bool started_typing_password=false;
  bool showPass=false;
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0,vertical: 20.0),
        child: Center(
          child: Column(
            children: [
              Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset('assets/logo_image.png',width: 0.35*_width,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back!",
                          style: GoogleFonts.pacifico(
                              fontWeight: FontWeight.w500,
                              color:grad1),
                          textScaleFactor: 2.0,
                        ),
                        Text(
                          "  Login as a driver",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.5),),
                          textAlign: TextAlign.start,
                          textScaleFactor: 1.0,
                        )
                      ],
                    ),
                  ),
                ],
              )),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(

                          controller: emailTextEditingController,
                          keyboardType: TextInputType.emailAddress,
                          onTap: (){
                            setState(() {
                              started_typing_email=true;
                              started_typing_password=false;
                            });
                          },
                          onSubmitted: (val){
                            setState(() {
                              started_typing_email=false;
                            });
                          },
                          cursorHeight: 25,
                          cursorColor: grad1,
                          style: GoogleFonts.montserrat(fontSize: 16.0),
                          decoration: InputDecoration(
                            icon: Icon(Icons.email_outlined, color: yellow,),
                            labelText: "Email Address",
                            labelStyle: GoogleFonts.montserrat(
                              textStyle: TextStyle(color: grey.withOpacity(0.5) ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade300,width: 1.5)
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: grad1,width: 2.0)
                            ),
                            filled: true,
                            fillColor: started_typing_email&&!started_typing_password?
                            Colors.yellow.withOpacity(0.1):Colors.transparent,
                            suffixIcon: started_typing_email&&!started_typing_password?
                            GestureDetector(
                                onTap: (){
                                  emailTextEditingController.clear();
                                },
                                child: Icon(CupertinoIcons.xmark,color: grad1,size: 20.0,)
                            ):null,
                          ),
                        ),
                        SizedBox(height: 15.0),
                        TextField(
                          controller: passwordTextEditingController,
                          obscureText: !showPass,
                          onTap: (){
                            setState(() {
                              started_typing_password=true;
                              started_typing_email=false;
                            });
                          },
                          onSubmitted: (val){
                            setState(() {
                              started_typing_password=false;
                              showPass=false;
                            });
                          },
                          style: GoogleFonts.montserrat(fontSize: 16.0),
                          cursorHeight: 25,
                          cursorColor: grad1,
                          decoration: InputDecoration(
                            icon: Icon(Icons.vpn_key_outlined, color: yellow,),
                            labelText: "Password",
                            labelStyle: GoogleFonts.montserrat(
                              textStyle: TextStyle(color: grey.withOpacity(0.5) ),
                            ),
                            suffixIcon: started_typing_password&&!started_typing_email?
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  showPass=!showPass;
                                });
                              },
                                child: Icon(showPass?CupertinoIcons.eye_slash:CupertinoIcons.eye,color: grad1,size: 20.0,)
                            ):null,
                            filled: true,
                            fillColor: !started_typing_email&&started_typing_password?
                            Colors.yellow.withOpacity(0.1):Colors.transparent,
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade300,width: 1.5)
                              ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: grad1,width: 2.0)
                            )

                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SubmitButton(onPressed: ValidateInput,txt: "Sign In",),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "New user?",
                                style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                              TextButton(
                                onPressed: (){
                                  Navigator.pushNamedAndRemoveUntil(context, RegistrationScreen.id_screen, (route) => false);
                                },
                                child:Text('Sign Up',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
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
              /*Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SubmitButton(onPressed: ValidateInput,txt: "Sign In",),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New user?",
                            style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black.withOpacity(0.6)),
                          ),
                          TextButton(
                            onPressed: (){
                              Navigator.pushNamedAndRemoveUntil(context, RegistrationScreen.id_screen, (route) => false);
                            },
                            child:Text('Sign Up',
                              style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,
                                  color: grad1),
                            ),

                          ),
                        ],
                      )
                    ],
                  ),
              )*/

            ],
          ),
        ),
      ),
    ),
    resizeToAvoidBottomInset: false,
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
        password: passwordTextEditingController.text).catchError((errMsg)async{
          Navigator.pop(context);
          await showDialog(context: context,
          barrierDismissible: false,
          builder:(BuildContext context){
            return ErrorDialogue(message: errMsg.toString(),);
          });
          displayToastMsg("ERROR!! "+errMsg.toString(), context);
    }) ).user;

    if(firebaseUser != null)
    {
      //save user info to db

      driversRef.child(firebaseUser.uid).once().then((DataSnapshot snap){
      if(snap.value!= null)
        {
          Navigator.pushNamedAndRemoveUntil(context, MainScreen.id_screen, (Route<dynamic> route) => false);
          displayToastMsg("Welcome Back 👋",context);
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
