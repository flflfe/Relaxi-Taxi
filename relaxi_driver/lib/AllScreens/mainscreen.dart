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
        height: 60,
        decoration: BoxDecoration(
          //borderRadius:BorderRadius.only(topRight: Radius.circular(60.0),topLeft: Radius.circular(60.0)),
          boxShadow: [
            BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
          ],
        ),

        child: ClipRRect(
              borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
              ),
          child:BottomNavigationBar(
            items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: "home",
                  activeIcon: Icon(Icons.home)
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.credit_card_rounded),
                  label: "earnings",
                  activeIcon: Icon(Icons.credit_card),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star_border_outlined),
                  label: "rating",
                  activeIcon: Icon(Icons.star),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: "home",
                  activeIcon:Icon(Icons.person),
                )
              ],
              showSelectedLabels: true,
              selectedItemColor: grad1,
              showUnselectedLabels: false,
              selectedLabelStyle: TextStyle(fontSize: 12.0,color: grad1),
              type: BottomNavigationBarType.fixed,
              unselectedItemColor: grey,
              currentIndex: selected_index,
              onTap: onTabClicked,
            ),
      ),)
    );
  }
}
