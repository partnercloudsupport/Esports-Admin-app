import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'RolesEnum.dart';
import 'adminDashboard.dart';
import 'coachDashboard.dart';
import 'colors.dart';
import 'launchPage.dart';
import 'newsBoard.dart';
import 'presidentDashboard.dart';
import 'profilePage.dart';
import 'utilities.dart';

class Dashboard extends StatefulWidget {
  Dashboard(this.leagueName);
  final String leagueName;
  @override
  State<StatefulWidget> createState() {
    return DashboardState();
  }
}

class DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  Role role;
  AnimationController animationController;
  bool isLoading = false;

  int numberOfTabs = 1;
  List<String> tabStrings = <String>[''];
  List<Widget> tabViews = <Widget>[const Text('')];

  void updateTabs() {
    if (role == Role.president) {
      numberOfTabs = 4;
      tabStrings = <String>['News', 'Admin', 'Coach', 'President'];
      tabViews = <Widget>[
        NewsBoard(widget.leagueName),
        AdminDashboard(widget.leagueName, role.toString()),
        Text('ds'),
        PresidentDashboard(widget.leagueName, role.toString()),
      ];
    } else if (role == Role.adminAndCoach) {
      numberOfTabs = 3;
      tabStrings = <String>['News', 'Admin', 'Coach'];
      tabViews = <Widget>[
        NewsBoard(widget.leagueName),
        AdminDashboard(widget.leagueName, role.toString()),
        Text('ds')
      ];
    } else if (role == Role.admin) {
      numberOfTabs = 2;
      tabStrings = <String>['News', 'Admin'];
      tabViews = <Widget>[
        NewsBoard(widget.leagueName),
        AdminDashboard(widget.leagueName, role.toString()),
      ];
    } else if (role == Role.coach) {
      numberOfTabs = 2;
      tabStrings = <String>['News', 'Coach'];
      tabViews = <Widget>[
        NewsBoard(widget.leagueName),
        AdminDashboard(widget.leagueName, role.toString()),
      ];
    } else {
      print('ddd');
    }
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    animationController.repeat(min: 0, max: 0.5);
    checkRole().whenComplete(() {
      setState(() {
        updateTabs();
        isLoading = false;
      });
    });
    super.initState();
  }

  Future<void> checkRole() async {
    bool isAdmin = false;
    bool isCoach = false;
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final DocumentSnapshot data = await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .get();
    if (data.data['President'] != null &&
        data.data['President']['id'] == user.email.replaceAll('.', '-')) {
      role = Role.president;
      return;
    }
    final QuerySnapshot admins = await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .collection('Admins')
        .getDocuments();
    for (DocumentSnapshot doc in admins.documents) {
      if (doc.documentID == user.email.replaceAll('.', '-')) {
        isAdmin = true;
        break;
      }
    }
    final QuerySnapshot coaches = await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .collection('Coaches')
        .getDocuments();
    for (DocumentSnapshot doc in coaches.documents) {
      if (doc.documentID == user.email.replaceAll('.', '-')) {
        isCoach = true;
        break;
      }
    }
    role = Role.unknown;

    if (isAdmin && isCoach) {
      role = Role.adminAndCoach;
    }
    if (isAdmin) {
      role = Role.admin;
    }
    if (isCoach) {
      role = Role.coach;
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: DefaultTabController(
        length: numberOfTabs,
        child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                  tabs: tabStrings
                      .map((String tabValue) => Container(
                            child: Text(
                              tabValue,
                              style: const TextStyle(
                                  fontSize: 12, fontFamily: 'Poppins'),
                            ),
                            height: 30,
                          ))
                      .toList()),
              title: const Text('Dashboard',style: TextStyle(color: Colors.white),),
              leading: FlatButton(
                child: Container(
                  child: Icon(
                    Icons.supervised_user_circle,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute<ProfilePage>(
                      builder: (BuildContext context) {
                    return ProfilePage();
                  }));
                },
              ),
              backgroundColor: Colors.orange,
              actions: <Widget>[
                FlatButton(
                  child: Container(
                    child: Image.asset('images/logout.png'),
                    height: 30,
                    width: 30,
                  ),
                  onPressed: () {
                    if (Platform.isIOS) {
                      showCupertinoDialog<CupertinoAlertDialog>(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text('Do you want to logout?'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  isDefaultAction: false,
                                  onPressed: () {
                                    Navigator.pop(context);

                                    FirebaseAuth.instance.signOut();
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute<LaunchPage>(
                                            builder: (BuildContext context) {
                                      return LaunchPage();
                                    }));
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
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
                              title: const Text('Do you want to logout?'),
                              actions: <Widget>[
                                FlatButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.pop(context);

                                    FirebaseAuth.instance.signOut();
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute<LaunchPage>(
                                            builder: (BuildContext context) {
                                      return LaunchPage();
                                    }));
                                  },
                                ),
                                FlatButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
                    }
                  },
                ),
              ],
            ),
            backgroundColor: Themes.theme1['CardColor'],
            body: ModalProgressHUD(
                inAsyncCall: isLoading, child: TabBarView(children: tabViews))),
      ),
    );
  }
}
