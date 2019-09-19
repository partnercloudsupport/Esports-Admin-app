import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'colors.dart';

class NewUsersChecks extends StatefulWidget {
  const NewUsersChecks(this.leagueName, this.user);
  final String leagueName;
  final String user;
  @override
  State<StatefulWidget> createState() {
    return NewUsersChecksState();
  }
}

class NewUsersChecksState extends State<NewUsersChecks> {
  bool admin = false;
  bool coach = false;
  bool isLoading = false;

  Future<http.Response> sendNotification(
      String email, String title, String content) async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final String email = user.email.replaceAll('.', '-');
    return http.Client().post(
        'https://us-central1-league2-33117.cloudfunctions.net/genericNotification?email=$email&title=$title&content=$content');
  }

  Future<void> deleteUser(String user) async {
    await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .collection('New Users')
        .document(user)
        .delete();
  }

  Future<void> updateAdmin(String user) async {
    await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .collection('Admins')
        .document(user)
        .setData(<String, dynamic>{});
  }

  Future<void> updateCoach(String user) async {
    await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .collection('Coaches')
        .document(user)
        .setData(<String, dynamic>{});
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Permissions'),
          backgroundColor: Colors.orange,
        ),
        backgroundColor: Themes.theme1['CardColor'],
        body: Container(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              const SizedBox(
                height: 40,
              ),
              ListTile(
                title: Text(
                  'Admin',
                  style: TextStyle(
                      color: Colors.white, fontSize: 20, fontFamily: 'Poppins'),
                ),
                subtitle: Text(
                  'User will get admin permissions',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16, fontFamily: 'Poppins'),
                ),
                trailing: Checkbox(
                    value: admin,
                    onChanged: (bool value) {
                      setState(() {
                        admin = value;
                      });
                    }),
              ),
              const SizedBox(
                height: 40,
              ),
              ListTile(
                title: Text(
                  'Coach',
                  style: TextStyle(
                      color: Colors.white, fontSize: 20, fontFamily: 'Poppins'),
                ),
                subtitle: Text(
                  'User will get coach permissions',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16, fontFamily: 'Poppins'),
                ),
                trailing: Checkbox(
                    value: coach,
                    onChanged: (bool value) {
                      setState(() {
                        coach = value;
                      });
                    }),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.orange),
                margin: const EdgeInsets.only(left: 16, right: 16),
                height: 40,
                child: FlatButton(
                  child: Text(
                    'Update?',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
                  ),
                  onPressed: () {
                    if (Platform.isIOS) {
                      showCupertinoDialog<CupertinoAlertDialog>(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text('Update'),
                              content:
                                  const Text('User will get selected access'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (admin) {
                                      updateAdmin(
                                          widget.user.replaceAll('.', '-'));
                                    }
                                    if (coach) {
                                      updateCoach(
                                          widget.user.replaceAll('.', '-'));
                                    }
                                    if (admin != false || coach != false) {
                                      deleteUser(
                                          widget.user.replaceAll('.', '-'));
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                    sendNotification(
                                        widget.user.replaceAll('.', '-'),
                                        'Request Status updated',
                                        'President has given you access.');
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
                                  isDestructiveAction: true,
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
                              title: const Text('Update'),
                              content:
                                  const Text('User will get selected access'),
                              actions: <Widget>[
                                FlatButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (admin) {
                                      updateAdmin(
                                          widget.user.replaceAll('.', '-'));
                                    }
                                    if (coach) {
                                      updateCoach(
                                          widget.user.replaceAll('.', '-'));
                                    }
                                    if (admin != false || coach != false) {
                                      deleteUser(
                                          widget.user.replaceAll('.', '-'));
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                    sendNotification(
                                        widget.user.replaceAll('.', '-'),
                                        'Request Status updated',
                                        'President has given you access.');
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.orange),
                margin: const EdgeInsets.only(left: 16, right: 16),
                height: 40,
                child: FlatButton(
                  child: Text(
                    'Ignore?',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
                  ),
                  onPressed: () {
                    if (Platform.isIOS) {
                      showCupertinoDialog<CupertinoAlertDialog>(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text('Update'),
                              content:
                                  const Text('User will get selected access'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (admin) {
                                      updateAdmin(
                                          widget.user.replaceAll('.', '-'));
                                    }
                                    if (coach) {
                                      updateCoach(
                                          widget.user.replaceAll('.', '-'));
                                    }
                                    if (admin != false || coach != false) {
                                      deleteUser(
                                          widget.user.replaceAll('.', '-'));
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                    sendNotification(
                                        widget.user.replaceAll('.', '-'),
                                        'Request Status updated',
                                        'President has given you access.');
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
                                  isDestructiveAction: true,
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
                              title: const Text('Update'),
                              content:
                                  const Text('User will get selected access'),
                              actions: <Widget>[
                                FlatButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (admin) {
                                      updateAdmin(
                                          widget.user.replaceAll('.', '-'));
                                    }
                                    if (coach) {
                                      updateCoach(
                                          widget.user.replaceAll('.', '-'));
                                    }
                                    if (admin != false || coach != false) {
                                      deleteUser(
                                          widget.user.replaceAll('.', '-'));
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                    sendNotification(
                                        widget.user.replaceAll('.', '-'),
                                        'Request Status updated',
                                        'President has given you access.');
                                    Navigator.pop(context);
                                  },
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                FlatButton(
                                  child: Text(
                                    'Ignore?',
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 16),
                                  ),
                                  onPressed: () {
                                    if (Platform.isIOS) {
                                      showCupertinoDialog<CupertinoAlertDialog>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CupertinoAlertDialog(
                                              title: const Text(
                                                  'Ignore this request?'),
                                              content: const Text(
                                                  'User will have to request again'),
                                              actions: <Widget>[
                                                CupertinoDialogAction(
                                                  child: const Text('OK'),
                                                  isDefaultAction: true,
                                                  onPressed: () {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    deleteUser(widget.user)
                                                        .whenComplete(() {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      sendNotification(
                                                          widget.user
                                                              .replaceAll(
                                                                  '.', '-'),
                                                          'Request Status updated',
                                                          'President has rejected your request');

                                                      Navigator.pop(context);
                                                    });
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
                                                  'Ignore this request?'),
                                              content: const Text(
                                                  'User will have to request again'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    deleteUser(widget.user)
                                                        .whenComplete(() {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      sendNotification(
                                                          widget.user
                                                              .replaceAll(
                                                                  '.', '-'),
                                                          'Request Status updated',
                                                          'President has rejected your request');
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                    }
                                  },
                                )
                              ],
                            );
                          });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
