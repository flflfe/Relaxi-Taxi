import 'dart:async';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_app/AllScreens/RegistrationScreen.dart';
import 'package:flutter_app/AllWidgets/buttons.dart';
import 'package:flutter_app/AllWidgets/dialogueBox.dart';
import 'package:flutter_app/AllWidgets/errorDialogue.dart';
import 'package:flutter_app/Configurations/configMaps.dart';
import 'package:flutter_app/constants/all_cons.dart';

import '../main.dart';
import 'mainscreen.dart';

class PhoneVerification extends StatefulWidget {
  const PhoneVerification({Key? key}) : super(key: key);
  static const String id_screen = "phoneNumber";

  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  TextEditingController carModelTextEditingController= TextEditingController();

  TextEditingController carNumberTextEditingController= TextEditingController();

  String? carColor;

  String? carBrand;

  String? carType;

  bool carBrandValid=true;

  bool carModelValid=true;

  bool carNumberValid=true;

  bool carColorValid=true;

  bool carTypeValid=true;

  bool carModelSelected=false;

  bool carNumberSelected=false;

  String _error='This field is required';


  TextEditingController phoneTextEditingController = TextEditingController();
  bool phoneSelected=false;
  bool phoneValid=true;
  bool smsSent=false;
  int current_page=0;
  FirebaseAuth _auth = FirebaseAuth.instance;
  void validatePhone() async
  {
    setState(() {
      phoneValid=true;
    });
    if((phoneTextEditingController.text.startsWith("1")&&phoneTextEditingController.text.length!=10)||
        (phoneTextEditingController.text.startsWith("0")&&phoneTextEditingController.text.length!=11)||
        (double.tryParse(phoneTextEditingController.text)==null))
      {
        setState(() {
          phoneValid=false;
        });
      }
    else {
      if(!(phoneTextEditingController.text.startsWith("11")||
        phoneTextEditingController.text.startsWith("15")||
        phoneTextEditingController.text.startsWith("10")||
        phoneTextEditingController.text.startsWith("12")||
        phoneTextEditingController.text.startsWith("011")||
        phoneTextEditingController.text.startsWith("012")||
        phoneTextEditingController.text.startsWith("010")||
        phoneTextEditingController.text.startsWith("015")
    ))
      {
        setState(() {
          phoneValid=false;
        });
      }
    else{
      setState(() {
        phoneValid=true;
      });
      //add after testing
      /*showDialog(context: context,
          barrierDismissible: false,
          builder:(BuildContext context){
            return DialogueBox(message: "Sending OTP",);
          }).whenComplete(() => print('dialogue dismissed'));*/
      await verifyPhone();
      //remove after testing
      buttonCarouselController.nextPage(
          duration: Duration(milliseconds: 500)
          , curve: Curves.easeInOutQuad
      );
      setState(() {
        current_page++;
      });
    }
    }
  }
  String? phoneNo;
  String smsOTP="";
  String? verificationId;
  String errorMessage = '';
  String smsOtpSent="not set yet";
  bool isClicked=false;
  String countryCode="";
  bool otpDialogueDismissed=false;
  TextEditingController textEditingController= TextEditingController();
  //StreamController<ErrorAnimationType>? errorController;
  OtpTimerButtonController controller = OtpTimerButtonController();

  _requestOtp() async{
    controller.loading();
    await verifyPhone(resend: true);
  }
  @override
  void dispose() {
    //errorController!.close();
    carModelTextEditingController.dispose();
    carNumberTextEditingController.dispose();
    phoneTextEditingController.dispose();
    textEditingController.dispose();
    super.dispose();
  }
  Future<void> verifyPhone({bool resend=false}) async {
    final PhoneCodeSent smsOTPSent = (String verId, int? forceCodeResend) {
      this.verificationId = verId;
      if(!resend) {
        if(otpDialogueDismissed==false) {
          Navigator.pop(context);
          textEditingController.clear();
          buttonCarouselController.nextPage(
              duration: Duration(milliseconds: 500)
              , curve: Curves.easeInOutQuad
          );
          setState(() {
            current_page++;
          });
          displayToastMsg('OTP has been sent to your number', context);
        }
        otpDialogueDismissed=false;

      }
      else
      {
        controller.startTimer();
        displayToastMsg('OTP has been sent to your number', context);
      }

    };
    try {
      setState(() {
        countryCode=phoneTextEditingController.text.startsWith("0")?"+2":"+20";
      });
      await _auth.verifyPhoneNumber(
          phoneNumber: countryCode+phoneTextEditingController.text, // PHONE NUMBER TO SEND OTP
          //remove after testing
          autoRetrievedSmsCodeForTesting: '111111',
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          //codeSent: smsOTPSent,  add this after testing
          codeSent: (String verId, int? forceCodeResend){},
          timeout: const Duration(seconds: 30),
          verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
            print(phoneAuthCredential.smsCode);
            setState(() {
              smsOtpSent=phoneAuthCredential.smsCode!;
            });
          },
          verificationFailed: (FirebaseAuthException exceptio) {
            print('${exceptio.message}');
          });
    } catch (e) {
      print(e.toString());
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //errorController = StreamController<ErrorAnimationType>();
  }

