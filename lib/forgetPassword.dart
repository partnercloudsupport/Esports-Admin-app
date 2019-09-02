import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'colors.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ForgotPasswordState();
  }
}

class ForgotPasswordState extends State<ForgotPassword>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  var formKey = GlobalKey<FormState>();
  bool showLoader = false;
  Color buttonColor = Colors.orange;
  TextEditingController email = TextEditingController(text: '');

  void forgotPassword() async {
    try {
      if (email.text.length >= 5 &&
          RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
              .hasMatch(email.text)) {
        buttonColor = Colors.orange;
        final List<InternetAddress> result =
            await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          setState(() {
            showLoader = true;
          });
          FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);

          if (Platform.isIOS) {
            showCupertinoDialog<CupertinoAlertDialog>(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                    title: const Text('Success'),
                    content: const Text('Verification email sent.'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        isDefaultAction: true,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                });
          } else {
            showDialog<AlertDialog>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Success'),
                    content: const Text('Verification email sent.'),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                });
          }
        }
      } else {
        buttonColor = Colors.orange[100];
      }
      setState(() {
        showLoader = false;
      });
    } on SocketException catch (_) {
      setState(() {
        showLoader = false;
      });
      if (Platform.isIOS) {
        showCupertinoDialog<CupertinoAlertDialog>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Some error occurred'),
                content: const Text('Verification email could not be sent.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      } else {
        showDialog<AlertDialog>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Some error occurred'),
                content: const Text('Verification email could not be sent.'),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }

    } on PlatformException catch (e) {
      setState(() {
        showLoader = false;
      });
      if (Platform.isIOS) {
        showCupertinoDialog<CupertinoAlertDialog>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Some error occurred'),
                content: const Text('Password reset email could not be sent.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      } else {
        showDialog<AlertDialog>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Some error occurred'),
                content: const Text('Verification email could not be sent.'),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }
    }
  }

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
      title: const Text('Forgot Password'),
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
            child: ModalProgressHUD(
                inAsyncCall: showLoader,
                child: Scaffold(
                  backgroundColor: Themes.theme1['CardColor'],
                  resizeToAvoidBottomPadding: false,
                  body: FadeTransition(
                    opacity: animation,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Container(
                            height: 400,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 40),
                            child: Form(
                              key: formKey,
                              child: ListView(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    child: Theme(
                                      child: TextFormField(
                                        controller: email,
                                        autocorrect: false,
                                        onSaved: (String email) {},
                                        validator: (String value) {
                                          if (RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                                                  .hasMatch(value) ||
                                              value.length <= 1) {
                                            return null;
                                          }
                                          return '';
                                        },
                                        autovalidate: true,
                                        decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.cyan),
                                            ),
                                            errorBorder: UnderlineInputBorder(
                                              borderSide:
                                                  BorderSide(color: Colors.red),
                                            ),
                                            hintStyle: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: Themes
                                                    .theme1['SubTextColor']),
                                            hintText: 'Email address'),
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Themes.theme1['TextColor']),
                                      ),
                                      data: ThemeData(
                                          primaryColor: Colors.orange,
                                          accentColor: Colors.cyan),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: buttonColor),
                                    margin: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    height: 40,
                                    child: FlatButton(
                                        onPressed: () {
                                          forgotPassword();
                                        },
                                        child:
                                            const Text('Send me instructions')),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
          )),
      onWillPop: () {
        return Future<bool>(() => true);
      },
    );
  }
}
