import 'package:clay_containers/clay_containers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relaxi_driver/AllWidgets/dialogueBox.dart';
import 'package:relaxi_driver/Assistants/methods.dart';
import 'package:relaxi_driver/Configurations/configMaps.dart';
import 'package:relaxi_driver/DataHandler/appData.dart';
import 'package:relaxi_driver/Models/drivers.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:relaxi_driver/tabPages/earningsPage.dart';
import 'package:relaxi_driver/tabPages/homePage.dart';
import 'package:relaxi_driver/tabPages/profilePage.dart';
import 'package:relaxi_driver/tabPages/ratingPage.dart';

import '../main.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const String id_screen="main";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin{
  int selected_index=0;
  void onTabClicked(int index)async
  {
    if(index==1&&(Provider.of<AppData>(context,listen: false).tripCards.length==0))
      {
        getCards();
      }
    else if(index==2)
      {
      }
    else if(index==3&&Provider.of<AppData>(context,listen: false).driverDetails==null)
    {
      await waitTogetDetails();
    }
    setState(() {
      selected_index = index;
      tabController!.index= selected_index;

    });

  }
  TabController? tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    waitTogetDetails();
  }
  Future<void> waitTogetDetails()async
  {
    showDialog(context: context,barrierDismissible: false,
        builder: (BuildContext context)=> DialogueBox(message: "Loading ..."));
    await _getDriverDetails();
    Navigator.pop(context);

  }
  void getCards()async{
    showDialog(context: context,barrierDismissible: false,
        builder: (BuildContext context)=> DialogueBox(message: "Loading ..."));
    await Methods.retrieveHistoryInfo(context);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController!.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomePage(),
          EarningsPage(),
          RatingPage(),
          ProfilePage()

        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 0, blurRadius: 20.0),
          ],
        ),

        child: ClipRRect(
              borderRadius: BorderRadius.all(
              Radius.circular(35.0)

              ),
          child:BottomNavigationBar(

            items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: ClayContainer(height:50,
                    width: 50,
                    borderRadius: 25.0,
                    spread: 2.0,

                    child: Center(child: Icon(CupertinoIcons.home,color: grad1,)),
                    curveType: CurveType.convex,
                  ),
                  label: ".",
                  activeIcon: ClayContainer(emboss:true,
                      height:50,
                      width: 50,
                      borderRadius: 25.0,
                      child: Center(child: Icon(CupertinoIcons.house_alt_fill, size: 25.0,color: Colors.grey,)),
                    spread: 1,
                    curveType: CurveType.none,
                    depth: 50,
                    color: Colors.white.withOpacity(0.2),
                  )
                ),
                BottomNavigationBarItem(
                  icon: ClayContainer(height:50,
                    width: 50,
                    borderRadius: 25.0,
                    spread: 2.0,
                    child: Center(child: Icon(Icons.history_outlined, color: grad1,)),
                    curveType: CurveType.convex,
                  ),
                  label: ".",
                  activeIcon: ClayContainer(emboss:true,
                    height:50,
                    width: 50,
                    borderRadius: 25.0,
                    child: Center(child: Icon(Icons.history_outlined, size: 25.0,color: grey,)),
                    spread: 1,
                    curveType: CurveType.none,
                    depth: 50,
                    color: Colors.white.withOpacity(0.2),
                  )
                ),
                BottomNavigationBarItem(
                  icon: ClayContainer(height:50,
                    width: 50,
                    borderRadius: 25.0,
                    spread: 2.0,
                    child: Center(child:Icon(CupertinoIcons.star,color: grad1,)),

                    curveType: CurveType.convex,
                  ),
                  label: ".",
                  activeIcon: ClayContainer(emboss:true,
                    height:50,
                    width: 50,
                    borderRadius: 25.0,
                    child: Center(child: Icon(CupertinoIcons.star_fill, size: 25.0,color: grey,)),
                    spread: 1,
                    curveType: CurveType.none,
                    depth: 50,
                    color: Colors.white.withOpacity(0.2),
                  )
                ),
                BottomNavigationBarItem(
                  icon: ClayContainer(height:50,
                      width: 50,
                      borderRadius: 25.0,
                      spread: 2.0,
                      child: Center(child: Icon(Icons.person_outline,color: grad1,)),
                      curveType: CurveType.convex,
                  ),
                  label: ".",
                  activeIcon:ClayContainer(emboss:true,
                    height:50,
                    width: 50,
                    borderRadius: 25.0,
                    color: Colors.grey[100],
                    child: Center(child: Icon(CupertinoIcons.person_solid, size: 25.0,color: Colors.grey,)),
                    spread: 1,
                    depth: 50,

                  )
                )
              ],
              iconSize: 20,
              showSelectedLabels: false,
              selectedItemColor: grad1,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              unselectedItemColor: grey,
              currentIndex: selected_index,
              onTap: onTabClicked,
              backgroundColor: Colors.grey[100],
            ),
      ),)
    );
  }
  Future<void> _getDriverDetails()async
  {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser;
    await currentDriverRef.once().then((DataSnapshot dataSnapshot)async
    {
      if(dataSnapshot.value!= null) {
          driversInfo=Drivers.fromSnapshot(dataSnapshot);

          await Provider.of<AppData>(context,listen: false).updateDriverDetails(driversInfo!);
      }
    });
  }
}
