import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'colors.dart';
import 'launchPage.dart';


class LeagueInfoPage extends StatefulWidget {
  LeagueInfoPage(this.leagueName);
  final String leagueName;
  @override
  State<StatefulWidget> createState() {
    return LeagueInfoPageState();
  }
}

class LeagueInfoPageState extends State<LeagueInfoPage> {
  bool isLoading = false;
  Future<void> revokeAdminAndCoachAccess() async{
    setState(() {
      isLoading = true;
    });
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection('Leagues').document(widget.leagueName).collection('Admins').document(user.email.replaceAll('.', '-')).delete();
      await Firestore.instance.collection('Leagues').document(widget.leagueName).collection('Coaches').document(user.email.replaceAll('.', '-')).delete();
      await FirebaseAuth.instance.signOut();
      setState(() {
        isLoading = false;
      });
      Navigator.push(context, MaterialPageRoute<LaunchPage>(builder: (BuildContext context){
        return LaunchPage();
      }));
    }
    catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Themes.theme1['CardColor'],
      body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: ListView(
            children: <Widget>[
              const SizedBox(
                height: 100,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: FlatButton(
                    onPressed: () {
                      if (Platform.isIOS) {
                        showCupertinoDialog<CupertinoAlertDialog>(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: const Text('Do you want to leave?'),
                                content: const Text(
                                    'Your access to this would be revoked and you will have to request access again.'),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    child: const Text('Yes'),
                                    isDestructiveAction: true,
                                    onPressed: () {
                                      revokeAdminAndCoachAccess();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text('Cancel'),
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
                                title: const Text('Do you want to leave?'),
                                content: const Text(
                                    'Your access to this would be revoked and you will have to request access again.'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: const Text('Yes'),
                                    onPressed: () {
                                      revokeAdminAndCoachAccess();
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
                    child: Text(
                      'Leave League',
                      style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontStyle: FontStyle.normal),
                    )),
              )
            ],
          )),
    );
  }
}
