import 'dart:io';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RolesEnum.dart';
import 'colors.dart';

class UpdateRole extends StatefulWidget {
  const UpdateRole(this.leagueName, this.user);
  final String leagueName;
  final String user;
  @override
  State<StatefulWidget> createState() {
    return UpdateRoleState();
  }
}

class UpdateRoleState extends State<UpdateRole> {
  bool admin = false;
  bool coach = false;
  bool isLoading = false;
  Role role = Role.unknown;

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
  Future<void> deleteAdmin(String user) async {
    await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .collection('Admins')
        .document(user).delete();
  }

  Future<void> deleteCoach(String user) async {
    await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .collection('Coaches')
        .document(user).delete();
  }

  Future<void> checkRole() async {
    setState(() {
      isLoading = true;
    });
    bool isAdmin = false;
    bool isCoach = false;

    final DocumentSnapshot data = await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .get();
    if (data.data['President'] != null &&
        data.data['President']['id'] == widget.user.replaceAll('.', '-')) {
      role = Role.president;
      isAdmin = true;
      isCoach = true;

      return;
    }
    final QuerySnapshot admins = await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .collection('Admins')
        .getDocuments();
    for (DocumentSnapshot doc in admins.documents) {
      if (doc.documentID ==  widget.user.replaceAll('.', '-')) {
        isAdmin = true;
        break;
      }
    }
    final QuerySnapshot coaches = await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .collection('Coaches')
        .getDocuments();
    for (DocumentSnapshot doc in coaches.documents) {
      if (doc.documentID ==  widget.user.replaceAll('.', '-')) {
        isCoach = true;
        break;
      }
    }
    role = Role.unknown;
    setState(() {
      if (isAdmin) {
        role = Role.admin;
        admin = true;
        coach = false;

      }
      if (isCoach) {
        role = Role.coach;
        admin = false;
        coach = true;
      }

      if (isAdmin && isCoach) {
        role = Role.adminAndCoach;
        admin = true;
        coach = true;
      }

    });

  }

  @override
  void initState() {
    checkRole().whenComplete((){
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.theme1['CardColor'],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Update Roles'),
      ),
      body: ModalProgressHUD(inAsyncCall: isLoading, child: Container(
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
            ),const SizedBox(
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
                                  if (admin && !coach) {
                                    updateAdmin(
                                        widget.user.replaceAll('.', '-'));
                                    deleteCoach(widget.user.replaceAll('.', '-'));
                                  }
                                  if (coach && !admin) {
                                    updateCoach(
                                        widget.user.replaceAll('.', '-'));
                                    deleteAdmin(widget.user.replaceAll('.', '-'));
                                  } else if(coach && admin){
                                    updateCoach(widget.user.replaceAll('.', '-'));
                                    updateAdmin(widget.user.replaceAll('.', '-'));
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
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
                                  if (admin && !coach) {
                                    updateAdmin(
                                        widget.user.replaceAll('.', '-'));
                                    deleteCoach(widget.user.replaceAll('.', '-'));
                                  }
                                  if (coach && !admin) {
                                    updateCoach(
                                        widget.user.replaceAll('.', '-'));
                                    deleteAdmin(widget.user.replaceAll('.', '-'));
                                  } else if(coach && admin){
                                    updateCoach(widget.user.replaceAll('.', '-'));
                                    updateAdmin(widget.user.replaceAll('.', '-'));
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
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

          ],
        ),
      )),
    );
  }
}
