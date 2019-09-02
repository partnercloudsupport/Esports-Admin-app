import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/services.dart';
import 'colors.dart';
import 'launchPage.dart';

void main() {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
//  Crashlytics.instance.enableInDevMode = true;


  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.recordFlutterError(details);
  };


  runApp(MyApp());
}

class MyApp extends StatelessWidget {



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    Themes();
    return MaterialApp(

      theme: ThemeData(
        primaryColor: Colors.white,
      ),

      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() =>  _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    startTime();
    super.initState();

  }


  void navigationPage() {
    Navigator.of(context).pushReplacement<Object,Object>(MaterialPageRoute<LaunchPage>(builder: (BuildContext context){
      return LaunchPage();
    }));
  }

  Future<Timer> startTime() async {
    final Duration _duration = Duration(seconds: 6);
    return Timer(_duration, navigationPage);
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Themes.theme1['CardColor'],
      body: Center(child: Image.asset('images/splash.gif'),),
    );
  }
}


