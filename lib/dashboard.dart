import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RolesEnum.dart';

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
  List<dynamic> teamNews = <dynamic>[];
  List<String> boardName = <String>['League News', 'Team News'];

  PageController controller = PageController();
  AnimationController animationController;
  String changedNews = '';

  final SlidableController slidableController = SlidableController();
  int currentPage = 0;

  @override
  void initState() {
    updateLeagueName();
    updateRole();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    animationController.repeat(min: 0, max: 0.5);
    super.initState();
  }

  Future<void> updateRole() async {
    final Role role = await checkRole();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Utilities.ROLE_NAME, role.toString());
  }

  Future<Role> checkRole() async {
    return Role.admin;
    bool isAdmin = false;
    bool isCoach = false;
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final DocumentSnapshot data = await Firestore.instance
        .collection('Leagues')
        .document(leagueName)
        .get();
    if (data.data['President']['id'] == user.email.replaceAll('.', '-')) {
      return Role.president;
    }
    final QuerySnapshot admins = await Firestore.instance
        .collection('Leagues')
        .document(leagueName)
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
        .document(leagueName)
        .collection('Coaches')
        .getDocuments();
    for (DocumentSnapshot doc in coaches.documents) {
      if (doc.documentID == user.email.replaceAll('.', '-')) {
        isCoach = true;
        break;
      }
    }
    if (isAdmin && isCoach) {
      return Role.adminAndCoach;
    }
    if (isAdmin) {
      return Role.admin;
    }
    if (isCoach) {
      return Role.coach;
    }
    return Role.unknown;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> updateLeagueName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.get(Utilities.LEAGUE_NAME) == null ||
        prefs.get(Utilities.LEAGUE_NAME) == '') {
      Utilities.logCrash('League name is empty');
    }
    setState(() {
      leagueName = prefs.get(Utilities.LEAGUE_NAME);
    });
  }

  Widget adminHalf(String role) {
    return FlatButton(
      onPressed: () {
        Navigator.push<Object>(context,
            MaterialPageRoute<AdminDashboard>(builder: (BuildContext context) {
          return AdminDashboard(leagueName,role);
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
          return CoachDashboard(leagueName,role);
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

  Future<Widget> returnRoles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String role = prefs.getString(Utilities.ROLE_NAME);
    if (role == Role.adminAndCoach.toString() ||
        role == Role.president.toString()) {
      boardName = <String>['League News', 'Team News'];
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[adminHalf(role), Spacer(), coachHalf(role)],
      );
    } else if (role == Role.admin.toString()) {
      boardName = <String>['League News'];
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          adminHalf(role),
          Spacer(),
        ],
      );
    } else if (role == Role.coach.toString()) {
      boardName = <String>['Team News'];
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          coachHalf(role),
          Spacer(),
        ],
      );
    } else {
      return const Text('You DOnt have access');
    }
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
                  leagueName,
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
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40))),
                    height: 40,
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Center(
                      child: Text(
                        boardName[currentPage],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    )),
                onDismissed: (DismissDirection direction) {
                  setState(() {
                    if (direction == DismissDirection.endToStart &&
                        currentPage == 0) {
                      currentPage = 1;
                      controller.jumpToPage(1);
                    } else if (direction == DismissDirection.startToEnd &&
                        currentPage == 1) {
                      controller.jumpToPage(0);
                      currentPage = 0;
                    }
                  });
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15, top: 5),
              height: MediaQuery.of(context).size.height * 0.4,
              child: Card(
                color: Themes.theme1['NewsBoardColor'],
                child: PageView.builder(
                    controller: controller,
                    onPageChanged: (int index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: boardName.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return Container(
                          child: StreamBuilder(
                            stream: Firestore.instance
                                .collection('Leagues')
                                .document(leagueName)
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
                                    leagueNews = snapshot.data.documents.first
                                            .data['News'] ??
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
                                                          Navigator.push<
                                                                  Object>(
                                                              context,
                                                              MaterialPageRoute<
                                                                      EditLeagueNews>(
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
                  dotsCount: boardName.length,
                  position: currentPage,
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
