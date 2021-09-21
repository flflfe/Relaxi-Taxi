import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relaxi_driver/constants/all_cons.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({Key? key}) : super(key: key);

  @override
  _EarningsPageState createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  bool? is_expanded=false;

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
                height: _height/2+60,

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [grad1,grad1,grad2],
                    end: Alignment.topLeft,
                    begin: Alignment.bottomRight
                  )
                ),
                child: Padding(
                  padding: EdgeInsets.only(top:_height/4-100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total Earnings:',style: GoogleFonts.pacifico(fontSize: 28.0,color: Colors.white),),
                      SizedBox(height: 5.0,),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                        children:[Text('235.35',style: GoogleFonts.lobster(fontSize: 24.0, color: Colors.black),),
                  SizedBox(width: 0.0,),
                  Icon(CupertinoIcons.money_pound, color: Colors.black,)]
                      ),
                      SizedBox(height: 20.0,),

                      Text('Total Trips:',style: GoogleFonts.pacifico(fontSize: 28.0,color: Colors.white),),
                      SizedBox(height: 5.0,),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[Text('20',style: GoogleFonts.lobster(fontSize: 24.0, color: Colors.black),),
                            SizedBox(width: 10.0,),
                            Icon(CupertinoIcons.car_detailed, color: Colors.black,)]
                      )
                    ],
                  ),
                ),
              )
          ),
          AnimatedPositioned(
              onEnd: (){},
              top: is_expanded!?0:height_top,
              child: Container(
                height: is_expanded!?_height:_height-height_top,
                width: _width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft:is_expanded!?Radius.circular(0.0):Radius.circular(50.0),
                        topRight:is_expanded!?Radius.circular(0.0):Radius.circular(50.0))
                ),
                child: Stack(
                  children: [
                    Positioned(
                        top:20,
                        right: 30,
                        child: OutlinedButton(
                          onPressed: (){
                            setState(() {
                              is_expanded=!is_expanded!;
                            });
                          },
                          style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all(grey)
                          ),
                          child: Text(is_expanded!?'Shrink':'Expand',),
                        )),
                    Positioned(

                      child: Padding(
                      padding: EdgeInsets.only(top:80.0,right: 18.0,left: 18.0,bottom: 90.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 20,
                        itemBuilder: (context, index){return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(

                            decoration: BoxDecoration(
                                border: Border.all(color: grad1,width: 0.5),
                              borderRadius: BorderRadius.circular(15.0),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: grad1.withOpacity(0.1),
                                blurRadius:5.0,

                              )
                            ]),

                            child: Card(
                              elevation: 0.0,
                              child: ListTile(
                                  onTap: (){

                                  },
                                  title: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Stack(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(CupertinoIcons.car_detailed,color: Colors.black,),
                                            SizedBox(width: 10.0,),
                                            Text('Trip ${index+1}'),
                                          ],

                                        ),
                                  Positioned(
                                    top: 5.0,right: 0.0,
                                      child:Row(children:[Text('15',style: GoogleFonts.jua(fontSize: 16.0,color: Colors.black),),SizedBox(width: 0.0,),Icon(CupertinoIcons.money_pound,size: 20.0,)]))


                                          ],
                                    ),
                                  ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(child: Column(

                                        mainAxisSize: MainAxisSize.min,

                                        children: [
                                          Row(children:[Icon(CupertinoIcons.location_solid,color: grad1,size: 15.0,),
                                            SizedBox(width: 5.0),Text('From:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                            SizedBox(width: 5.0,),Expanded(child: Text('Lorem Ipsum is simply dummy text of the printing and typesetting industry',overflow: TextOverflow.ellipsis,))],),
                                          SizedBox(height: 5.0,),
                                          Row(children:[Icon(CupertinoIcons.location,color: grad1,size: 15.0,),SizedBox(width: 5.0),Text('To:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),), SizedBox(width: 5.0,),
                                            Expanded(child: Text('Lorem Ipsum is simply dummy text of the printing and typesetting industry',overflow: TextOverflow.ellipsis,))],),

                                        ],
                                      ),)
                                    ],
                                  ),
                                ),
                                  ),

                            ),
                          ),
                        );},
                      ),
                    ))
                  ],
                ),
              ), duration: Duration(milliseconds: 700),
          curve: Curves.easeInOutQuint,)


        ],
      ),
    );
  }
}
