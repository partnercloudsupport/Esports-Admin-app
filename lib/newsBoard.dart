import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'addLeagueNews.dart';
import 'addTeamNews.dart';
import 'colors.dart';
import 'editLeagueNews.dart';
import 'utilities.dart';

class NewsBoard extends StatefulWidget {
  const NewsBoard(this.leagueName);
  final String leagueName;
  @override
  State<StatefulWidget> createState() {
    return NewsBoardState();
  }
}

class NewsBoardState extends State<NewsBoard> {
  List<String> boardName = <String>['League News', 'Team News'];
  bool isLoading = false;
  int currentPage = 0;
  PageController controller = PageController();
  List<dynamic> leagueNews = <dynamic>[];
  List<dynamic> teamNews = <dynamic>[];
  final SlidableController slidableController = SlidableController();
  String changedNews = '';
  Map<String, dynamic> leagueData = <String, dynamic>{};
  String leagueID = '';
  String leagueImage =
      'https://firebasestorage.googleapis.com/v0/b/league2-33117.appspot.com/o/logo.png?alt=media&token=8a8b3791-7676-485a-a800-959d4a1b0325';

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    getLayoutData().whenComplete(() {
      if(mounted){
        setState(() {
          isLoading = false;
        });
      }
    });
    super.initState();
  }

  Future<void> getLayoutData() async {
    final DocumentSnapshot data = await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .get();
    leagueData = data.data;
    if (leagueData['leaguePhoto'].toString().trim().isNotEmpty) {
      leagueImage = leagueData['leaguePhoto'].toString().trim();
    }

    if (leagueData['President']['leagueID'].toString().trim().isNotEmpty) {
      leagueID = leagueData['President']['leagueID'].toString().trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Themes.theme1['CardColor'],
      child: ListView(
        children: <Widget>[
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
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Colors.white),
              ),
              Spacer()
            ],
          ),
          Center(child:
          Container(
              width: 60,
              height: 60,
              child: ClipRRect(
                child: Container(
                  child: Image.network(leagueImage,fit: BoxFit.fill,),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(60)),
              )),),
          Row(
            children: <Widget>[
              Spacer(),
              Text(
                leagueID,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Colors.white),
              ),
              Spacer()
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 40,
            child: Dismissible(
              key: Key(DateTime.now().toString()),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8))),
                  height: 40,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Center(
                    child: Text(
                      boardName[currentPage],
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.normal),
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
              color: Themes.theme1['PrimaryColor'],
              child: PageView.builder(
                  controller: controller,
                  onPageChanged: (int index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: boardName.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Container(
                        child: StreamBuilder(
                          stream: Firestore.instance
                              .collection('Leagues')
                              .document(widget.leagueName)
                              .collection('League News')
                              .snapshots(),
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done ||
                                snapshot.connectionState ==
                                    ConnectionState.active) {
                              if (!snapshot.hasData) {
                                return Column(
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      child: Image.asset('images/news.png'),
                                      height: 150,
                                      width: 150,
                                    ),
                                    Text(
                                      'No News',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                );
                              } else {
                                if (snapshot.data.documents.length == 0) {
                                  leagueNews = <dynamic>[];
                                } else {
                                  leagueNews = snapshot
                                          .data.documents.first.data['News'] ??
                                      <dynamic>[];
                                }
                                if (leagueNews.isEmpty) {
                                  return Column(
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        child: Image.asset('images/news.png'),
                                        height: 150,
                                        width: 150,
                                      ),
                                      Text(
                                        'No News',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      )
                                    ],
                                  );
                                }
                                return Container(
                                  color: Themes.theme1['PrimaryColor'],
                                  child: ListView.builder(
                                      itemCount: leagueNews.length,
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
                                                      leagueNews[
                                                          leagueNews.length -
                                                              1 -
                                                              index],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 16),
                                                    ),
//                                        leading: FadeInFadeOutIcons(Icons.blur_circular, Icons.blur_circular, Duration(milliseconds: 100)),
                                                  ),
                                                  actionPane:
                                                      const SlidableDrawerActionPane(),
                                                  secondaryActions: <Widget>[
                                                    IconSlideAction(
                                                      color: Themes.theme1[
                                                          'TextPlaceholderColor'],
                                                      icon: Icons.edit,
                                                      onTap: () {
                                                        changedNews =
                                                            leagueNews[index];
                                                        Navigator.push<Object>(
                                                            context,
                                                            MaterialPageRoute<
                                                                    EditLeagueNews>(
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                          return EditLeagueNews(
                                                              widget.leagueName,
                                                              leagueNews,
                                                              changedNews,
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
                                              margin: const EdgeInsets.only(
                                                  left: 20, right: 20),
                                            )
                                          ],
                                        );
                                      }),
                                );
                              }
                            }
                            return Center(
                              child: const CircularProgressIndicator(),
                            );
                          },
                        ),
                      );
                    } else {
                      return Container(
                        color: Themes.theme1['PrimaryColor'],
                        child: ListView.builder(
                            itemCount: teamNews.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: <Widget>[
                                  Container(
                                    child: Slidable(
                                        controller: slidableController,
                                        key: Key('$index'),
                                        child: ListTile(
                                          title: Text(
                                            teamNews[index],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16),
                                          ),
//                                        leading: FadeInFadeOutIcons(Icons.blur_circular, Icons.blur_circular, Duration(milliseconds: 100)),
                                        ),
                                        actionPane:
                                            const SlidableDrawerActionPane(),
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
                                    margin: const EdgeInsets.only(
                                        left: 20, right: 20),
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
                borderRadius: BorderRadius.circular(8), color: Colors.orange),
            margin: const EdgeInsets.only(left: 40, right: 40, top: 20),
            child: FlatButton(
              child: Text(
                'Add News',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              onPressed: () {
                if ('League News' == boardName[currentPage]) {
                  Navigator.push(
                      context,
                      MaterialPageRoute<AddLeagueNews>(
                          builder: (BuildContext context) =>
                              AddLeagueNews(widget.leagueName, leagueNews)));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute<AddTeamNews>(
                          builder: (BuildContext context) =>
                              AddTeamNews(widget.leagueName, teamNews)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
