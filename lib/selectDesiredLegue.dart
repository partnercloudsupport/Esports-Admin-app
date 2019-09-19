import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'colors.dart';
import 'dashboard.dart';
import 'enterLeagueName.dart';
import 'launchPage.dart';
import 'models/FetchLeague.dart';
import 'subscriptionPage.dart';
import 'joinLeague.dart';

class SelectDesiredLeague extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SelectDesiredLeagueState();
  }
}

class SelectDesiredLeagueState extends State<SelectDesiredLeague> {
  List<Map<String, String>> leaguesOfWhichUserisPart = [];
  bool noData = false;
  bool loading = false;

  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;

  Future<void> _saveDeviceToken() async {
    // Get the current user
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String uid = user.email.replaceAll('.', '-');

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      await Firestore.instance
          .collection('Users')
          .document(uid)
          .updateData(<String, dynamic>{
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem // optional
      });
    }
  }

  Future<http.Response> fetchLeaguesData() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();

    final String email = user.email.replaceAll('.', '-');
    print(email);
    return http.Client().get(
        'https://us-central1-league2-33117.cloudfunctions.net/readAllLeagues?email=$email');
  }

  String leagueHeader() {
    if (noData) {
      return 'Please add a league';
    } else {
      return 'Please select a league';
    }
  }

  @override
  void initState() {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(const IosNotificationSettings());
    }
    _saveDeviceToken();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        if (Platform.isIOS) {
          showCupertinoDialog<CupertinoAlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: Text(message['aps']['alert']['title']),
                  content: Text(message['aps']['alert']['body']),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text('OK'),
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
                  title: Text(message['notification']['title']),
                  content: Text(message['notification']['body']),
                  actions: <Widget>[
                    FlatButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
      },
    );
    super.initState();
  }

  String roleString(bool admin, bool coach) {
    if (admin && coach) {
      return 'Admin & Coach';
    } else if (admin) {
      return 'Admin';
    } else if (coach) {
      return 'Coach';
    }
    return '';
  }

  Widget leadingWidget(bool president) {
    if (president) {
      return Container(
        child: Image.asset('images/crown.png'),
      );
    }
    return const Text('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Themes.theme1['CardColor'],
        body: ModalProgressHUD(
            inAsyncCall: loading,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                const SizedBox(
                  height: 40,
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Align(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white)),
                      child: FlatButton(
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                            if (await InAppPurchaseConnection.instance
                                .isAvailable()) {
                              final Set<String> _productIDs =
                                  <String>['1eleague_54.'].toSet();
                              QueryPurchaseDetailsResponse previousResponse =
                                  await InAppPurchaseConnection.instance
                                      .queryPastPurchases();
                              if (previousResponse.pastPurchases.length >= 1 &&
                                  previousResponse.pastPurchases.first.status ==
                                      PurchaseStatus.purchased) {
                                setState(() {
                                  loading = false;
                                });
                                Navigator.push(context,
                                    MaterialPageRoute<EnterLeagueName>(
                                        builder: (BuildContext context) {
                                  return EnterLeagueName();
                                }));
                              } else {
                                final ProductDetailsResponse response =
                                    await InAppPurchaseConnection.instance
                                        .queryProductDetails(_productIDs);
                                if (response.notFoundIDs.isNotEmpty) {
                                  setState(() {
                                    loading = false;
                                  });
                                  if (Platform.isIOS) {
                                    showCupertinoDialog<CupertinoAlertDialog>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CupertinoAlertDialog(
                                            title: const Text(
                                                'Some error occurred'),
                                            content: const Text(
                                                'Product is not available'),
                                            actions: <Widget>[
                                              CupertinoDialogAction(
                                                child: const Text('OK'),
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
                                            title: const Text(
                                                'Some error occurred'),
                                            content: const Text(
                                                'Product is not available'),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: const Text('OK'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  }
                                } else {
                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.push(context,
                                      MaterialPageRoute<SubscriptionPage>(
                                          builder: (BuildContext context) {
                                    return SubscriptionPage(
                                        response.productDetails);
                                  }));
                                }
                              }
                            } else {
                              if (Platform.isIOS) {
                                showCupertinoDialog<CupertinoAlertDialog>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title:
                                            const Text('Some error occurred'),
                                        content:
                                            const Text('Store is unavailable.'),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: const Text('OK'),
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
                                        title:
                                            const Text('Some error occurred'),
                                        content:
                                            const Text('Store is unvailable'),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      );
                                    });
                              }
                            }
                          },
                          child: Text(
                            'Create your own league',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Themes.theme1['TextColor'],
                                fontSize: 16),
                          )),
                      width: 200,
                    ),
                    alignment: Alignment.topRight,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  child: Text(
                    leagueHeader(),
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 16),
                  ),
                  margin: const EdgeInsets.only(left: 16),
                ),
                FutureBuilder<http.Response>(
                  future: fetchLeaguesData(),
                  builder: (BuildContext context,
                      AsyncSnapshot<http.Response> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done ||
                        snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.data == null) {
                        return CupertinoAlertDialog(
                          title: const Text('Some error occurred'),
                          content: const Text(
                              'Data fetching failed. Please try again.'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              isDefaultAction: true,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        );
                      }
                      if (snapshot.data.statusCode != 200) {
                        if (Platform.isIOS) {
                          showCupertinoDialog<CupertinoAlertDialog>(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title: const Text('Some error occurred'),
                                  content: const Text(
                                      'Data fetching failed. Please try again.'),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      child: const Text('OK'),
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
                                  title: const Text('Some error occurred'),
                                  content: const Text(
                                      'Data fetching failed. Please try again.'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              });
                        }
                      } else if (snapshot.data.body != '[]') {
                        final FetchLeagues leagues =
                            FetchLeagues.fromJson(snapshot.data.body);
                        return Container(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.9,
                              minHeight: 200),
                          child: ListView.builder(
                            itemCount: leagues.leagues.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              String roles = roleString(
                                  leagues.leagues[index].admin.toString() ==
                                      'true',
                                  leagues.leagues[index].coach.toString() ==
                                      'true');
                              return FlatButton(
                                child: ListTile(
                                  trailing: leadingWidget(leagues
                                          .leagues[index].president
                                          .toString() ==
                                      'true'),
                                  leading: ClipRRect(
                                    child: Container(
                                      height: 50,width: 50,
                                      child: FadeInImage.assetNetwork(fit: BoxFit.fill,
                                          placeholder: 'images/logo.png',
                                          image: leagues
                                                  .leagues[index].leaguePhoto ??
                                              'https://firebasestorage.googleapis.com/v0/b/league2-33117.appspot.com/o/logo.png?alt=media&token=8a8b3791-7676-485a-a800-959d4a1b0325'),
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  subtitle: Container(
                                    child: Text(
                                      roles,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins'),
                                    ),
                                  ),
                                  title: Text(leagues.leagues[index].leagueName,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins')),
                                ),
                                onPressed: () {
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute<Dashboard>(
                                          builder: (BuildContext context) {
                                    return Dashboard(
                                        leagues.leagues[index].leagueName);
                                  }));
                                },
                              );
                            },
                          ),
                        );
                      }
                      return Column(
                        children: <Widget>[
                          Container(
                            child: Image.asset('images/emptyBox.png'),
                          ),
                          Text(
                            'No Leagues',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 18),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: const CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                FlatButton(
                  child: Text(
                    'Join a league?',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 20),
                  ),onPressed: (){
                  Navigator.push(context, MaterialPageRoute<JoinLeague>(builder: (BuildContext context){
                    return JoinLeague();
                  }));
                },
                ),
                FlatButton(
                  child: Text(
                    'Log out?',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 20),
                  ),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(context, MaterialPageRoute<LaunchPage>(builder: (BuildContext context){
                      return LaunchPage();
                    })
                    );
                  },
                )              ],
            )));
  }
}
