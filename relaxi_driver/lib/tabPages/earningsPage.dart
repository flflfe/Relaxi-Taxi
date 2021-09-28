import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:relaxi_driver/AllWidgets/tripCard.dart';
import 'package:relaxi_driver/Assistants/methods.dart';
import 'package:relaxi_driver/DataHandler/appData.dart';
import 'package:relaxi_driver/Models/history.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';
class EarningsPage extends StatefulWidget {
  const EarningsPage({Key? key}) : super(key: key);
  static const String id_screen="history";

  @override
  _EarningsPageState createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();


  }


  @override
  Widget build(BuildContext context) {
    List<History> trips=Provider.of<AppData>(context).tripCards;
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 10.0),
              child: ListView.builder(
                  itemBuilder: (context,index){
                    if(index==0)
                    {
                      return Column(
                        children: [
                          SizedBox(height: 90.0,),
                          TripCard(height: _height,trip: trips[index],)
                        ],
                      );
                    }
                    return TripCard(height: _height,trip: trips[index],);
                  },
                  //separatorBuilder: separatorBuilder,
                  itemCount: trips.length),
            ),
            Positioned(
              child: Container(
                width: _width,
                height: 80,
                decoration: new BoxDecoration(
                    image: DecorationImage(
                        image: ExactAssetImage('assets/driver_bg.png',),
                        fit: BoxFit.cover
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.shade400,blurRadius: 10.0
                      )
                    ]
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(left: 0.0,
                          child: IconButton(onPressed: (){
                            Navigator.pop(context);
                          },icon: Icon(CupertinoIcons.back))),
                      Positioned(

                        child: Center(
                          child: Text('TRIPS HISTORY', style: GoogleFonts.amaticSc(fontWeight: FontWeight.bold,color: Colors.black ),
                            textScaleFactor: 2.0,),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

