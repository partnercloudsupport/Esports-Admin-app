import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RolesEnum.dart';

import 'coachDashboard.dart';
import 'colors.dart';
import 'leagueSettings.dart';
import 'newUsersList.dart';
import 'roleManagement.dart';
import 'selectSubleague.dart';
import 'subleagueSettings.dart';
import 'utilities.dart';

class PresidentDashboard extends StatefulWidget {
  const PresidentDashboard(this.leagueName, this.role);

  final String leagueName;
  final String role;

  @override
  State<StatefulWidget> createState() {
    return PresidentDashboardState();
  }
}

class PresidentDashboardState extends State<PresidentDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Themes.theme1['CardColor'],
        body: Container(
            color: Themes.theme1['CardColor'],
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                GridTile(
                  child: FlatButton(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 10, right: 10),
                    onPressed: () {
                      Navigator.push<Object>(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                            return NewUsersList(widget.leagueName);
                          }));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Themes.theme1['PrimaryColor'],
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              child: Container(height: 100,
                                  width: 40,
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Image.asset('images/envelope.png')),
                              borderRadius:
                              const BorderRadius.all(Radius.circular(1)),
                            ),
                            Text('Request by new users',
                                softWrap: true,
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white)),
                          ]),
                    ),
                  ),
                ),
              ],
            )));
  }
}
