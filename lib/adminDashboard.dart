import 'package:flutter/material.dart';
import 'coachDashboard.dart';
import 'colors.dart';
import 'leagueSettings.dart';
import 'selectSubleague.dart';
import 'subleagueSettings.dart';

class AdminDashboard extends StatefulWidget {
  final String leagueName;
  AdminDashboard(this.leagueName);
  @override
  State<StatefulWidget> createState() {
    return AdminDashboardState();
  }
}

class AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Themes.theme1["CardColor"],
        body: Container(
            color: Themes.theme1["CardColor"],
            margin: EdgeInsets.only(bottom: 70),
            child: ListView(children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  Spacer()
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    FlatButton(
                      child: Container(
                        margin: EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Themes.theme1["SecondGradientColor"],
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
                                  margin: EdgeInsets.only(top: 20, left: 20),
                                  child: Column(
                                    children: <Widget>[
                                      Icon(
                                        Icons.verified_user,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Admin",
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
                                      color: Themes.theme1["SubTextColor"],
                                    )),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(1)),
                              )
                            ]),
                      ),
                    ),
                    Spacer(),
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push<Object>(context,
                            MaterialPageRoute<CoachDashboard>(builder: (BuildContext context) {
                          return CoachDashboard();
                        }));
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Themes.theme1["PrimaryColor"],
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
                                  margin: EdgeInsets.only(top: 20, left: 20),
                                  child: Column(
                                    children: <Widget>[
                                      Icon(
                                        Icons.supervised_user_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Coach",
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
                                          Themes.theme1["FirstGradientColor"],
                                    )),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(1)),
                              )
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
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
                      margin: EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Themes.theme1["PrimaryColor"],
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
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Image.asset("images/dumbbell.png")),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                            ),
                            Container(
                                width: 100,
                                margin: EdgeInsets.only(top: 10, left: 0),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("League Update",
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
                      margin: EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Themes.theme1["PrimaryColor"],
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
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Icon(Icons.settings,size: 40,color: Colors.white,)),
                              borderRadius:
                              BorderRadius.all(Radius.circular(1)),
                            ),
                            Container(
                                width: 100,
                                margin: EdgeInsets.only(top: 10, left: 0),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("League Settings",
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
              SizedBox(height: 20,),
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
                      margin: EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Themes.theme1["PrimaryColor"],
                      ),
                      constraints: BoxConstraints(
                          minHeight: 73,
                          maxHeight: 73,
                          minWidth:
                          MediaQuery.of(context).size.width * 0.5 - 40,
                          maxWidth:
                          MediaQuery.of(context).size.width * 0.5 - 40),
                      child:Container(child:  Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              child: Container(
                                  width: 40,
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Image.asset("images/permission.png")),
                              borderRadius:
                              BorderRadius.all(Radius.circular(1)),
                            ),
                            Container(
                                width: 100,
                                margin: EdgeInsets.only(top: 10, left: 0),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Role Management",
                                        softWrap: true,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white))
                                  ],
                                )),
                          ]),),
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
                      margin: EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Themes.theme1["PrimaryColor"],
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
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Image.asset("images/subleagueSettings.png")),
                              borderRadius:
                              BorderRadius.all(Radius.circular(1)),
                            ),
                            Container(
                                width: 100,
                                margin: EdgeInsets.only(top: 10, left: 0),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Subleague Settings",
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
