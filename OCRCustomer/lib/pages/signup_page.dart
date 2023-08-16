import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocrcustomer/pages/login_screen.dart';
import 'package:ocrcustomer/pages/tabbar.dart';
import 'package:ocrcustomer/widgets/email_input.dart';
import 'package:ocrcustomer/widgets/name_input.dart';

import '../widgets/password_input.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");
  TextEditingController rePasswordController = TextEditingController(text: "");
  TextEditingController nameController = TextEditingController(text: "");
  bool _isLoading = false;

  bool validateEmail(String email) {
    // Regular expression pattern for email validation
    final emailRegex = r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$';

    // Create a regular expression object
    final regex = RegExp(emailRegex);

    // Use the RegExp object to match the email against the pattern
    if (!regex.hasMatch(email)) {
      return false; // Invalid email format
    }

    return true; // Valid email format
  }

  Future<void> _createUserWithEmailAndPassword() async {
    if (emailController.text == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Complete all the fields"),
            content: const Text("provide an email"),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    if (passwordController.text != rePasswordController.text) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Password  Error"),
            content: const Text("provide same password for both fields"),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    if (passwordController.text.length < 8) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Password is weak"),
            content: const Text(
                "Provide strong password with atleast eight characters"),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    if (nameController.text == "") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Name field empty"),
            content: const Text("Provide a name"),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    if (!validateEmail(emailController.text)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Email is invalid"),
            content: const Text("Provide a valid email"),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Create a new document in the "users" collection with the user's ID as the document ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'name': nameController.text,
        'toxic': [],
      });

      // User registration successful, you can perform further actions or navigate to another screen
      print('User registered successfully: ${userCredential.user?.uid}');
      await userCredential.user?.sendEmailVerification();
      //Navigator.pushNamed(context, '/toxic');
    } catch (e) {
      // Handle errors during user registration
      print('Error creating user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          // Column(
          //   children: <Widget>[
          //     const Expanded(
          //       flex: 3,
          //       child: Image(
          //         image: AssetImage('assets/images/signup_art.jpg'),
          //       ),
          //     ),
          //     Expanded(
          //       flex: 5,
          //       child: Container(
          //         padding: const EdgeInsets.all(20),
          //         child: Column(
          //           children: <Widget>[
          //             EmailInputField(inputController: emailController),
          //             const SizedBox(height: 20),
          //             PasswordInputField(inputController: passwordController),
          //             const SizedBox(height: 20),
          //             PasswordInputField(inputController: rePasswordController),
          //             const SizedBox(height: 20),
          //             NameInputField(inputController: nameController),
          //             const SizedBox(height: 20),
          //
          //             SizedBox(
          //               width: double.infinity,
          //               child: ElevatedButton(
          //                 onPressed: () async {
          //                   setState(() {
          //                     _isLoading = true;
          //                   });
          //                   await _createUserWithEmailAndPassword();
          //                   setState(() {
          //                     _isLoading = false;
          //                   });
          //                 },
          //                 style: ElevatedButton.styleFrom(
          //                   primary: const Color(0xFF1ea99a),
          //                 ),
          //                 child: _isLoading
          //                     ? const CircularProgressIndicator(
          //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //                 ) // Show loading indicator
          //                     : const Text('Sign Up'),
          //               ),
          //             ),
          //             const SizedBox(height: 20),
          //             const Text(
          //               'Already have an account?',
          //               style: TextStyle(
          //                 color: Color(0xFFfdc542),
          //               ),
          //             ),
          //             const SizedBox(height: 20),
          //             SizedBox(
          //               width: double.infinity,
          //               child: ElevatedButton(
          //                 onPressed: () {
          //                   Navigator.pushNamed(context, '/login');
          //                   print(emailController.text);
          //                 },
          //                 style: ElevatedButton.styleFrom(
          //                   primary: const Color(0xFFfb6d65),
          //
          //                 ),
          //                 child: const Text('Login'),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),

          SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Container(
            height: 900,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('images/backblue.jpg'),
              fit: BoxFit.fitHeight,
            )),
            child: Column(
              children: [
                SizedBox(
                  height: 110,
                  width: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Create an Account !",
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
                      width: 20,
                    ),
                    Text(
                      "Let's protect your ",
                      style: TextStyle(fontSize: 40, color: Colors.black),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Health with us ! ",
                      style: TextStyle(fontSize: 40, color: Colors.black87),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          EmailInputField(inputController: emailController),
                          const SizedBox(height: 10),
                          PasswordInputField(
                              inputController: passwordController),
                          const SizedBox(height: 10),
                          PasswordInputField(
                              inputController: rePasswordController),
                          const SizedBox(height: 10),
                          NameInputField(inputController: nameController),
                          const SizedBox(height: 0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await _createUserWithEmailAndPassword();
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                primary: const Color(0xFF1ea99a),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ) // Show loading indicator
                                  : const Text('Sign Up'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account?',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Navigate to the new page when the text is tapped
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Tabbar()),
                                  );
                                },
                                child: const Text(
                                  '    Sign In?',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
