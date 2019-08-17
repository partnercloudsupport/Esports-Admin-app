import 'package:flutter/material.dart';
import 'colors.dart';
import 'adminDashboard.dart';
class CoachDashboard extends StatefulWidget {
  String leagueName = "";
  @override
  State<StatefulWidget> createState() {
    return CoachDashboardState();
  }
}

class CoachDashboardState extends State<CoachDashboard> {
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
              SizedBox(
                height: 10,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    FlatButton(
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.push<Object>(context, MaterialPageRoute<AdminDashboard>(builder: (BuildContext context){
                          return AdminDashboard(widget.leagueName);
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
                                      color:
                                      Themes.theme1["FirstGradientColor"],
                                    )),
                                borderRadius:
                                BorderRadius.all(Radius.circular(1)),
                              )
                            ]),
                      ),
                    ),
                    Spacer(),
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
                                      Themes.theme1["SubTextColor"],
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
            ])));
  }
}
