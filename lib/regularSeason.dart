import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'colors.dart';

class RegularSeason extends StatefulWidget {
  RegularSeason(this.leagueName);
  final String leagueName;
  List<dynamic> subleagues = <String>[''];
  dynamic subleague;

  @override
  State<StatefulWidget> createState() {
    return RegularSeasonState();
  }
}

class RegularSeasonState extends State<RegularSeason> {

  Future<void> startRegularSeason() async{
    if (Platform.isIOS) {
      showCupertinoDialog<CupertinoAlertDialog>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Once season started you wont be able to add more teams'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: const Text('OK'),
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
              title: const Text('Once season started you wont be able to add more teams'),
              actions: <Widget>[
                FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
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

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: Text(
            'Regular Season',
            style: TextStyle(
                color: Colors.black, fontFamily: 'Poppins', fontSize: 12),
          ),
        ),
        backgroundColor: Themes.theme1['CardColor'],
        body: ModalProgressHUD(
            inAsyncCall: isLoading,
            child: Container(
              child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 40,
                      child: Text(
                        'Select a subleague',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      margin: const EdgeInsets.only(left: 20),
                    ),
                    StreamBuilder(
                      stream: Firestore.instance
                          .collection('Leagues')
                          .document(this.widget.leagueName)
                          .collection('Subleagues')
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot snap) {
                        if (snap.connectionState == ConnectionState.done ||
                            snap.connectionState == ConnectionState.active) {
                          if (!snap.hasData) {
                            return Container(
                              height: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(colors: [
                                    Themes.theme1['FirstGradientColor'],
                                    Themes.theme1['SecondGradientColor']
                                  ])),
                              margin:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Container(
                                child: Text(
                                  'No Subleagues',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white),
                                ),
                                margin: EdgeInsets.only(top: 20, left: 10),
                              ),
                            );
                          }
                          widget.subleagues =
                              (snap as AsyncSnapshot<QuerySnapshot>)
                                  .data
                                  .documents
                                  .map((e) => e.documentID)
                                  .toList();
                          return Container(
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                    colors: [Colors.orange, Colors.yellow])),
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            child: Theme(
                                data: ThemeData.dark(),
                                child: DropdownButtonHideUnderline(
                                    child: DropdownButton<dynamic>(
                                        hint: Container(
                                            margin:
                                                const EdgeInsets.only(left: 20),
                                            child: Text(
                                              'Please select a subleague',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            )),
                                        isExpanded: true,
                                        icon: Container(
                                          child: Icon(
                                            Icons.keyboard_arrow_down,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                          margin: const EdgeInsets.only(
                                              top: 10, right: 20),
                                        ),
                                        value: widget.subleague,
                                        items: widget.subleagues
                                            .map((dynamic e) =>
                                                DropdownMenuItem<dynamic>(
                                                  value: e,
                                                  child: Container(
                                                    child: Text(
                                                      e,
                                                      style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            widget.subleague = value;
                                          });
                                        }))),
                          );
                        } else {
                          return Center(
                            child: const CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ]),
            )));
  }
}
