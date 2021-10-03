import 'package:flutter/material.dart';
import 'package:flutter_app/AllScreens/introOnBoardingScreen.dart';
import 'package:flutter_app/AllScreens/loginScreen.dart';
import 'package:flutter_app/AllScreens/mainscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/AllScreens/phoneVerification.dart';
import 'package:flutter_app/Configurations/configMaps.dart';
import 'package:flutter_app/constants/all_cons.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const String id_screen="build";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: splash,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: SplashScreenView(
              backgroundColor: splash,
              navigateRoute: isFirstTimeBool!?IntroOnBoardingScreen():FirebaseAuth.instance.currentUser==null?LoginScreen():hasCompletedProf!?MainScreen():PhoneVerification(),
              imageSrc: 'assets/logo_intro.png',
              duration: 8500,
              pageRouteTransition: PageRouteTransition.SlideTransition,
              imageSize: (0.6*_width).toInt(),
              textType: TextType.ScaleAnimatedText,
            ),
          ),
          Positioned(
            bottom: _height/2-((0.5*(0.55*_width).toInt())+15),
            child:DefaultTextStyle(
            style:  GoogleFonts.pacifico(
                    fontSize: 14.0,
                    color: Colors.black,
                    //fontWeight: FontWeight.w500
                      ),
            child: AnimatedTextKit(
              displayFullTextOnTap: true,
              isRepeatingAnimation: false,
              animatedTexts: [
                TypewriterAnimatedText('',cursor: ''),
                TyperAnimatedText('more than just a taxi...',speed: Duration(milliseconds: 100)),
                TyperAnimatedText('it\'s \'Relaxi\'',speed: Duration(milliseconds: 100))
              ],
            ),
          ))
        ],
      ),
    );
  }
}

