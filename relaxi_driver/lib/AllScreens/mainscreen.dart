import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:relaxi_driver/tabPages/earningsPage.dart';
import 'package:relaxi_driver/tabPages/homePage.dart';
import 'package:relaxi_driver/tabPages/profilePage.dart';
import 'package:relaxi_driver/tabPages/ratingPage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const String id_screen="main";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin{
  int selected_index=0;
  void onTabClicked(int index)
  {
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
                    child: Center(child: Icon(CupertinoIcons.creditcard, color: grad1,)),
                    curveType: CurveType.convex,
                  ),
                  label: ".",
                  activeIcon: ClayContainer(emboss:true,
                    height:50,
                    width: 50,
                    borderRadius: 25.0,
                    child: Center(child: Icon(CupertinoIcons.creditcard_fill, size: 25.0,color: grey,)),
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
}
