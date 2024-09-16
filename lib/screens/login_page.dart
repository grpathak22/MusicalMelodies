import 'package:flutter/material.dart';
import 'package:myapp/screens/home_screen.dart';

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

  void _handleGoogleBtnClick() {
    // Placeholder for Google sign-in logic (Firebase integration here later)
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text('Google Sign-In'),
    //     content: Text('Google Sign-In logic will be here.'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => HomeScreen(studentName: "hagya"),
    //         child: Text('OK'),
    //       ),
    //     ],
    //   ),
    // );
    // Direct navigation to HomeScreen after clicking sign-in
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => HomeScreen(studentName: "hagya"),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * .25,
              right: _isAnimate ? mq.width * 0.1 : mq.width * .15,
              width: mq.width * 0.8,
              duration: const Duration(milliseconds: 600),
              child: Image.asset('assets/png/logo-no-background.png')), // Updated logo path
          Positioned(
              bottom: mq.height * 0.15,
              left: mq.width * 0.05,
              width: mq.width * 0.9,
              height: mq.height * 0.07,
              child: ElevatedButton.icon(
                  onPressed: _handleGoogleBtnClick,
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                      width: 2,
                    ),
                    shape: StadiumBorder(),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  icon: Transform.scale(
                    scale: 0.55,
                    child: Image.asset('assets/google.png'), // Google icon
                  ),
                  label: RichText(
                    text: const TextSpan(children: [
                      TextSpan(
                          text: 'Sign in with Google',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'abz',
                              color: Colors.black)),
                    ]), // Theme-matching text style
                  ))),
        ],
      ),
    );
  }
}

