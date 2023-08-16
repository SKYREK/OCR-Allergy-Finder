import 'package:flutter/material.dart';
import 'package:ocrcustomer/pages/faq_page.dart';
import 'package:ocrcustomer/pages/scanfile.dart';
import 'package:ocrcustomer/pages/toxic_pages.dart';
import 'package:ocrcustomer/pages/userprofile.dart';



class Tabbar extends StatefulWidget {
  const Tabbar({Key? key}) : super(key: key);

  @override
  State<Tabbar> createState() => _TabbarState();
}

class _TabbarState extends State<Tabbar> {
  int index=0;
  final screen=[
   CheckPage(),
    FAQPage(),
    ToxicPage(),
    userprofile(),


  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 3,
        child: SafeArea(

            child: Scaffold(
              drawer: Drawer(
                child: ListView(
                  children: [
                    ListTile(
                      title:Text("hey") ,
                      onTap: () {},
                    )
                  ],
                ),
              ),

              bottomNavigationBar: NavigationBarTheme(

                data: NavigationBarThemeData(
                  indicatorColor: Colors.blue.shade100,
                  labelTextStyle: MaterialStateProperty.all(
                      TextStyle(fontSize: 14 , fontWeight: FontWeight.w500)
                  ),

                ),
                child: NavigationBar(
                  height: 70,
                  selectedIndex: index,
                  onDestinationSelected: (index) =>
                      setState(() => this.index=index),
                  destinations: const [

                    NavigationDestination(
                      icon: Icon(Icons.home,size: 35,) ,
                      label: "",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.insert_comment,size: 35,) ,
                      label: "",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.add_circle,size: 35,) ,
                      label: "",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.account_circle,size: 35,) ,
                      label: "",
                    ),
                  ],
                ),
              ),
              body:screen[index],



            )
        ));;;
  }
}