  CarouselController buttonCarouselController = CarouselController();
  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: current_page==0||current_page==2?null:IconButton(icon: Icon(CupertinoIcons.back,color: Colors.black,size: 20.0,),
        onPressed: (){
          buttonCarouselController.previousPage();
          setState(() {
            current_page--;
          });
        },
        ),
        title: Text('Complete Profile', style: GoogleFonts.montserrat(color: Colors.grey.shade400,fontSize: 14.0),),
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/logo_image.png',width: 50.0,),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CarouselSlider(
          items: [
            //phone number
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0,vertical: 20.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Image.asset('assets/2.png',width: 50.0,),
                        Text(
                          "Add Phone Number",
                          style: GoogleFonts.pacifico(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: grad1),
                        ),
                      ],
                    ),
                    Image.asset('assets/add_phone.png',width: 0.7*_width,),
                    Container(
                      child: Column(
                        mainAxisAlignment:MainAxisAlignment.start,
                        children: [
                          TextField(
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.phone,
                            controller: phoneTextEditingController,
                            cursorHeight: 25,
                            cursorColor: grad1,
                            style: GoogleFonts.montserrat(fontSize: 16.0),
                            onTap: (){
                              setState(() {
                                phoneSelected=true;
                              });
                            },
                            onSubmitted: (val){
                              setState(() {
                                phoneSelected=false;

                              });
                            },
                            decoration: InputDecoration(
                              icon: Container(
                                width: 50.0,
                                child: Row(
                                  children: [
                                    Expanded(child: Image.asset('assets/egypt.png',)),
                                    Expanded(child: Text('+20'))
                                  ],
                                ),
                              ),
                              labelText: "Phone Number",
                              labelStyle: GoogleFonts.montserrat(
                                textStyle: TextStyle(color: grey.withOpacity(0.5) ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade300,width: 1.5)
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: grad1,width: 2.0)
                              ),
                              filled: false,
                              suffixIcon: phoneSelected?
                              GestureDetector(
                                  onTap: (){
                                    phoneTextEditingController.clear();
                                  },
                                  child: Icon(CupertinoIcons.xmark,color: grad1,size: 20.0,)
                              ):null,
                              errorText: phoneValid?null:"Enter a valid phone number!",
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red,width: 2.0)
                              ),
                            ),
                          ),
                          SizedBox(height: 40,),
                          SubmitButton(onPressed: (){
                            validatePhone();
                          },txt: "Verify",),
                          SizedBox(height: 4,),
                          Text('you \'ll recieve an sms for verification',style: TextStyle(
                              color: grey.withOpacity(0.8)
                          ),)

                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0,vertical: 20.0),
              child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Image.asset('assets/3.png',width: 50.0,),
                          Text(
                            "OTP Verification",
                            style: GoogleFonts.pacifico(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                color: grad1),
                          ),
                        ],
                      ),
                      Expanded(flex:4,child: Image.asset('assets/otp.png',width: 0.7*_width,)),
                      SizedBox(height: 0.0,),
                      Expanded(child: Row(

                        children: [
                          Expanded(child: Text('We have sent a verification code to "+20${phoneTextEditingController.text}" please enter the otp sent to you or press resend if you haven\'t recieve it',
                          style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold,),
                            textAlign: TextAlign.center,
                          ))
                        ],
                      )),
                      Expanded(
                        child: PinCodeTextField(
                          appContext: context,
                          pastedTextStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          length: 6,
                          obscureText: true,
                          obscuringCharacter: '*',
                          obscuringWidget: Icon(Icons.lock,color: grad1,),
                          blinkWhenObscuring: true,
                          animationType: AnimationType.scale,
                          validator: (v) {
                            if (v!.length < 6) {
                              return "fill all the fields, please";
                            } else {
                              return null;
                            }
                          },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: Colors.white,
                            borderWidth: 1.0,
                            disabledColor: Colors.white70,
                            selectedColor: Colors.yellow,
                            activeColor: Colors.yellow,
                            selectedFillColor: grad1,
                            inactiveFillColor: Colors.white.withOpacity(0.9),
                            inactiveColor: Colors.white
                          ),
                          autoDisposeControllers: false,
                          backgroundColor: Colors.transparent,
                          cursorColor: Colors.black,
                          animationDuration: Duration(milliseconds: 200),
                          enableActiveFill: true,
                          //errorAnimationController: errorController,
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          boxShadows: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              color: Colors.grey.shade400,
                              blurRadius: 5,
                            )
                          ],
                          onCompleted: (val) {
                            print(val);
                            this.smsOTP = val;
                          },
                          onSubmitted: (val){
                            if(val==this.smsOtpSent)
                              {
                                print('matched');
                              }
                            else
                              {
                                print('dis match');
                              }
                          },
                          // onTap: () {
                          //   print("Pressed");
                          // },
                          onChanged: (value) {
                          },
                          beforeTextPaste: (text) {
                            print("Allowing to paste $text");
                            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                            //but you can show anything you want here, like your pop up saying wrong paste format or etc
                            return true;
                          },
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            ElevatedButton(onPressed: ()async{
                              if(this.smsOTP==smsOtpSent)
                              {
                                print('matched');
                                savePhoneNumber(context);
                                print('done saving info');
                                buttonCarouselController.nextPage(
                                    duration: Duration(milliseconds: 500)
                                    , curve: Curves.easeInOutQuad
                                );
                                setState(() {
                                  current_page++;
                                });
                              }
                              else
                              {
                                print('dismatched');
                                await showDialog(context: context,
                                barrierDismissible: false,
                                builder:(BuildContext context){
                                  return ErrorDialogue(message: 'The otp you entered is not correct, try typing '
                                      'it again or check that the phone number belongs to you',);
                                });
                              }
                            }, child: Text(
                                'Submit Code'
                            ),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(grad1),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  ))
                              ),
                            ),
                            OtpTimerButton(
                              controller: controller,
                              onPressed: () => _requestOtp(),
                              text: Text('Resend OTP'),
                              duration: 30,
                              backgroundColor: Colors.black,
                              height: 40.0,
                              radius: 20.0,
                            ),

                          ],
                        ),
                      ),
                    ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0,vertical: 20.0),
              child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      Expanded(flex:1,child: Image.asset('assets/otp_success.png',width: 0.7*_width,)),
                      SizedBox(height: 10.0,),
                      Text(
                        "Registration Completed!",
                        style: GoogleFonts.pacifico(
                            fontSize: 28,
                            color: Colors.black),
                      ),
                      SizedBox(height: 5.0,),

                      Row(
                        children: [
                          Expanded(child: Text('Congratulations! you have successfully completed your profile information and you are ready to start now!',
                            style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold,color: Colors.grey),
                            textAlign: TextAlign.center,
                          ))
                        ],
                      ),
                      SizedBox(height: 10.0,),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(onPressed: (){
                              Navigator.pushNamedAndRemoveUntil(context, MainScreen.id_screen, (route) => false);
                            }, child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0,horizontal: _width/4),
                              child: Text('Start',textScaleFactor: 1.5,),
                            ),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.black),
                              elevation:  MaterialStateProperty.all(2.0)
                            ),
                            ),
                            SizedBox(height: 50.0,)

                          ],
                        ),
                      ),
                    ]),
              ),
            ),
          ],
          carouselController: buttonCarouselController,
          options: CarouselOptions(
            height: _height,
            aspectRatio: 16/9,
            viewportFraction: 1,
            initialPage: current_page,
            enableInfiniteScroll: false,
            reverse: false,
            autoPlay: false,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            scrollPhysics: NeverScrollableScrollPhysics()
          ),

        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
  void savePhoneNumber(context)
  {
    String userId= firebaseUser!.uid;
    userRef.child(userId).child("phone").set(countryCode+phoneTextEditingController.text.trim());
  }


}
