import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  LoginFormState createState() => LoginFormState();

}

class LoginFormState extends State<LoginForm>{
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        const Image(
          image: AssetImage('images/login_art.png'),
        ),
        const TextField(
          decoration: InputDecoration(
            hintText: 'Enter your email',
          ),
        ),
        const TextField(
          decoration: InputDecoration(
            hintText: 'Enter your password',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Respond to button press
            //make a toast message

          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}