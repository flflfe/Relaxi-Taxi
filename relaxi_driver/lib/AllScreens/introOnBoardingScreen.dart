import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intro_slider/dot_animation_enum.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:relaxi_driver/AllScreens/RegistrationScreen.dart';
import 'package:relaxi_driver/AllScreens/loginScreen.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroOnBoardingScreen extends StatefulWidget {
  const IntroOnBoardingScreen({Key? key}) : super(key: key);
  static const String id_screen="onBoard";

  @override
  _IntroOnBoardingScreenState createState() => _IntroOnBoardingScreenState();
}

class _IntroOnBoardingScreenState extends State<IntroOnBoardingScreen> {
  List<Slide> slides = [];
  List<String> subTitles=[
    'Tired of being a regular Taxi driver?',
    'So, what is Relaxi Taxi?'
    ,'Ready for Work?',
    'What are you waiting for !'

  ];
  Function? goToTab;

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "Welcome !",
        styleTitle: GoogleFonts.pacifico(
          fontWeight: FontWeight.w500,
        ),
        description:
        "With RELAXI TAXI, you'll love being a taxi driver! We do our best to make every driver and customer of our users RELAX.",
        styleDescription:
        GoogleFonts.montserrat(fontSize: 14.0, fontStyle: FontStyle.italic,color: Colors.black54),
        pathImage: "assets/driver_prof.png",
      ),
    );
    slides.add(
      new Slide(
        title: "Our Goal",
        styleTitle: GoogleFonts.pacifico(
          fontWeight: FontWeight.w500,
        ),
        description:
        "Relaxi Taxi is an online app for delivering people to their destination, our goal is to deliver people in a very short and comfortable journey by providing the best and shortest route for the driver and providing all the relaxation means inside the taxi itself..",
        styleDescription:
        GoogleFonts.montserrat(fontSize: 14.0, fontStyle: FontStyle.italic,color: Colors.black54),
        pathImage: "assets/our_goal.png",
      ),
    );
    slides.add(
      new Slide(
        title: "Accept a job",
        styleTitle: GoogleFonts.pacifico(
          fontWeight: FontWeight.w500,
        ),
        description:
        "Go online and be discoverable, when you're online you'll be able to receive ride requests from nearby customers, you can either accept or decline any request.",
        styleDescription:
        GoogleFonts.montserrat(fontSize: 14.0, fontStyle: FontStyle.italic,color: Colors.black54),
        pathImage: "assets/male.png",
      ),
    );
    slides.add(
      new Slide(
        title: "No Time!",
        styleTitle: GoogleFonts.pacifico(
          fontWeight: FontWeight.w500,
        ),
        description:
        "Join the Relaxi world now...",
        styleDescription:
        GoogleFonts.montserrat(fontSize: 14.0, fontStyle: FontStyle.italic,color: Colors.black54),
        pathImage: "assets/no_time.png",
      ),
    );

  }

  void onDonePress() {
    // Back to the first tab
    this.goToTab!(0);
  }

  void onTabChangeCompleted(index) {
    // Index of current tab is focused
    print(index);
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: grad1,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      CupertinoIcons.refresh_thin,
      color: grad1,
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: grad1,
    );
  }

  ButtonStyle myButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(StadiumBorder()),
      backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
      overlayColor: MaterialStateProperty.all<Color>(Color(0x33ffcc5c)),
    );
  }

  List<Widget> renderListCustomTabs(context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    List<Widget> tabs = [];
    for (int i = 0; i < slides.length; i++) {
      Slide currentSlide = slides[i];
      tabs.add(Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          margin: EdgeInsets.only(bottom: 60.0, top: 40.0),
          child: ListView(
            children: <Widget>
            [
              Container(
                child: Text(
                  currentSlide.title!,
                  style: currentSlide.styleTitle,
                  textAlign: TextAlign.start,
                  textScaleFactor: 2.3,
                ),
                margin: EdgeInsets.only(top: 20.0,left: 15.0,bottom: 50.0),
              ),
              GestureDetector(
                  child: Image.asset(
                    currentSlide.pathImage!,
                    width:0.65*_width,
                    height: 0.65*_width,
                    fit: BoxFit.contain,
                  )),
              Container(
                child: Text(
                  subTitles[i],
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold,fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
                margin: EdgeInsets.only(top: 40.0,left: 30.0,right: 30.0),
              ),
              Container(
                child: Text(
                  currentSlide.description!,
                  style: currentSlide.styleDescription,
                  textAlign: TextAlign.center,
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),
                margin: EdgeInsets.only(top: 10.0,left: 20.0,right: 20.0,bottom: 20.0),
              ),
              if (i==slides.length-1) Column(
                children: [
                  ElevatedButton(onPressed: (){
                    removeFirstTime();
                    Navigator.pushNamedAndRemoveUntil(context, RegistrationScreen.id_screen, (route) => false);
                  }, child: Text('Register',textScaleFactor: 1.5,style: GoogleFonts.balsamiqSans(color: Colors.black),),
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(Size(_width/2,50)),
                        backgroundColor: MaterialStateProperty.all(grad1),
                        elevation:  MaterialStateProperty.all(2.0),
                        shape: MaterialStateProperty.all(ContinuousRectangleBorder(borderRadius: BorderRadius.circular(40.0)))
                    ),
                  ),
                  SizedBox(height: 15.0,),
                  ElevatedButton(onPressed: (){
                    removeFirstTime();
                    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.id_screen, (route) => false);
                  }, child: Text('Login',textScaleFactor: 1.5,
                      style:GoogleFonts.balsamiqSans()),
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(Size(_width/2,50)),
                        backgroundColor: MaterialStateProperty.all(Colors.black),
                        elevation:  MaterialStateProperty.all(2.0),
                        shape: MaterialStateProperty.all(ContinuousRectangleBorder(borderRadius: BorderRadius.circular(40.0)))

                    ),
                  ),
                ],
              ) else Container(),
            ],
          ),
        ),
      ));
    }
    return tabs;
  }
  Future<void> removeFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('first_time', false);

  }
  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return new IntroSlider(
      // Skip button
      renderSkipBtn: this.renderSkipBtn(),
      skipButtonStyle: myButtonStyle(),

      // Next button
      renderNextBtn: this.renderNextBtn(),
      nextButtonStyle: myButtonStyle(),

      // Done button
      renderDoneBtn: this.renderDoneBtn(),
      onDonePress: this.onDonePress,
      doneButtonStyle: myButtonStyle(),

      // Dot indicator
      colorDot: Colors.grey.shade200,
      //sizeDot: 13.0,
      typeDotAnimation: dotSliderAnimation.DOT_MOVEMENT,
      colorActiveDot: yellow,
      // Tabs
      listCustomTabs: this.renderListCustomTabs(context),
      backgroundColorAllSlides: Colors.white,
      refFuncGoToTab: (refFunc) {
        this.goToTab = refFunc;
      },

      // Behavior
      scrollPhysics: BouncingScrollPhysics(),

      // Show or hide status bar
      hideStatusBar: false,

      // On tab change completed
      onTabChangeCompleted: this.onTabChangeCompleted,
    );
  }
}
