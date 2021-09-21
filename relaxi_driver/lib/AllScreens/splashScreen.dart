import 'package:flutter/material.dart';
import 'package:relaxi_driver/AllScreens/loginScreen.dart';
import 'package:relaxi_driver/AllScreens/mainscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const String id_screen="build";
  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: SplashScreenView(
              navigateRoute: FirebaseAuth.instance.currentUser==null?LoginScreen():MainScreen(),
              imageSrc: 'assets/logo_title.png',
              duration: 8500,
              pageRouteTransition: PageRouteTransition.SlideTransition,
              imageSize: (0.35*_width).toInt(),
              textType: TextType.ScaleAnimatedText,
            ),
          ),
          Positioned(
            bottom: _height/2-((0.5*(0.35*_width).toInt())+30.0),
            child:DefaultTextStyle(
            style:  GoogleFonts.ibmPlexMono(
                    fontSize: 14.0,
                    color: Color(0xff444b54),
                      ),
            child: AnimatedTextKit(
              displayFullTextOnTap: true,
              isRepeatingAnimation: false,
              animatedTexts: [
                TypewriterAnimatedText('',cursor: ''),
                TypewriterAnimatedText('more than just a taxi.',speed: Duration(milliseconds: 100)),
              TypewriterAnimatedText('it\'s RELAXI.',speed: Duration(milliseconds: 100))
              ],
            ),
          ))
        ],
      ),
    );
  }
}
