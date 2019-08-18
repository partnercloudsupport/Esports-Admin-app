import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RolesEnum.dart';

import 'adminDashboard.dart';
import 'colors.dart';
import 'utilities.dart';

class CoachDashboard extends StatefulWidget {
  const CoachDashboard(this.leagueName,this.role);
  final String leagueName;
  final String role;
  @override
  State<StatefulWidget> createState() {
    return CoachDashboardState();
  }
}



class CoachDashboardState extends State<CoachDashboard> {
  Widget adminHalf(String role){
    return FlatButton(
      onPressed: () {
        Navigator.push<Object>(context,
            MaterialPageRoute<AdminDashboard>(builder: (BuildContext context) {
              return AdminDashboard(widget.leagueName,role);
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

  Widget coachHalf(String role){
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
            minWidth:
            MediaQuery.of(context).size.width * 0.5 - 40),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
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
                      color:
                      Themes.theme1['SubTextColor'],
                    )),
                borderRadius:
                const BorderRadius.all(Radius.circular(1)),
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
              const SizedBox(
                height: 10,
              ),
          Container(
              child: FutureBuilder<Widget>(
                  future: returnRoles(),
                  builder:
                      (BuildContext context, AsyncSnapshot<Widget> snapshot) {
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
            ])));
  }
}
