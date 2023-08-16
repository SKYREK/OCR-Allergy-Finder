import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ocrcustomer/services/firebaseservice.dart';

class userprofile extends StatefulWidget {
  const userprofile({Key? key}) : super(key: key);

  @override
  State<userprofile> createState() => _userprofileState();
}

class _userprofileState extends State<userprofile> {
  String _userName = '';
  String _usertoxic = '';
  String _useremail = '';
  void _editProfileName() async {
    String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String updatedName = _userName;
        return AlertDialog(
          title: Text('Edit Profile Name'),
          content: TextField(
            onChanged: (value) {
              updatedName = value;
            },
            controller: TextEditingController(text: _userName),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(updatedName);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName != null) {
      // Update the name in Firebase
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'name': newName});

      // Reload the user profile
      setState(() {
        _userName = newName;
      });
    }
  }

  void loadDate() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // Retrieve the 'toxic' array from the document data
    List<String> toxicArray =
        (snapshot.data() as Map<String, dynamic>)['toxic'].cast<String>();
    String name = (snapshot.data() as Map<String, dynamic>)['name'];
    String toxic = toxicArray.toString();
    //get email
    String email = FirebaseAuth.instance.currentUser!.email.toString();
    setState(() {
      _userName = name;
      _usertoxic = toxic;
      _useremail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    loadDate();
    return Scaffold(
      body: Container(
        height: 1000,
        decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage("images/woodbc.jpg"),
            //   fit: BoxFit.fill,
            // ),
            ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(60.10),
            child: Column(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image(image: AssetImage('images/li.png'))),
                ),
                const SizedBox(
                  height: 10,
                  width: 100,
                ),
                Text(_userName, style: Theme.of(context).textTheme.headline6),
                Text(_useremail, style: Theme.of(context).textTheme.bodyText2),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 250,
                  child: Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                        onPressed: _editProfileName,
                        child: Text(
                          "Edit Profile".toUpperCase(),
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.yellow.shade900),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Details".toUpperCase()),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                        ),
                      ),
                    ],
                  )),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    color: Colors.white,
                    child: accountwidget(
                        title: "Setting",
                        icon: Icons.settings,
                        onPress: () {})),
                const Divider(
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.white,
                  child: accountwidget(
                    title: "Log Out",
                    icon: Icons.logout,
                    textColor: Colors.red,
                    endIcon: false,
                    onPress: () {
                      GoogleSignIn().signOut();
                      FirebaseAuth.instance.signOut();
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class accountwidget extends StatelessWidget {
  const accountwidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
    // super.key,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.blue.withOpacity(0.1)),
        child: Icon(
          icon,
          color: Colors.black,
        ),
      ),
      title: Text(title,
          style:
              Theme.of(context).textTheme.bodyText1?.apply(color: textColor)),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.black.withOpacity(0.1),
              ),
              child: const Icon(Icons.arrow_forward_ios),
            )
          : null,
    );
  }
}
