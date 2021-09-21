import 'package:flutter/material.dart';
import 'package:relaxi_driver/AllScreens/mainscreen.dart';
import 'package:relaxi_driver/AllWidgets/dialogueBox.dart';
import 'package:relaxi_driver/Assistants/requests.dart';
import 'package:relaxi_driver/Configurations/configMaps.dart';
import 'package:relaxi_driver/DataHandler/appData.dart';
import 'package:relaxi_driver/Models/address.dart';
import 'package:relaxi_driver/Models/placePredictions.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:relaxi_driver/AllWidgets/buttons.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:relaxi_driver/AllWidgets/predictionsTile.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = new TextEditingController();
  TextEditingController dropOffTextEditingController = new TextEditingController();
  List<PlacePredictions> placePredictionsList=[];
  @override
  Widget build(BuildContext context) {
    String placeAddress = Provider.of<AppData>(context).pickUpLocation.placeName ;
    pickUpTextEditingController.text= placeAddress;
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return
SafeArea(
child:
Scaffold(
  resizeToAvoidBottomInset: false,
  backgroundColor: Colors.white,
  body: Stack(
  children: [


  Positioned(
  bottom: 20,
  width: _width,
  child: Image.asset('assets/landscape.png')),
    Positioned(

      child: Column(
        children: [
          Container(
            height: 0.25*_height,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white,Colors.white.withOpacity(0.6),grey, ],end:Alignment.topCenter,begin:Alignment.bottomCenter),
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(0.25*_width)),
                boxShadow: <BoxShadow>[BoxShadow(color: grey.withOpacity(0.5), blurRadius: 3, spreadRadius: 0, offset: Offset(1.0,0)),]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.all(8.0),
                  child: Stack(
                    children: [Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: GestureDetector(onTap:(){
                        Navigator.pop(context);
                      },child: Icon(Icons.home, color: grey,)),
                    ),
                      Center(child: Text('Set Drop Off Location',
                        style: GoogleFonts.recursive(
                          fontSize: 18,
                          textStyle: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500
                          ),
                        ),))],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 20.0),
                  child: TextField(
                    controller: pickUpTextEditingController,
                    cursorColor: grad1,
                    maxLines: null,
                    minLines: null,
                    expands: false,
                    decoration: InputDecoration(
                      icon: Icon(Icons.circle, size: 15, color: Colors.black87,),
                      border: InputBorder.none,
                      labelText: 'Address Location', //add the current location here
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      suffixIcon: Icon(Icons.location_on,color: grad1,),

                      isDense: true,
                    ),


                  ),

                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 60.0),child: Divider(thickness: 1,)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 20.0),
                  child: TextField(
                    controller: dropOffTextEditingController,
                    cursorColor: grad1,
                    cursorWidth: 1,
                    onChanged: (val)
                    {
                      findPlace(val);
                    },
                    decoration: InputDecoration(
                        hintText: 'Destination',
                        hintStyle: TextStyle(color: grey),
                        isDense: true,
                        labelStyle: TextStyle(color: Colors.grey[700]),
                        icon: Icon(Icons.circle, size: 15, color: grad1,),
                        border: InputBorder.none,
                        labelText: 'Drop Off Location'
                    ),
                  ),

                ),

              ],
            ),

          ),

          // predictions list
          (placePredictionsList.length>0)? Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: ListView.separated(
              itemBuilder: (context, index)
              {
                return PredictionsTile(placePredictions: placePredictionsList[index]);
              },
              separatorBuilder: (BuildContext context, int index)=>Divider(height: 1.0,),
              shrinkWrap: true,
              itemCount: placePredictionsList.length,
              physics: ClampingScrollPhysics(),
            ),
          ): Container()


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
void getPlaceAddressDetails(String id, context) async
{
  showDialog(context: context ,
      barrierDismissible: false,
  builder: (BuildContext context)=> DialogueBox(message: "Setting Drop Off"));
  String placeAddressUrl="https://maps.googleapis.com/maps/api/place/details/json?place_id=$id&key=$mapKey";
  var response = await Requests.getRequest(placeAddressUrl);
  Navigator.pop(context);
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

    Provider.of<AppData>(context, listen: false).updateDropOffLocation(address);
    print("This Is Drop Off Location :: ");
    print(address.placeName);

    Navigator.pop(context, "obtainDirection");
  }

}