import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../firebase_options.dart';

class LoadingPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    //looking if there is a firebase logged in
    redirect(context);
    return(
        Scaffold(
            body : Center(
              //add Image
                child :
                Container(
                    width : 100,
                    height : 100,
                    child : const Image(
                        image : AssetImage('assets/images/icon.png')
                    )
                )
            )
        )
    );
  }
  void redirect(BuildContext context) async{
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if(FirebaseAuth.instance.currentUser == null){
      Navigator.pushNamed(context,"/login");
    }else{
      Navigator.pushNamed(context,"/home");
    }
  }

}