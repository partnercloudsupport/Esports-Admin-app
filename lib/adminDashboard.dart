import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RolesEnum.dart';

import 'coachDashboard.dart';
import 'colors.dart';
import 'leagueSettings.dart';
import 'selectSubleague.dart';
import 'subleagueSettings.dart';
import 'utilities.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard(this.leagueName, this.role);

  final String leagueName;
  final String role;

  @override
  State<StatefulWidget> createState() {
    return AdminDashboardState();
  }
}

class AdminDashboardState extends State<AdminDashboard> {
  Widget adminHalf(String role) {
    return FlatButton(
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Themes.theme1['SecondGradientColor'],
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
                  color: Themes.theme1['SubTextColor'],
                )),
            borderRadius: BorderRadius.all(Radius.circular(1)),
          )
        ]),
      ),
    );
  }

  Widget coachHalf(String role) {
    return FlatButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.push<Object>(context,
            MaterialPageRoute<CoachDashboard>(builder: (BuildContext context) {
          return CoachDashboard(widget.leagueName, widget.role);
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
            borderRadius: BorderRadius.all(Radius.circular(1)),
          )
        ]),
      ),
    );
  }

  Future<Widget> returnRoles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String role = prefs.getString(Utilities.ROLE_NAME);
    if (role == Role.adminAndCoach.toString() ||
        role == Role.president.toString()) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[adminHalf(role), Spacer(), coachHalf(role)],
      );
    } else if (role == Role.admin.toString()) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          adminHalf(role),
          Spacer(),
        ],
      );
    } else if (role == Role.coach.toString()) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          coachHalf(role),
          Spacer(),
        ],
      );
    } else {
      return Text('You DOnt have access');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Themes.theme1['CardColor'],
        body: Container(
            color: Themes.theme1['CardColor'],
            margin: const EdgeInsets.only(bottom: 70),
            child: ListView(children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  Text(
                    'Coach Dashboard',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  Spacer()
                ],
              ),
              Container(
                  child: FutureBuilder<Widget>(
                      future: returnRoles(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Widget> snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data;
                        }
                        return const CircularProgressIndicator();
                      })),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  Text(
                    widget.leagueName,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                  Spacer()
                ],
              ),
              Row(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.push<Object>(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return SelectSubleague(widget.leagueName);
                      }));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Themes.theme1['PrimaryColor'],
                      ),
                      constraints: BoxConstraints(
                          minHeight: 73,
                          maxHeight: 73,
                          minWidth:
                              MediaQuery.of(context).size.width * 0.5 - 40,
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.5 - 40),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              child: Container(
                                  width: 40,
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Image.asset('images/dumbbell.png')),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                            ),
                            Container(
                                width: 100,
                                margin: const EdgeInsets.only(top: 10, left: 0),
                                child: Column(
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text('League Update',
                                        softWrap: true,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white))
                                  ],
                                )),
                          ]),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.push<Object>(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return LeagueSettings(widget.leagueName);
                      }));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Themes.theme1['PrimaryColor'],
                      ),
                      constraints: BoxConstraints(
                          minHeight: 73,
                          maxHeight: 73,
                          minWidth:
                              MediaQuery.of(context).size.width * 0.5 - 40,
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.5 - 40),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              child: Container(
                                  width: 40,
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Icon(
                                    Icons.settings,
                                    size: 40,
                                    color: Colors.white,
                                  )),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                            ),
                            Container(
                                width: 100,
                                margin: const EdgeInsets.only(top: 10, left: 0),
                                child: Column(
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text('League Settings',
                                        softWrap: true,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white))
                                  ],
                                )),
                          ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.push<Object>(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return SelectSubleague(widget.leagueName);
                      }));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Themes.theme1['PrimaryColor'],
                      ),
                      constraints: BoxConstraints(
                          minHeight: 73,
                          maxHeight: 73,
                          minWidth:
                              MediaQuery.of(context).size.width * 0.5 - 40,
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.5 - 40),
                      child: Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              ClipRRect(
                                child: Container(
                                    width: 40,
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child:
                                        Image.asset('images/permission.png')),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(1)),
                              ),
                              Container(
                                  width: 100,
                                  margin:
                                      const EdgeInsets.only(top: 10, left: 0),
                                  child: Column(
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text('Role Management',
                                          softWrap: true,
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white))
                                    ],
                                  )),
                            ]),
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.push<Object>(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return SubleagueSettings(widget.leagueName);
                      }));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Themes.theme1['PrimaryColor'],
                      ),
                      constraints: BoxConstraints(
                          minHeight: 73,
                          maxHeight: 73,
                          minWidth:
                              MediaQuery.of(context).size.width * 0.5 - 40,
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.5 - 40),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              child: Container(
                                  width: 40,
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Image.asset(
                                      'images/subleagueSettings.png')),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                            ),
                            Container(
                                width: 100,
                                margin: const EdgeInsets.only(top: 10, left: 0),
                                child: Column(
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text('Subleague Settings',
                                        softWrap: true,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white))
                                  ],
                                )),
                          ]),
                    ),
                  ),
                ],
              )
            ])));
  }
}
