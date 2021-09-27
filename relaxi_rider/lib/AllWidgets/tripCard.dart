import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Models/history.dart';
import 'package:flutter_app/constants/all_cons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timelines/timelines.dart';
class TripCard extends StatefulWidget {
  History? trip;
  TripCard({
    Key? key,
    required double height,
    this.trip
  }) : _height = height, super(key: key);

  final double _height;

  @override
  _TripCardState createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> with TickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Stack(
        children: [
          Positioned(
            child: Padding(
              padding: EdgeInsets.only(bottom:2.0,top: 2.0),
              child: Container(
                height: widget._height/5 - 4,
                decoration: BoxDecoration(
                    color: grad1,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.shade200,blurRadius: 1.0
                      )
                    ]
                ),
              ),
            ),
          ),
          Positioned(
            child: Padding(
              padding: EdgeInsets.only(left:8.0,top: 0.0,bottom: 0.0),

              child: Container(
                height: widget._height/5,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.shade300,blurRadius: 15.0
                      ),
                    ]
                ),
                child: Row(

                  children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            "At: "+"\""+widget.trip!.created_at!.hour.toString()+":"+widget.trip!.created_at!.minute.toString()+":"+widget.trip!.created_at!.second.toString()+"\"",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            minFontSize: 20.0,
                            textScaleFactor: 0.7,
                          ),
                          Column(
                            children: [
                              AutoSizeText(
                                widget.trip!.created_at!.day.toString(),
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                minFontSize: 20.0,
                                textScaleFactor: 1.6,
                              ),

                              AutoSizeText(
                                getMonth(widget.trip!.created_at!.month),
                                style:
                                GoogleFonts.ubuntuCondensed(color: Colors.grey,),
                                maxLines: 1,
                                softWrap: true,
                                textScaleFactor: 2.5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                        ],
                      ),
                    )),
                    Expanded(
                        flex: 2,
                        child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[
                              FixedTimeline.tileBuilder(
                                theme: TimelineThemeData(
                                  color: grad1,
                                  connectorTheme: ConnectorThemeData(
                                      space: 25.0
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
                                    Text(
                                      widget.trip!.pickup_address.toString(),
                                      style: GoogleFonts.ubuntuCondensed(),
                                      overflow: TextOverflow.ellipsis,
                                    ):(index==2)?Text(
                                      widget.trip!.dropoff_address.toString(),
                                      style: GoogleFonts.ubuntuCondensed(),
                                      overflow: TextOverflow.ellipsis,):
                                    Text(widget.trip!.distance.toString(),style: TextStyle(color: Colors.grey,fontSize: 12.0),);
                                  },
                                  indicatorStyleBuilder: (context, index) {

                                    return (index==1)?IndicatorStyle.transparent: (index==0)?IndicatorStyle.outlined:IndicatorStyle.dot;
                                  },
                                  itemExtent: 30.0,
                                  itemCount: 3,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0,left: 8.0,bottom: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('duration', style: GoogleFonts.ubuntuCondensed(color: grey),),
                                          Text(widget.trip!.duration.toString(),textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 12.0),),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text('cost', style: GoogleFonts.ubuntuCondensed(color: grey),),
                                          Text(widget.trip!.fares.toString() ,textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 12.0),),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text('driver name', style: GoogleFonts.ubuntuCondensed(color: grey),),
                                          Text(widget.trip!.driver_name.toString() ,textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 12.0),),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),


                            ]
                        ))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  String getMonth(int mon)
  {
    List<String> monthNames=[
    'Jan.', 'Feb.', 'Mar.', 'Apr.','May','Jun.','Jul', 'Aug.', 'Sept.', 'Oct.', 'Nov.', 'Dec.'
    ];
    return monthNames[mon-1];

  }
}
