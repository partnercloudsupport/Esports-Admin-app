import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'RolesEnum.dart';

import 'adminDashboard.dart';
import 'coachDashboard.dart';
import 'colors.dart';
import 'newsBoard.dart';
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

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    animationController.repeat(min: 0, max: 0.5);
    checkRole().whenComplete((){
    setState(() {
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
    if (data.data['President'] != null && data.data['President']['id'] == user.email.replaceAll('.', '-')) {
      role = Role.president;
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
    if (isAdmin && isCoach) {
      role = Role.adminAndCoach;
    }
    if (isAdmin) {
      role = Role.admin;
    }
    if (isCoach) {
      role = Role.coach;
    }
    role = Role.unknown;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget adminHalf(String role) {
    return FlatButton(
      onPressed: () {
        Navigator.push<Object>(context,
            MaterialPageRoute<AdminDashboard>(builder: (BuildContext context) {
          return AdminDashboard(widget.leagueName, role);
        }));
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Themes.theme1['PrimaryColor'],
        ),
        constraints: BoxConstraints(
            minHeight: 93,
            maxHeight: 93,
            minWidth: MediaQuery.of(context).size.width * 0.5 - 40),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Container(
              margin: const EdgeInsets.only(top: 20, left: 20),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.verified_user,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('Admin',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white))
                ],
              )),
          ClipRRect(
            child: Container(
                width: 70,
                child: Icon(
                  Icons.verified_user,
                  size: 130,
                  color: Themes.theme1['FirstGradientColor'],
                )),
            borderRadius: const BorderRadius.all(Radius.circular(1)),
          )
        ]),
      ),
    );
  }

  Widget coachHalf(String role) {
    return FlatButton(
      onPressed: () {
        Navigator.push<Object>(context,
            MaterialPageRoute<CoachDashboard>(builder: (BuildContext context) {
          return CoachDashboard(widget.leagueName, role);
        }));
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Themes.theme1['PrimaryColor'],
        ),
        constraints: BoxConstraints(
            minHeight: 93,
            maxHeight: 93,
            minWidth: MediaQuery.of(context).size.width * 0.5 - 40),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Container(
              margin: const EdgeInsets.only(top: 20, left: 20),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.supervised_user_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('Coach',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white))
                ],
              )),
          ClipRRect(
            child: Container(
                width: 70,
                child: Icon(
                  Icons.supervised_user_circle,
                  size: 130,
                  color: Themes.theme1['FirstGradientColor'],
                )),
            borderRadius: const BorderRadius.all(Radius.circular(1)),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(tabs: <Widget>[
            Tab(
              child: const Text('News Board'),
            ),
            Tab(child: const Text('Admin')),
            Tab(child: const Text('Coach')),
          ]),
          title: const Text('Dashboard'),
          backgroundColor: Colors.orange,
          actions: <Widget>[
            FlatButton(
              child: Container(
                child: Image.asset('images/logout.png'),
                height: 30,
                width: 30,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            )
          ],
        ),
        backgroundColor: Themes.theme1['CardColor'],
        body: ModalProgressHUD(inAsyncCall: isLoading, child: TabBarView(children: [NewsBoard(widget.leagueName),AdminDashboard(widget.leagueName, role.toString()),Text('ds')]))
      ),
    );
  }
}
