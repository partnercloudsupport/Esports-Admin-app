
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'addLeagueNews.dart';
import 'addTeamNews.dart';
import 'adminDashboard.dart';
import 'coachDashboard.dart';
import 'colors.dart';
import 'editLeagueNews.dart';
import 'utilities.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DashboardState();
  }
}

class DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  String leagueName = ' ';
  List<dynamic> leagueNews = <dynamic>[];
  List<dynamic> teamNews =  <dynamic>[];
  List<String> boardName = <String>['League News', 'Team News'];

  PageController controller = PageController();
  AnimationController animationController;
  String changedNews = '';

  final SlidableController slidableController = SlidableController();
  var currentPage = 0;

  @override
  void initState() {
    updateLeagueName();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    animationController.repeat(min: 0, max: 0.5);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> updateLeagueName() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.get(Utilities.LEAGUE_NAME) == null || prefs.get(Utilities.LEAGUE_NAME) == ''){
      Utilities.logCrash('League name is empty');
    }
    setState(() {
      leagueName = prefs.get(Utilities.LEAGUE_NAME);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.theme1['CardColor'],
      body: Container(
        color: Themes.theme1['CardColor'],
        child: ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                Spacer(),
                FlatButton(
                  child: Container(
                    child: Image.asset('images/logout.png'),
                    height: 30,
                    width: 30,
                  ),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    GoogleSignIn().signOut();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Spacer(),
                Text(
                  'My Dashboard',
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
                    onPressed: () {
                      Navigator.push<Object>(context,
                          MaterialPageRoute<AdminDashboard>(builder: (BuildContext context) {
                        return AdminDashboard(leagueName);
                      }));
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Themes.theme1['PrimaryColor'],
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                            )
                          ]),
                    ),
                  ),
                  Spacer(),
                  FlatButton(
                    onPressed: () {
                      Navigator.push<Object>(context,
                          MaterialPageRoute<CoachDashboard>(builder: (BuildContext context) {
                        return CoachDashboard();
                      }));
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Themes.theme1['PrimaryColor'],
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
                  this.leagueName,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
                Spacer()
              ],
            ),
            Container(
              height: 40,
              child: Dismissible(
                key: Key(DateTime.now().toString()),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40))),
                    height: 40,
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Center(
                      child: Text(
                        this.boardName[this.currentPage],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    )),
                onDismissed: (direction) {
                  setState(() {
                    if (direction == DismissDirection.endToStart &&
                        this.currentPage == 0) {
                      this.currentPage = 1;
                      controller.jumpToPage(1);
                    } else if (direction == DismissDirection.startToEnd &&
                        this.currentPage == 1) {
                      controller.jumpToPage(0);
                      this.currentPage = 0;
                    }
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 15, right: 15, top: 5),
              height: MediaQuery.of(context).size.height * 0.4,
              child: Card(
                color: Themes.theme1['NewsBoardColor'],
                child: PageView.builder(
                    controller: controller,
                    onPageChanged: (index) {
                      setState(() {
                        this.currentPage = index;
                      });
                    },
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: 2,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return Container(
                          child: StreamBuilder(
                            stream: Firestore.instance
                                .collection('Leagues')
                                .document(this.leagueName)
                                .collection('League News')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done ||
                                  snapshot.connectionState ==
                                      ConnectionState.active) {
                                if (!snapshot.hasData) {
                                  return Text(
                                    'No News',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  );
                                } else {
                                  if (snapshot.data.documents.length == 0) {
                                    leagueNews = <dynamic>[];
                                  } else {
                                    leagueNews = snapshot.data.documents
                                            .first.data['News'] ??
                                        <dynamic>[];
                                  }
                                  if (this.leagueNews.isEmpty) {
                                    return Text('No News',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center);
                                  }
                                  return Container(
                                    color: Themes.theme1['PrimaryColor'],
                                    child: ListView.builder(
                                        itemCount: this.leagueNews.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Column(
                                            children: <Widget>[
                                              Container(
                                                child: Slidable(
                                                    controller:
                                                        slidableController,
                                                    key: Key('$index'),
                                                    child: ListTile(
                                                      title: Text(
                                                        this.leagueNews[this
                                                                .leagueNews
                                                                .length -
                                                            1 -
                                                            index],
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 16),
                                                      ),
//                                        leading: FadeInFadeOutIcons(Icons.blur_circular, Icons.blur_circular, Duration(milliseconds: 100)),
                                                    ),
                                                    actionPane:
                                                        SlidableDrawerActionPane(),
                                                    secondaryActions: <Widget>[
                                                      IconSlideAction(
                                                        color: Themes.theme1[
                                                            'TextPlaceholderColor'],
                                                        icon: Icons.edit,
                                                        onTap: () {
                                                          this.changedNews =
                                                              this.leagueNews[
                                                                  index];
                                                          Navigator.push<Object>(
                                                              context,
                                                              MaterialPageRoute<EditLeagueNews>(
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                            return EditLeagueNews(
                                                                leagueName,
                                                                this.leagueNews,
                                                                this.changedNews,
                                                                index);
                                                          }));
                                                        },
                                                      )
                                                    ]),
                                              ),
                                              Container(
                                                child: Divider(
                                                  color: Colors.white,
                                                ),
                                                margin: EdgeInsets.only(
                                                    left: 20, right: 20),
                                              )
                                            ],
                                          );
                                        }),
                                  );
                                }
                              }
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        );
                      } else {
                        return Container(
                          color: Themes.theme1['PrimaryColor'],
                          child: ListView.builder(
                              itemCount: this.teamNews.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: <Widget>[
                                    Container(
                                      child: Slidable(
                                          controller: slidableController,
                                          key: Key('$index'),
                                          child: ListTile(
                                            title: Text(
                                              this.teamNews[index],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16),
                                            ),
//                                        leading: FadeInFadeOutIcons(Icons.blur_circular, Icons.blur_circular, Duration(milliseconds: 100)),
                                          ),
                                          actionPane:
                                              SlidableDrawerActionPane(),
                                          secondaryActions: <Widget>[
                                            IconSlideAction(
                                              color: Colors.black,
                                              icon: Icons.add,
                                              onTap: () {},
                                            )
                                          ]),
                                    ),
                                    Container(
                                      child: Divider(
                                        color: Colors.white,
                                      ),
                                      margin:
                                          EdgeInsets.only(left: 20, right: 20),
                                    )
                                  ],
                                );
                              }),
                        );
                      }
                    }),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DotsIndicator(
                  decorator: DotsDecorator(
                    size: const Size.square(9.0),
                    activeSize: const Size(18.0, 9.0),
                    activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  dotsCount: 2,
                  position: this.currentPage,
                )
              ],
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Utilities.cornerRadius)),
              margin: EdgeInsets.only(left: 40, right: 40, top: 20),
              child: RaisedGradientButton(
                child: Text(
                  'Add News',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                gradient: LinearGradient(colors: [
                  Themes.theme1['FirstGradientColor'],
                  Themes.theme1['SecondGradientColor']
                ]),
                onPressed: () {
                  if ('League News' == this.boardName[this.currentPage]) {
                    Navigator.push(
                        context,
                        MaterialPageRoute<AddLeagueNews>(
                            builder: (BuildContext context) => AddLeagueNews(
                                this.leagueName, this.leagueNews)));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute<AddTeamNews>(
                            builder: (BuildContext context) =>
                                AddTeamNews(this.leagueName, this.teamNews)));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
