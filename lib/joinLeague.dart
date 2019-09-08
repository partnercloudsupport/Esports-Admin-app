import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'colors.dart';
import 'processingPage.dart';
import 'databaseOperations/Backend.dart';

class JoinLeague extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return JoinLeagueState();
  }
}

class JoinLeagueState extends State<JoinLeague> {
  bool isLoading = false;
  TextEditingController nameController = TextEditingController(text: '');

  Color buttonColor() {
    if (nameController.text.length >= 4) {
      return Colors.orange;
    }
    return Colors.orange[200];
  }

  Future<http.Response> sendNotification(String presidentEmail) async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final String email = user.email.replaceAll('.', '-');
    return http.Client().post(
        'https://us-central1-league2-33117.cloudfunctions.net/informPresident?email=$presidentEmail&userEmail=$email');
  }

  Future<void> joinLeague() async {
    bool leagueExist = false;
    if (nameController.text.length >= 4) {
      setState(() {
        isLoading = true;
      });
      QuerySnapshot docs = await Firestore.instance.collection('Leagues').getDocuments();
      for(DocumentSnapshot doc in docs.documents){
        print(doc.data);
        if (doc.data['President']['leagueID'].toString() == nameController.text) {
          print(doc.data);
          leagueExist = true;
          final FirebaseUser user = await FirebaseAuth.instance.currentUser();

          await sendNotification(doc.data['President']['id']);
          await Firestore.instance.collection('Leagues').document(doc.documentID).collection('New Users').document(user.email.replaceAll('.', '-')).setData(<String,dynamic>{});
          break;
        }
      }
      setState(() {
        isLoading = false;
      });
      if (!leagueExist){
        if (Platform.isIOS) {
          showCupertinoDialog<CupertinoAlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('League does not exist'),
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
                  title: const Text('League Does not exist'),
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
        Navigator.push(context, MaterialPageRoute<UnderProcessingPage>(builder: (BuildContext context){
          return UnderProcessingPage();
        }));
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.theme1['CardColor'],
      appBar: AppBar(
        title: const Text('Join a new league'),
        backgroundColor: Colors.orange,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Container(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              const SizedBox(
                height: 60,
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16),
                child: Form(
                  child: Theme(
                    child: TextFormField(
                      controller: nameController,
                      autocorrect: false,
                      onSaved: (String email) {},
                      validator: (String value) {
                        if (value.length >= 4) {
                          return null;
                        }
                        return '';
                      },
                      autovalidate: true,
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyan),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Themes.theme1['SubTextColor']),
                          hintText: 'Please enter league ID'),
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Themes.theme1['TextColor']),
                    ),
                    data: ThemeData(
                        primaryColor: Colors.orange, accentColor: Colors.cyan),
                  ),
                  onChanged: () {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: buttonColor()),
                margin: const EdgeInsets.only(left: 16, right: 16),
                height: 40,
                child: FlatButton(
                    onPressed: () {
                      try {
                        joinLeague();
                      } catch (e) {
                        print(e);

                      }
                    },
                    child: const Text(
                      'Ask for invite?',
                      style: TextStyle(color: Colors.black),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
