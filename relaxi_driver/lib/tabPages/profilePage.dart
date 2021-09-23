import 'dart:io';
import 'dart:typed_data';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:relaxi_driver/Assistants/methods.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'ratingPage.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UploadTask? task;
  String? imageUrl;
  File? image;
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
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    double? height_top= _height/2 - 50.0;

    return SafeArea(

      child: Stack(
        //overflow: Overflow.visible,
        children: [
          Positioned(

              child:Container(
                width: _width+200,

                height: _height/2-60,
                decoration: new BoxDecoration(
                  color: Colors.white,
                  image: new DecorationImage(
                    image: new ExactAssetImage('assets/bg.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                          radius: 50.0,
                          backgroundColor: Colors.grey,
                          foregroundImage: imageUrl!=null?NetworkImage(imageUrl!) :
                          AssetImage('assets/logo3.gif') as ImageProvider
                          ),


                        ),
                          Positioned(
                            bottom:0.0,
                            right: 0.0,
                            child: IconButton(
                            icon: Icon(CupertinoIcons.camera_circle_fill,size:30.0,color:Colors.white,),
                            onPressed: (){
                              pickImage();
                            },
                          ))
                        ],
                      ),
                      SizedBox(height: 5.0,),
                      Divider(height: 10.0,thickness: 3.5,indent: _width/2-40,endIndent: _width/2-40,),
                      Text('Donia Esawi', style: GoogleFonts.pacifico(fontSize: 28.0,color: Colors.white),
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.center,),
                      AnimatedDefaultTextStyle(
                        style: GoogleFonts.lobster(fontSize: 24.0),
                        duration: Duration(milliseconds: 3000),
                        child: AnimatedTextKit(
                          pause: Duration(milliseconds: 0),
                          repeatForever: true,
                          isRepeatingAnimation: true,

                          animatedTexts: [
                            ColorizeAnimatedText('Good Driver', textStyle: GoogleFonts.lobster(fontSize: 24.0),colors: [Colors.purple,
                              Colors.blue,
                              Colors.yellow,
                              Colors.orange,
                              Colors.deepOrange,
                              Colors.red,],
                              speed: Duration(milliseconds: 3000)
                            )
                          ],
                        ),
                      )

                    ],
                  ),
                ),

              )
          ),
          Positioned(
            top: _height/2-50,
            width: _width,
            child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                //borderRadius: BorderRadius.circular(20.0),
                border: Border(
                  top: BorderSide(color: grad1, width: 10.0)
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: grey.withOpacity(0.2),
                    offset: Offset(4,4),
                    blurRadius: 4.0,
                    spreadRadius: 1.0
                  ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.09),
                    offset: Offset(-1,-1),
                    blurRadius: 6.0
                  )
                ]
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:[Image.asset('assets/driver_prof.png',width: 100,),SizedBox(height: 5.0,),Image.asset('assets/car_prof.png',width: 100,),]),
                    ),
                    VerticalDivider(width: 30.0,thickness: 1.0,indent: 30.0,endIndent: 30.0,color: grey.withOpacity(0.2),),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email Address:', style: GoogleFonts.montserrat(fontSize: 14.0,fontWeight: FontWeight.bold),),
                            Expanded(child: Text('donya.esawi@gmail.com')),
                            SizedBox(height: 10.0,),
                            Text('PhoneNumber:', style: GoogleFonts.montserrat(fontSize: 14.0,fontWeight: FontWeight.bold),),
                            Text('+20 1141992110'),
                            SizedBox(height: 10.0,),
                            Text('Car Model',style: GoogleFonts.montserrat(fontSize: 14.0,fontWeight: FontWeight.bold),),
                            Text('Toyota Corolla 2010'),
                            SizedBox(height: 10.0,),
                            Text('Car Number',style: GoogleFonts.montserrat(fontSize: 14.0,fontWeight: FontWeight.bold),),
                            Text('K F C 3 1 6'),
                            SizedBox(height: 10.0,),
                            Text('Car Color',style: GoogleFonts.montserrat(fontSize: 14.0,fontWeight: FontWeight.bold),),
                            Text('White'),
                            SizedBox(height: 10.0,),

                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ))



        ],
      ),
    );
  }

}

