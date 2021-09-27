import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/AllScreens/mainscreen.dart';
import 'package:flutter_app/AllWidgets/dialogueBox.dart';
import 'package:flutter_app/Assistants/requests.dart';
import 'package:flutter_app/Configurations/configMaps.dart';
import 'package:flutter_app/DataHandler/appData.dart';
import 'package:flutter_app/Models/address.dart';
import 'package:flutter_app/Models/placePredictions.dart';
import 'package:flutter_app/constants/all_cons.dart';
import 'package:flutter_app/AllWidgets/buttons.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:timelines/timelines.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/AllWidgets/predictionsTile.dart';
class AddHomeWorkScreen extends StatefulWidget {
final bool home;
AddHomeWorkScreen({Key? key,required this.home}) : super(key: key);
static const String id_screen="addHomeWork";

@override
_AddHomeWorkScreenState createState() => _AddHomeWorkScreenState();
}

class _AddHomeWorkScreenState extends State<AddHomeWorkScreen> {
TextEditingController currentHomeTextEditingController = new TextEditingController();
TextEditingController currentWorkTextEditingController = new TextEditingController();
List<PlacePredictions> placePredictionsList=[];
bool startedTyping =false;
@override
Widget build(BuildContext context) {
  Address homeAddress = Provider.of<AppData>(context).homeLocation! ;
  Address workAddress = Provider.of<AppData>(context).workLocation! ;
  final double _height= MediaQuery.of(context).size.height;
  final double _width= MediaQuery.of(context).size.width;
  return SafeArea(child:
  Scaffold(
    resizeToAvoidBottomInset: false,
    backgroundColor: Colors.white,
    body: Stack(
        children: [
          Positioned(
              bottom: 20,
              width: _width,
              child: Image.asset('assets/landscape.png')
          ),
          Positioned(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 25.0),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.white,Colors.white.withOpacity(0.6),grey, ],end:Alignment.topCenter,begin:Alignment.bottomCenter),
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(0.25*_width)),
                      boxShadow: <BoxShadow>[BoxShadow(color: grey.withOpacity(0.5), blurRadius: 3, spreadRadius: 0, offset: Offset(1.0,0)),]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Padding(padding: EdgeInsets.all(10.0),
                                child: Stack(
                                  children: [Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: GestureDetector(onTap:(){
                                      Navigator.pop(context);
                                    },child: Icon(Icons.home, color: grey,)),
                                  ),
                                    Center(child: Text(widget.home?'Set Home Location':'Set Work Location',
                                      style: GoogleFonts.balsamiqSans(
                                        fontSize: 18,
                                        textStyle: TextStyle(
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),))],
                                ),
                              ),
                              Padding(
                                      padding: EdgeInsets.only(right: _width/4-20,left: 20.0),
                                      child: TextField(
                                        controller: widget.home?currentHomeTextEditingController:
                                        currentWorkTextEditingController,
                                        cursorColor: grad1,
                                        cursorWidth: 1,
                                        enabled: true,
                                        onChanged: (val)
                                        {
                                          setState(() {
                                            startedTyping =true;
                                          });
                                          findPlace(val);

                                        },
                                        decoration: InputDecoration(
                                          hintText: widget.home?'home address':'work address',
                                          hintStyle: TextStyle(color: grey),
                                          isDense: true,
                                          labelStyle: TextStyle(color: Colors.grey[500]),
                                          labelText: widget.home?'Update Home Address':'Update work Address',
                                          suffixIcon: Icon(widget.home?CupertinoIcons.house_fill:CupertinoIcons.bag,color: Colors.grey,),
                                          enabledBorder:  UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: grad1, width: 1.0),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: grad1, width: 1.0),
                                          ),

                                        ),
                                      ),
                                    )



                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                ),
                // predictions list
                (startedTyping==true&&placePredictionsList.length>0)? Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: ListView.separated(
                    itemBuilder: (context, index)
                    {
                      return PredictionsTile(placePredictions: placePredictionsList[index],location: widget.home?'home':'work',);
                    },
                    separatorBuilder: (BuildContext context, int index)=>Divider(height: 1.0,),
                    shrinkWrap: true,
                    itemCount: placePredictionsList.length,
                    physics: ClampingScrollPhysics(),
                  ),
                ):
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 4.0,
                      color: Colors.grey.shade50.withOpacity(0.9),
                      child:Row(
                        children: [
                          Expanded(child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(widget.home?'assets/home_address.png':'assets/work_address.png',),
                          )),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.home?homeAddress.placeName:workAddress.placeName, style: GoogleFonts.almarai(
                                  fontWeight: FontWeight.bold,),textScaleFactor: 1.3,),
                                  SizedBox(height: 5.0,),
                                  Text(widget.home?homeAddress.placeFormattedAddress:workAddress.placeFormattedAddress,
                                    style: GoogleFonts.balsamiqSans(color: grey),
                                    textScaleFactor: 1,)
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                  ),
                )


              ],
            ),
          ),
        ]
    ),
  ),
  );
}
void findPlace(String placeName) async
{
  if(placeName.trim().length>1)
  {
    String autoCompleteurl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:eg";
    var result = await Requests.getRequest(autoCompleteurl);
    if(result == 'failed')
    {
      return;
    }
    if(result["status"]=="OK")
    {
      var predictions= result["predictions"];
      var placesList = (predictions as List).map((e) => PlacePredictions.fromJson(e)).toList();
      setState(() {
        placePredictionsList= placesList;
      });
    }
  }
}




}

