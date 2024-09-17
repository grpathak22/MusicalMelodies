import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/screens/home_screen.dart';
import 'dart:io';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Size mq;
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    // Start animation after a slight delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  void _handleGoogleBtnClick() async {
    final userCredential = await _signInWithGoogle();
    if (userCredential != null) {
      // Show success Snackbar
      _showSnackBar('Login Successful!', Colors.green);

      // Navigate to HomeScreen if login is successful
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(studentName: "hagya"),
        ),
      );
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Check for internet connectivity
      await InternetAddress.lookup('google.com');

      // Check if user is already signed in
      final GoogleSignInAccount? googleUser = GoogleSignIn().currentUser;
      if (googleUser == null) {
        // Trigger the authentication flow if no user is signed in
        final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: ['email']).signIn();
        if (googleUser == null) {
          // User canceled sign-in, return null
          return null;
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with Firebase
        return await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        // User is already signed in, get credentials from Google
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with Firebase
        return await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      // Show error Snackbar if something goes wrong
      _showSnackBar('Something went wrong (Check Internet)', Colors.red);
      return null;
    }
  }

  // Function to show a SnackBar with custom message and color
  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * .25,
            right: _isAnimate ? mq.width * 0.1 : mq.width * .15,
            width: mq.width * 0.8,
            duration: const Duration(milliseconds: 600),
            child: Image.asset('assets/png/logo-no-background.png'),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            left: mq.width * 0.05,
            width: mq.width * 0.9,
            height: mq.height * 0.07,
            child: ElevatedButton.icon(
              onPressed: _handleGoogleBtnClick,
              style: ElevatedButton.styleFrom(
                side: const BorderSide(width: 2),
                shape: const StadiumBorder(),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              icon: Transform.scale(
                scale: 0.55,
                child: Image.asset('assets/google.png'), // Google icon
              ),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(fontSize: 18, fontFamily: 'abz', color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
