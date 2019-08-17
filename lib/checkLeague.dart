import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/cupertino.dart';

//import 'package:ads/ads.dart';
import 'colors.dart';
import 'databaseOperations/Backend.dart';
import 'enterLeagueName.dart';
import 'existingLogin.dart';
import 'login.dart';
import 'utilities.dart';


class CheckLeaguePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CheckLeaguePageState();
  }
}

class CheckLeaguePageState extends State<CheckLeaguePage> {
  var controller = TextEditingController(text: '');
  var emailController = TextEditingController(text: '');
  final GlobalKey<FormState> _controllerKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailKey = GlobalKey<FormState>();
  SharedPreferences prefs;
  String leagueID = '';
  FirebaseUser auth;
  bool isLoading = false;
  final utilities = Utilities();
//  Ads ads;

  @override
  void initState() {
    super.initState();
    updateLeagueIDFromPrefs();
    //    ads = Utilities.showBannerAds();
    Backend.readLeagueData();
    instantiateSharedPreference();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> instantiateSharedPreference() async{
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> updateLeagueIDFromPrefs() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    controller.text = prefs.get(Utilities.LEAGUE_ID) ?? '';
  }
  

  @override
  Widget build(BuildContext context) {
//    ads.showBannerAd(state: this);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Themes.theme1['PrimaryColor'],
      body: ModalProgressHUD(inAsyncCall: this.isLoading, child:


      Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  0.7,
                  0.8
                ],
                colors: [
                  Themes.theme1['CardColor'],
                  Themes.theme1['PrimaryColor']
                ])),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              color: Themes.theme1['TableColor'],
              padding:
              EdgeInsets.only(left: 40, right: 40, top: 40, bottom: 40),
              child: Text(
                ' ',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 20),
              width: MediaQuery.of(context).size.width,
              child: Text(
                'Please enter you league id if you already have an account.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 20),
              child: Form(
                  key: _controllerKey,
                  child: TextFormField(
                    controller: controller,
                    validator: (String arg) {
                      if (arg.length < 4)
                        return 'League ID must be atleast 5 characters long';
                      else
                        return null;
                    },
                    style: TextStyle(
                      color: Themes.theme1['TextColor'],
                      fontFamily: 'Arial',
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 14),
                        hintText: 'League ID',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),filled: true, fillColor: Themes.theme1['TextFieldFillColor'],
                        hintStyle: CustomTextStyles.regularText,
                        suffixIcon: Icon(
                          Icons.search,
                          color: Themes.theme1['TextColor'],
                        )),
                  )),

            ),
            Container(
                margin: EdgeInsets.only(top: 40, left: 40, right: 40),
                child: RaisedGradientButton(
                    child:
                    Text('Confirm', style: CustomTextStyles.boldLargeText),
                    gradient: LinearGradient(colors: [
                      Themes.theme1['FirstGradientColor'],
                      Themes.theme1['SecondGradientColor']
                    ]),
                    onPressed: () async{
                      if (_controllerKey.currentState.validate()) {
                        if (Backend.checkLeagueID(controller.text) !=
                            'League already exists') {
                          if (Platform.isAndroid) {
                            showDialog<AlertDialog>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Themes.theme1['CardColor'],
                                    title: Text(
                                      'Invalid league ID',
                                      style: TextStyle(
                                        color: Themes.theme1['TextColor'],
                                      ),
                                    ),
                                    content: Text(
                                      'Please enter correct league id.',
                                      style: TextStyle(
                                        color: Themes.theme1['TextColor'],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      IconButton(
                                        icon: Icon(
                                          Icons.done,
                                          color: Themes.theme1['TextColor'],
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
//                                        Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  );
                                });
                          } else {
                            showDialog<CupertinoAlertDialog>(
                                context: context,
                                builder: (BuildContext context) {
                                  return Utilities.iosAlert(
                                      'Invalid league ID',
                                      'Please enter correct league id',
                                      context);
                                });
                          }
                        } else {

                          utilities.logEvent('login_page');
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString(Utilities.LEAGUE_ID, controller.text);
                          Navigator.push<Object>(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                                return Login(controller.text);
                              }));
                        }
                      }
                    })),Container(
                margin: EdgeInsets.only(top: 40, left: 40, right: 40),
                child: RaisedGradientButton(
                    child:
                    Text('Create new league', style: CustomTextStyles.boldLargeText),
                    gradient: LinearGradient(colors: [
                      Themes.theme1['FirstGradientColor'],
                      Themes.theme1['SecondGradientColor']
                    ]),
                    onPressed: () {
                      Navigator.push<Object>(context, MaterialPageRoute(builder: (BuildContext context){
                        return EnterLeagueName();
                      }));
                    })),
            Container(
              margin: EdgeInsets.only(top: 20, left: 40, right: 40),
              child: FlatButton(
                  onPressed: () {
                    if(Platform.isAndroid){
                      showDialog<AlertDialog>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Themes.theme1['CardColor'],
                              title: Text(
                                'Please enter your email id',
                                style: TextStyle(
                                  color: Themes.theme1['TextColor'],
                                ),
                              ),
                              content: Container(
                                child: Form(
                                    key: _emailKey,
                                    child: TextFormField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                          errorStyle: TextStyle(fontSize: 14)),
                                      validator: (String emailID) {
                                        if (emailID.isEmpty) {
                                          return 'Please enter your email id.';
                                        } else if (RegExp(
                                            r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                                            .hasMatch(emailID) ==
                                            false) {
                                          return 'Entered email is not valid';
                                        }
                                      },
                                      style: TextStyle(
                                        color: Themes.theme1['TextColor'],
                                      ),
                                    )),
                                margin: EdgeInsets.only(
                                    top: 10, left: 10, bottom: 10, right: 10),
                              ),
                              actions: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.mail,
                                    color: Themes.theme1['TextColor'],
                                  ),
                                  onPressed: () {
                                    if (_emailKey.currentState.validate()) {
                                      Backend.checkIfUserExists(
                                          emailController.text)
                                          .then((value) {
                                        if ('User exists' == value) {
                                          showDialog<AlertDialog>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                  Themes.theme1['CardColor'],
                                                  title: Text(
                                                    'Email is sent',
                                                    style: TextStyle(
                                                      color: Themes
                                                          .theme1['TextColor'],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    IconButton(
                                                      icon: Icon(Icons.done,
                                                          color: Themes.theme1[
                                                          'TextColor']),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        } else {
                                          Navigator.pop(context);
                                          showDialog<AlertDialog>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                  Themes.theme1['CardColor'],
                                                  title: Text(
                                                    'User does not exist',
                                                    style: TextStyle(
                                                      color: Themes
                                                          .theme1['TextColor'],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    IconButton(
                                                      icon: Icon(Icons.done,
                                                          color: Themes.theme1[
                                                          'TextColor']),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        }
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Themes.theme1['TextColor'],
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
                    }
                    else{
                      showDialog<CupertinoAlertDialog>(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text(
                                'Please enter your email id',
                                style: TextStyle(
                                  color: Themes.theme1['TextColor'],
                                ),
                              ),
                              content: Container(
                                child: Form(
                                    key: _emailKey,
                                    child: TextFormField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                          errorStyle: TextStyle(fontSize: 14)),
                                      validator: (String emailID) {
                                        if (emailID.isEmpty) {
                                          return 'Please enter your email id.';
                                        } else if (RegExp(
                                            r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                                            .hasMatch(emailID) ==
                                            false) {
                                          return 'Entered email is not valid';
                                        }
                                      },
                                      style: TextStyle(
                                        color: Themes.theme1['TextColor'],
                                      ),
                                    )),
                                margin: EdgeInsets.only(
                                    top: 10, left: 10, bottom: 10, right: 10),
                              ),
                              actions: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.mail,
                                    color: Themes.theme1['TextColor'],
                                  ),
                                  onPressed: () {
                                    if (_emailKey.currentState.validate()) {
                                      Backend.checkIfUserExists(
                                          emailController.text)
                                          .then((value) {
                                        if ('User exists' == value) {
                                          showDialog<CupertinoAlertDialog>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CupertinoAlertDialog(
                                                  title: Text(
                                                    'Email is sent',
                                                    style: TextStyle(
                                                      color: Themes
                                                          .theme1['TextColor'],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    IconButton(
                                                      icon: Icon(Icons.done,
                                                          color: Themes.theme1[
                                                          'TextColor']),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        } else {
                                          Navigator.pop(context);
                                          showDialog<CupertinoAlertDialog>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CupertinoAlertDialog(

                                                  title: Text(
                                                    'User does not exist',
                                                    style: TextStyle(
                                                      color: Themes
                                                          .theme1['TextColor'],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    IconButton(
                                                      icon: Icon(Icons.done,
                                                          color: Themes.theme1[
                                                          'TextColor']),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        }
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Themes.theme1['TextColor'],
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
                    }

                  },
                  child: Text('Forgot ID?',
                      style: CustomTextStyles.boldLargeText)),
            ),
            Container(
              child: FlatButton(
                  onPressed: () {
                    Navigator.push<Object>(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                          return ExistingLogin(leagueID);
                        }));
                  },
                  child: Text('Already have an account?',
                      style: CustomTextStyles.boldLargeText)),
            )
          ],
        ),
      )),
    );
  }
}
