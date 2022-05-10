import 'dart:async';
// ignore: import_of_legacy_library_into_null_safe
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:test_app/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // implement createState
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // implement initState
    super.initState();
    startTimer();
  }

  void startTimer() {
    Timer(const Duration(seconds: 1), () {
      Navigator.of(context).pushNamedAndRemoveUntil('/home',
          (Route<dynamic> route) => false); //It will redirect  after 3 seconds
    });
  }

  /*void navigateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;

    if (status) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
     
    }
  }*/
  //Color.fromARGB(255, 249, 229, 163);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 400,
              margin: const EdgeInsets.only(top: 120),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(200)),
                //color: couleurJaune,
                image: DecorationImage(
                    image: AssetImage("assets/images/M2L net rond.png"),
                    fit: BoxFit.cover),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
            ),
            const Text(
              "Bienvenue à la Maison des Ligues",
              style: TextStyle(
                  color: rouge, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
