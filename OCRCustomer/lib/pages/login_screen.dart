import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocrcustomer/pages/tabbar.dart';
import 'package:ocrcustomer/services/firebaseservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class signin extends StatefulWidget {
  const signin({Key? key}) : super(key: key);

  @override
  State<signin> createState() => _signinState();
}

class _signinState extends State<signin> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("images/log.jpg"),
          fit: BoxFit.fill,
        )),
        child: Stack(
          children: [
            Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                height: 400,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        )
                      ]),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Welcome back !",
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Let's Discover foods ",
                            style: TextStyle(fontSize: 35),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "for you ... ",
                            style: TextStyle(fontSize: 35),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 70,
                      ),
                      Row(
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
                                    MaterialStateProperty.all<Color>(
                                        Colors.yellow.shade900),
                              ),
                              onPressed: () async {
                                try {
                                  await FirebaseServices().signInwithgoogle();

                                  // Get user details
                                  User? user =
                                      FirebaseAuth.instance.currentUser;

                                  // Check and create user document if needed
                                  await checkAndCreateUserDocument(user);

                                  // Proceed with navigation to Tabbar or other app logic
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (_) {
                                    return Tabbar();
                                  }));
                                } catch (e) {
                                  print('Error occurred during sign-in: $e');
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'images/google.png', // Replace this with your actual image asset path
                                    height:
                                        70, // Set the desired height of the image
                                    width:
                                        70, // Set the desired width of the image
                                  ),
                                  SizedBox(
                                      width:
                                          1), // Optional space between image and text
                                  Text(
                                    "Sign in with Google",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    ));
  }

  Future<void> checkAndCreateUserDocument(User? user) async {
    if (user != null) {
      // Reference to the Firestore collection
      final usersCollection = FirebaseFirestore.instance.collection('users');

      try {
        // Get the document snapshot for the user's ID
        DocumentSnapshot snapshot = await usersCollection.doc(user.uid).get();

        if (snapshot.exists) {
          // Document with the user's ID already exists
          print('User document exists');
          // You can perform any further actions if needed
        } else {
          // Document with the user's ID does not exist
          print('User document does not exist. Creating a new one...');

          // Create a new user document with fields 'name' and 'toxic'
          await usersCollection.doc(user.uid).set({
            'name':
                user.displayName ?? '', // Use user's display name if available
            'toxic': [], // An empty list for the 'toxic' field
          });

          print('New user document created successfully!');
        }
      } catch (e) {
        // Handle any exceptions that might occur during the process
        print('Error occurred while checking and creating user document: $e');
      }
    }
  }
}
