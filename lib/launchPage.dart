import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'colors.dart';
import 'mainPage.dart';
import 'signUp.dart';

class LaunchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LaunchState();
  }
}

class LaunchState extends State<LaunchPage> {
  Future<void> openTermsAndConditions() async {
    const String url = 'https://flutter.dev';
    launch(url);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          color: Themes.theme1['CardColor'],
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 40,
              ),
              Center(
                child: ClipRRect(
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    width: 150,
                    height: 150,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(150)),
                ),
              ),
              const SizedBox(
                height: 200,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.orange),
                margin: const EdgeInsets.only(left: 16, right: 16),
                height: 40,
                child: FlatButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute<WelcomePage>(
                          builder: (BuildContext context) {
                        return WelcomePage();
                      }));
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(color: Colors.black),
                    )),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.orange),
                margin: const EdgeInsets.only(left: 16, right: 16),
                height: 40,
                child: FlatButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute<WelcomePage>(
                          builder: (BuildContext context) {
                        return SignUpPage();
                      }));
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(color: Colors.black),
                    )),
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: MaterialButton(
                  onPressed: () {
                    openTermsAndConditions();
                  },
                  child: const Text(
                    'By continuing, you agree to terms and conditions',
                    style:
                        TextStyle(fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
              )),
            ],
//            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }
}
