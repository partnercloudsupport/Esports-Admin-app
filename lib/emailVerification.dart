import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'colors.dart';
import 'databaseOperations/Backend.dart';
import 'utilities.dart';

class EmailVerification extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EmailVerificationState();
  }
}

class EmailVerificationState extends State<EmailVerification>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  var formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  AppBar appbar() {
    return AppBar(
      title: const Text('Verify your email'),
      backgroundColor: Colors.orange,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: appbar(),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Scaffold(
              backgroundColor: Themes.theme1['CardColor'],
              resizeToAvoidBottomPadding: false,
              body: FadeTransition(
                opacity: animation,
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: Container(
                        child: Image.asset('images/email.png'),
                        height: 150,
                        width: 150,
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      'Please verify your email address',
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                     FlatButton(
                      onPressed: (){
                        Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                      },
                      child: const Text('Login?',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Poppins',fontSize: 18)),
                    )
                  ],
                ),
              ),
            ),
          )),
      onWillPop: () {
        return Future<bool>(() => true);
      },
    );
  }
}
