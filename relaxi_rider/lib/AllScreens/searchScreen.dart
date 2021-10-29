import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app/AllScreens/RegistrationScreen.dart';
import 'package:flutter_app/AllScreens/mainscreen.dart';
import 'package:flutter_app/AllWidgets/dialogueBox.dart';
import 'package:flutter_app/Assistants/methods.dart';
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
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = new TextEditingController();
  TextEditingController dropOffTextEditingController = new TextEditingController();
  List<PlacePredictions> placePredictionsList=[];
  bool startedTyping =false;
  @override
  Widget build(BuildContext context) {
    String placeAddress = Provider.of<AppData>(context).pickUpLocation.placeName ;
    Address homeAddress = Provider.of<AppData>(context).homeLocation! ;
    Address workAddress = Provider.of<AppData>(context).workLocation! ;
    pickUpTextEditingController.text= placeAddress;
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
                  padding: EdgeInsets.all(25.0),
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
                              Stack(
                                children: [GestureDetector(onTap:(){
                                  Navigator.pop(context);
                                },child: Icon(Icons.home, color: grey,)),
                                  Center(child: Text('Set Drop Off Location',
                                    style: GoogleFonts.balsamiqSans(
                                      fontSize: 18,
                                      textStyle: TextStyle(
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w600
                                      ),
                                    ),))],
                              ),
                              SizedBox(height: 15.0,),
                              FixedTimeline.tileBuilder(
                                theme: TimelineThemeData(
                                  color: grad1,
                                  connectorTheme: ConnectorThemeData(
                                      space: 35.0
                                  ),

                                ),
                                builder: TimelineTileBuilder.connectedFromStyle(

                                  connectionDirection: ConnectionDirection.before,
                                  connectorStyleBuilder: (context, index) {
                                    return ConnectorStyle.dashedLine;
                                  },
                                  nodePositionBuilder: (context, index)
                                  {
                                    return 0.0;
                                  },
                                  indicatorPositionBuilder: (context,index)
                                  {
                                    return  (index==0)?0.5:0.5;
                                  },
                                  contentsBuilder: (context,index)
                                  {
                                    return  (index==0)?
                                    Padding(
                                      padding: EdgeInsets.only(right: _width/4-40),                              child: TextField(
                                        controller: pickUpTextEditingController,
                                        cursorColor: grad1,
                                        maxLines: null,
                                        minLines: null,
                                        expands: false,
                                        enabled: false,
                                        style: TextStyle(color: Colors.grey.shade800),
                                        decoration: InputDecoration(

                                          labelText: 'Address Location', //add the current location here
                                          labelStyle: TextStyle(color: Colors.grey[550]),
                                          suffixIcon: Icon(CupertinoIcons.location,color: Colors.grey,),
                                          isDense: true,
                                          disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0),
                                          ),
                                        ),


                                      ),
                                    ): Padding(
                                      padding: EdgeInsets.only(right: _width/4-40),
                                      child: TextField(
                                        controller: dropOffTextEditingController,
                                        cursorColor: grad1,
                                        cursorWidth: 1,
                                        onChanged: (val)
                                        {
                                          findPlace(val);
                                          setState(() {
                                            startedTyping=true;
                                          });
                                        },

                                        decoration: InputDecoration(
                                            hintText: 'Destination',
                                            hintStyle: TextStyle(color: grey),
                                            isDense: true,
                                            labelStyle: TextStyle(color: Colors.grey[500]),
                                            labelText: 'Drop Off Location',
                                            suffixIcon: Icon(CupertinoIcons.location_solid,color: Colors.grey,),

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
                                    ;
                                  },
                                  indicatorStyleBuilder: (context, index) {

                                    return (index==1)?IndicatorStyle.dot:IndicatorStyle.outlined;
                                  },
                                  itemCount: 2,
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                ), // predictions list
                (startedTyping&&placePredictionsList.length>0)? Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: ListView.separated(
                    itemBuilder: (context, index)
                    {
                      return PredictionsTile(placePredictions: placePredictionsList[index],location: 'dropOff',);
                    },
                    separatorBuilder: (BuildContext context, int index)=>Divider(height: 1.0,),
                    shrinkWrap: true,
                    itemCount: placePredictionsList.length,
                    physics: ClampingScrollPhysics(),
                  ),
                ):
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
                    child: Column(
                      children: [

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 0.0),
                          child: TextButton(
                            onPressed:(){
                              if(homeAddress.placeName!="not set") {
                                Navigator.pop(context, "obtainDirection_home");
                              }
                            },
                            style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(grad1.withOpacity(0.5)),
                              backgroundColor: MaterialStateProperty.all(Colors.grey.shade100)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 16.0),
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.house_fill, color: grad1,),
                                  SizedBox(width: 10.0,),
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(homeAddress.placeName,style: GoogleFonts.balsamiqSans(color: Colors.black),textScaleFactor: 1.4,),
                                      Text(homeAddress.placeFormattedAddress,style: GoogleFonts.balsamiqSans(color: Colors.grey),textScaleFactor: 1,),
                                    ],
                                  )),
                                  Icon(CupertinoIcons.right_chevron, color: grad1,)
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            onPressed:()
                            {
                              if(workAddress.placeName!="not set") {
                                Navigator.pop(context, "obtainDirection_work");
                              }
                            },
                            style: ButtonStyle(
                                overlayColor: MaterialStateProperty.all(grad1.withOpacity(0.5)),
                                backgroundColor: MaterialStateProperty.all(Colors.grey.shade100)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 16.0),
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.bag_fill, color: grad1,),
                                  SizedBox(width: 10.0,),
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(workAddress.placeName,style: GoogleFonts.balsamiqSans(color: Colors.black),textScaleFactor: 1.4,),
                                      Text(workAddress.placeFormattedAddress,style: GoogleFonts.balsamiqSans(color: Colors.grey),textScaleFactor: 1,),
                                    ],
                                  )),
                                  Icon(CupertinoIcons.right_chevron, color: grad1,)
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
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
Future<void> getPlaceAddressDetails(String id, context, {String place='dropOff'}) async
{
  if(place=='dropOff') {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            DialogueBox(message: "Setting Drop Off"));
  }
  String placeAddressUrl="https://maps.googleapis.com/maps/api/place/details/json?place_id=$id&key=$mapKey";
  var response = await Requests.getRequest(placeAddressUrl);
  if(place=='dropOff') {Navigator.pop(context);}
  if(response == 'failed')
  {
    return;
  }
  if(response["status"]=="OK")
  {
    Address address= new Address(
        "","","",0.0, 0.0
    );
    address.placeName= response["result"]["name"];
    address.placeId= id;
    address.latitude= response["result"]["geometry"]["location"]["lat"];
    address.longitude= response["result"]["geometry"]["location"]["lng"];
    address.placeFormattedAddress=response["result"]["formatted_address"];
    if(place=='dropOff') {Provider.of<AppData>(context, listen: false).updateDropOffLocation(address);}
    if(place=='home') {
        await Provider.of<AppData>(context, listen: false).updateHomeLocation(address);
        Methods.updateHomeAddress(address);
        print("This Is Home Location :: ");
        print(address.placeName);
        SchedulerBinding.instance!.addPostFrameCallback((_) {
        Navigator.pop(context);
        displayToastMsg('Home Place updated successfully!', context);
        });
    }
    if(place=='work') {
        await Provider.of<AppData>(context, listen: false).updateWorkLocation(address);
        Methods.updateWorkAddress(address);
        print("This Is Work Location :: ");
        print(address.placeName);
        SchedulerBinding.instance!.addPostFrameCallback((_) {
        Navigator.pop(context);
        displayToastMsg('Work Place updated successfully!', context);

      });

    }
    if(place=='dropOff') {
      print("This Is Drop Off Location :: ");
      print(address.placeName);
    }


    if(place=='dropOff') {Navigator.pop(context, "obtainDirection");}

  }

}