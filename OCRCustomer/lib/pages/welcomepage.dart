import 'package:flutter/material.dart';
import 'package:ocrcustomer/pages/login_screen.dart';
import 'package:ocrcustomer/pages/signup_page.dart';

class welcome extends StatefulWidget {
  const welcome({Key? key}) : super(key: key);

  @override
  State<welcome> createState() => _welcomeState();
}

class _welcomeState extends State<welcome> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:
        Container
        (

        // height: MediaQuery.of(context).size.height * 15,
        // margin: EdgeInsets.all(0.0),
        decoration:  BoxDecoration(

        // borderRadius:  BorderRadius.circular(0.0),
        image: DecorationImage(
        image: AssetImage("images/food.jpg"),
    fit: BoxFit.fill,


    ),

    ),
     child:    Column(

     children: [
     SizedBox(height: 460,width: 20,),
    Row(

    children: [
    SizedBox(width: 10,),
    Text("WELCOME",style: TextStyle(fontSize: 60,color: Colors.white),),
    ],
    ),
    SizedBox(height: 5,),
    SizedBox(width: 10,),
    Row(
    children: [
    SizedBox(width: 10,),
    Text("Let’s check the food that’s Allergic to you",style: TextStyle(fontSize: 20,color: Colors.white),),
    ],
    ),
    Row(
    children: [
    SizedBox(width: 10,),
    Text("by using your mobile phone",style: TextStyle(fontSize: 20,color: Colors.white),)
    ],
    ),

    SizedBox(height:120,),
    Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Container(
    width: 300,
    height: 50,
    child: ElevatedButton(
    style: ButtonStyle(
    shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    ),
    backgroundColor:
    MaterialStateProperty.all<Color>(Colors.yellow.shade900),
    ),
    onPressed: () {
    Navigator.of(context).push(MaterialPageRoute(
    builder:(_){
    return signin();
    }
    ));
    },
    child: Text(
    "Get Started",
    style: TextStyle(
    fontWeight: FontWeight.bold, fontSize: 20),
    ),
    ),
    ),
    ],
    ),

    ],
    ),
      ),
      )
    );
    
  }
}
