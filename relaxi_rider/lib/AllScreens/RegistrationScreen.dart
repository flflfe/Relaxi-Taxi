
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/AllScreens/loginScreen.dart';
import 'package:flutter_app/AllScreens/mainscreen.dart';
import 'package:flutter_app/AllScreens/phoneVerification.dart';
import 'package:flutter_app/AllWidgets/buttons.dart';
import 'package:flutter_app/AllWidgets/dialogueBox.dart';
import 'package:flutter_app/constants/all_cons.dart';
import 'package:flutter_app/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
class RegistrationScreen extends StatefulWidget {


  RegistrationScreen({Key? key}) : super(key: key);
  static const String id_screen="register";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController nameTextEditingController = TextEditingController();

  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController phoneTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingControllerConfirm = TextEditingController();


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool startedUserName=false;

  bool startedEmail=false;

  bool startedPassword=false;

  bool startedPhone=false;

  bool startedPasswordConfirm=false;

  bool showPass=false;

  bool showPassConfirm=false;

  bool passConfirmValidate=true;
  bool passValidate=true;
  bool emailValidate=true;
  bool userNameValidate=true;
  bool genderValidate=true;

  String _gender='gender';

  String _userNameError='';
  String _emailError='';
  String _passError='';
  String _confirmPassError='';
  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    void ValidateInput(){
      setState(() {
        passConfirmValidate=true;
        passValidate=true;
        emailValidate=true;
        userNameValidate=true;
        genderValidate=true;
      });
      bool hasError=false;
      if(nameTextEditingController.text.trim().length<4)
      {
        setState(() {
          userNameValidate=false;
          _userNameError="Username must be at least 3 characters";
        });
        hasError=true;
      }
      if(!emailTextEditingController.text.contains('@'))
      {
        setState(() {
          emailValidate=false;
          _emailError="Email address is not valid";
        });
        hasError=true;

      }
      if(passwordTextEditingController.text.trim().length<9)
      {
        setState(() {
          passValidate=false;
          _passError="Password must be at least 8 characters";
        });
        hasError=true;

      }
      else if(passwordTextEditingController.text!=passwordTextEditingControllerConfirm.text)
      {
        setState(() {
          passConfirmValidate=false;
          _confirmPassError="Passwords don't match";
        });
        hasError=true;

      }
      if(_gender=='gender')
      {
        displayToastMsg( "please choose a gender!", context);
        hasError=true;
      }
      if(hasError==false)
      {
        RegisterNewUser(context);
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0,vertical: 20.0),
          child: Center(
            child: Column(
              mainAxisSize:MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset('assets/logo_image.png',width: 0.35*_width,),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, new rider!",
                              style: GoogleFonts.pacifico(
                                  fontWeight: FontWeight.w500,
                                  color:grad1),
                              textScaleFactor: 2.0,
                            ),
                            Text(
                              " create a new account",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade500,),
                              textAlign: TextAlign.start,
                              textScaleFactor: 1.0,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    child: Center(
                      child: Scrollbar(
                        interactive: true,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 25.0,),
                              //userName
                              TextField(
                                textCapitalization: TextCapitalization.sentences,
                                keyboardType: TextInputType.name,
                                controller: nameTextEditingController,
                                onTap: (){
                                  setState(() {
                                    startedUserName=true;
                                    startedEmail=false;
                                    startedPassword=false;
                                    startedPhone=false;
                                    startedPasswordConfirm=false;
                                  });
                                },
                                onSubmitted: (val){
                                  setState(() {
                                    startedUserName=false;
                                  });
                                },
                                cursorHeight: 25,
                                cursorColor: grad1,
                                style: GoogleFonts.montserrat(fontSize: 16.0),
                                decoration: InputDecoration(
                                  isDense: true,
                                  errorText: userNameValidate?null:_userNameError,
                                  icon: Icon(CupertinoIcons.person_solid, color: yellow,),
                                  labelText: "User Name",
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
                                  fillColor: startedUserName?
                                  (userNameValidate?Colors.yellow.withOpacity(0.1):Colors.red.withOpacity(0.1)):
                                  (userNameValidate?Colors.transparent:Colors.red.withOpacity(0.1)),
                                  suffixIcon: startedUserName?
                                  GestureDetector(
                                      onTap: (){
                                        nameTextEditingController.clear();
                                      },
                                      child: Icon(CupertinoIcons.xmark,color: grad1,size: 20.0,)
                                  ):null,
                                ),
                              ),
                              SizedBox(height: 25.0),
                              //email
                              TextField(
                                keyboardType: TextInputType.emailAddress,
                                controller: emailTextEditingController,
                                onTap: (){
                                  setState(() {
                                    startedUserName=false;
                                    startedEmail=true;
                                    startedPassword=false;
                                    startedPhone=false;
                                    startedPasswordConfirm=false;
                                  });
                                },
                                onSubmitted: (val){
                                  setState(() {
                                    startedEmail=false;
                                  });
                                },
                                cursorHeight: 25,
                                cursorColor: grad1,
                                style: GoogleFonts.montserrat(fontSize: 16.0),
                                decoration: InputDecoration(
                                  isDense: true,
                                  errorText: emailValidate?null:_emailError,
                                  icon: Icon(Icons.email, color: yellow,),
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
                                  fillColor: startedEmail?
                                  (emailValidate?Colors.yellow.withOpacity(0.1):Colors.red.withOpacity(0.1)):
                                  (emailValidate?Colors.transparent:Colors.red.withOpacity(0.1)),
                                  suffixIcon: startedEmail?
                                  GestureDetector(
                                      onTap: (){
                                        emailTextEditingController.clear();
                                      },
                                      child: Icon(CupertinoIcons.xmark,color: grad1,size: 20.0,)
                                  ):null,
                                ),
                              ),
                              SizedBox(height: 25.0),
                              //password
                              TextField(
                                controller: passwordTextEditingController,
                                obscureText: !showPass,
                                onTap: (){
                                  setState(() {
                                    startedUserName=false;
                                    startedEmail=false;
                                    startedPassword=true;
                                    startedPhone=false;
                                    startedPasswordConfirm=false;
                                  });
                                },
                                onSubmitted: (val){
                                  setState(() {
                                    startedPassword=false;
                                    showPass=false;
                                  });
                                },
                                cursorHeight: 25,
                                cursorColor: grad1,
                                style: GoogleFonts.montserrat(fontSize: 16.0),
                                decoration: InputDecoration(
                                    isDense: true,
                                    errorText: passValidate?null:_passError,
                                    icon: Icon(CupertinoIcons.lock_fill, color: yellow,),
                                    labelText: "Password",
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
                                    fillColor: startedPassword?
                                    (passValidate?Colors.yellow.withOpacity(0.1):Colors.red.withOpacity(0.1)):
                                    (passValidate?Colors.transparent:Colors.red.withOpacity(0.1)),
                                    suffixIcon: startedPassword?
                                    GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            showPass=!showPass;
                                          });
                                        },
                                        child: Icon(showPass?CupertinoIcons.eye_slash:CupertinoIcons.eye,color: grad1,size: 20.0,)
                                    ):null
                                ),
                              ),
                              SizedBox(height: 25.0),
                              //password Confirm
                              TextField(
                                controller: passwordTextEditingControllerConfirm,
                                obscureText: !showPassConfirm,
                                onTap: (){
                                  setState(() {
                                    startedUserName=false;
                                    startedEmail=false;
                                    startedPassword=false;
                                    startedPhone=false;
                                    startedPasswordConfirm=true;
                                  });
                                },
                                onSubmitted: (val){
                                  setState(() {
                                    startedPasswordConfirm=false;
                                    showPassConfirm=false;
                                  });
                                },
                                cursorHeight: 25,
                                cursorColor: grad1,
                                style: GoogleFonts.montserrat(fontSize: 16.0),
                                decoration: InputDecoration(
                                    errorText: passConfirmValidate?null:_confirmPassError,
                                    isDense: true,
                                    icon: Icon(CupertinoIcons.lock_fill, color: yellow,),
                                    labelText: "Password Confirm",
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
                                    fillColor: startedPasswordConfirm?
                                    (passConfirmValidate?Colors.yellow.withOpacity(0.1):Colors.red.withOpacity(0.1)):
                                    (passConfirmValidate?Colors.transparent:Colors.red.withOpacity(0.1)),
                                    suffixIcon: startedPasswordConfirm?
                                    GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            showPassConfirm=!showPassConfirm;
                                          });
                                        },
                                        child: Icon(showPassConfirm?CupertinoIcons.eye_slash:CupertinoIcons.eye,color: grad1,size: 20.0,)
                                    ):null
                                ),
                              ),
                              SizedBox(height: 25.0),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Gender: ', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold,color: grad1),),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        activeColor: grad1,
                                        value: 'Male',
                                        groupValue: _gender,
                                        onChanged: (value){
                                          setState(() {
                                            print(value);
                                            _gender=value as String;
                                          });
                                        },
                                      ),
                                      Text('♂️ Male',style: GoogleFonts.montserrat(color: Colors.black))
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        activeColor: grad1,
                                        value: 'Female',
                                        groupValue: _gender,
                                        onChanged: (value){
                                          setState(() {
                                            print(value);
                                            _gender=value as String;
                                          });
                                        },
                                      ),
                                      Text('♀️Female️',style: GoogleFonts.montserrat(color: Colors.black),)
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 100.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SubmitButton(onPressed: ValidateInput,txt: "Register",),
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
                )
              ],
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset:false,

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
      "gender":_gender
    };
    userRef.child(firebaseUser.uid).set(userDataMap);
    displayToastMsg("Successfully Created a New User !",context);
    print('ay hagaaaa');
    Navigator.pushNamedAndRemoveUntil(context, PhoneVerification.id_screen, (route) => false);

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