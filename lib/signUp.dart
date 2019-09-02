import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'emailVerification.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignUpPageState();
  }
}

class SignUpPageState extends State<SignUpPage> {
  bool lock = true;
  bool showText = true;
  bool showLoader = false;
  var formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController password = TextEditingController(text: '');
  TextEditingController rePassword = TextEditingController(text: '');

  Icon lockIcon() {
    if (lock) {
      return Icon(
        Icons.lock,
        color: Colors.white,
      );
    } else {
      return Icon(
        Icons.lock_open,
        color: Colors.white,
      );
    }
  }

  void toggle() {
    setState(() {
      if (lock) {
        lock = false;
        showText = false;
      } else {
        lock = true;
        showText = true;
      }
    });
  }

  Color buttonColor() {
    if (emailController.text.length >= 5 && password.text.length >= 8) {
      return Colors.orange;
    }
    return Colors.orange[200];
  }

  Future<void> signUpAction() async {
    if (emailController.text.length >= 5 && password.text.length >= 8) {
      try{
        final List<InternetAddress> result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          setState(() {
            showLoader = true;
          });
          final FirebaseAuth instance = FirebaseAuth.instance;
          final FirebaseUser user = await instance.createUserWithEmailAndPassword(
              email: emailController.text, password: password.text);
          await user.sendEmailVerification();
          setState(() {
            showLoader = false;
          });
          Navigator.push<Object>(context, MaterialPageRoute<EmailVerification>(builder: (BuildContext context){
            return EmailVerification();
          }));

        }
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
        }
        else {
          showDialog<AlertDialog>(context: context, builder: (BuildContext context){
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
      } catch (e) {
        print(e);
        setState(() {
          showLoader = false;
        });
        if (Platform.isIOS) {
          showCupertinoDialog<CupertinoAlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('Some error occurred'),
                  content: const Text('Sign in failed.'),
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
        }
        else {
          showDialog<AlertDialog>(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: const Text('Some error occurred'),
              content: const Text('Sign in failed.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Text('Sign up'),
        backgroundColor: Colors.orange,
      ),
      body: GestureDetector(
        child: ModalProgressHUD(
            inAsyncCall: showLoader,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Form(
                key: formKey,
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 16, top: 16),
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Themes.theme1['TextColor']),
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 16, right: 16),
                      child: Theme(
                        child: TextFormField(
                          controller: emailController,
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
                                borderSide: BorderSide(color: Colors.cyan),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Themes.theme1['SubTextColor']),
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
                      height: 16,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 16, right: 16),
                      child: Theme(
                        child: TextFormField(
                          controller: password,
                          autocorrect: false,
                          onSaved: (String password) {},
                          validator: (String value) {
                            if ((value.length >= 8 || value.length <= 1) && password.text == rePassword.text) {
                              return null;
                            }
                            return '';
                          },
                          autovalidate: true,
                          obscureText: showText,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  icon: lockIcon(),
                                  onPressed: () {
                                    toggle();
                                  }),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.cyan),
                              ),
                              hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Themes.theme1['SubTextColor']),
                              hintText: 'Password'),
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Themes.theme1['TextColor']),
                        ),
                        data: ThemeData(primaryColor: Colors.orange),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 16, right: 16),
                      child: Theme(
                        child: TextFormField(
                          controller: rePassword,
                          autocorrect: false,
                          onSaved: (String password) {},
                          validator: (String value) {
                            if ((value.length >= 8 || value.length <= 1) && password.text == rePassword.text) {
                              return null;
                            }
                            return '';
                          },
                          autovalidate: true,
                          obscureText: showText,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  icon: lockIcon(),
                                  onPressed: () {
                                    toggle();
                                  }),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.cyan),
                              ),
                              hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Themes.theme1['SubTextColor']),
                              hintText: 'Retype Password'),
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Themes.theme1['TextColor']),
                        ),
                        data: ThemeData(primaryColor: Colors.orange),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: buttonColor()),
                      margin: const EdgeInsets.only(left: 16, right: 16),
                      height: 40,
                      child: FlatButton(
                          onPressed: () {
                            try{
                              signUpAction();
                            }
                            catch (e) {
                              print(e);
                              if (Platform.isIOS) {
                                showCupertinoDialog<CupertinoAlertDialog>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: const Text('Some error occurred'),
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
                              }
                              else {
                                showDialog<AlertDialog>(context: context, builder: (BuildContext context){
                                  return AlertDialog(
                                    title: const Text('Some error occurred'),
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
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(color: Colors.black),
                          )),
                    )
                  ],
                ),
              ),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Themes.theme1['CardColor'],
                Themes.theme1['PrimaryColor']
              ], stops: const <double>[
                1,
                0.0
              ])),
            )),
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
      ),
    );
  }
}
