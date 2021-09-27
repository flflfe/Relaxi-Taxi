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
import 'package:flutter_app/AllScreens/tripHistoryPage.dart';
import 'package:flutter_app/AllWidgets/dialogueBox.dart';
import 'package:flutter_app/DataHandler/appData.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:flutter_app/AllWidgets/speedDialCustom.dart';
import 'package:flutter_app/Assistants/methods.dart';
import 'package:flutter_app/Configurations/configMaps.dart';
import 'package:flutter_app/constants/all_cons.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  static const String id_screen="profile";

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
  }
  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    int trip_count=Provider.of<AppData>(context).total_trips;
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: Icon(CupertinoIcons.right_chevron, color: Colors.white,),
          backgroundColor: grad1,
        ),
      body: SafeArea(
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
                        userCurrentInfo.name!,overflow: TextOverflow.fade, style: GoogleFonts.lobster(color: grad1),textAlign: TextAlign.center,
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
                        Icons.logout,
                      ],
                      secondaryIconsText: [
                        "log out",
                      ],
                      secondaryIconsOnPress: [
                        (){}
                      ],
                      secondaryBackgroundColor: Colors.grey[900],
                      secondaryForegroundColor: grad1,
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
                  child: Center(
                    //padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 40.0),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Personal Info.', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),textScaleFactor: 1.1,),
                          Divider(height: 15.0,thickness: 4.0,color: grad1,endIndent: _width/3,indent: _width/3,),
                          SizedBox(height: 5.0,),
                          Container(
                            padding: EdgeInsets.only(left: 10.0, ),
                            decoration: BoxDecoration(
                              border:Border(
                                left: BorderSide(color: grey.withOpacity(0.4), width: 2.0,)
                              )
                            ),
                            child:
                            Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:MainAxisAlignment.center,
                            children: [
                              Text('Phone number:',style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: grey)),
                              SizedBox(height: 5.0,),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 16.0,color: grad1),
                                  SizedBox(width: 5.0,),
                                  Text(userCurrentInfo.phone!, style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w400, color: Colors.black)),
                                ],
                              ),
                              SizedBox(height: 5.0,),
                              Text('Email Address:',style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: grey)),
                              SizedBox(height: 5.0,),
                              Row(
                                children: [
                                  Icon(Icons.email, size: 16.0,color: grad1,),
                                  SizedBox(width: 5.0,),
                                  Text(userCurrentInfo.email!, style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w400, color: Colors.black)),
                                ],
                              ),
                            ],
                          ),
                          ),
                          SizedBox(height: 20.0,),
                          Text('Trips Info.', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),textScaleFactor: 1.1,),
                          Divider(height: 15.0,thickness: 4.0,color: grad1,endIndent: _width/3,indent: _width/3,),
                          SizedBox(height: 5.0,),
                          Container(
                          padding: EdgeInsets.only(left: 10.0, ),
                          decoration: BoxDecoration(
                              border:Border(
                                  left: BorderSide(color: grey.withOpacity(0.4), width: 2.0,)
                              )
                          ),
                          child:Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Completed trips:',style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: grey)),
                                SizedBox(height: 5.0,),
                                Row(
                                  children: [
                                    Icon(CupertinoIcons.location_fill, size: 16.0,color: grad1),
                                    SizedBox(width: 5.0,),
                                    Text(userCurrentInfo.total_trips.toString(), style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w400, color: Colors.black)),
                                  ],
                                ),
                                SizedBox(height: 5.0,),
                                Container(
                                  child: OutlinedButton(
                                    onPressed: ()async{
                                      showDialog(context: context,barrierDismissible: false,
                                          builder: (BuildContext context)=> DialogueBox(message: "Loading ..."));
                                      await Methods.retrieveHistoryInfo(context);
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, TripHistoryPage.id_screen);
                                    },
                                    child: Text('view trips',),
                                    style: ButtonStyle(
                                      foregroundColor: MaterialStateProperty.all(Color(0xFFFFDD00)),
                                    ),
                                  ),
                                )
                              ],
                            ),)

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }



}

