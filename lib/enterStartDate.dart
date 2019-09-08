import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'colors.dart';
import 'dashboard.dart';
import 'models/ScheduleModel.dart';

class EnterStartDate extends StatefulWidget {
  const EnterStartDate(
      this.leagueID, this.subleagueName, this.weeksSchedule, this.teamNames,this.leagueName);
  final String leagueName;
  final String leagueID;
  final String subleagueName;
  final List<String> teamNames;
  final Map<int, List<List<String>>> weeksSchedule;
  @override
  State<StatefulWidget> createState() {
    return EnterStartDateState(
        leagueID, subleagueName, weeksSchedule, teamNames,leagueName);
  }
}

class EnterStartDateState extends State<EnterStartDate> {
  EnterStartDateState(
      this.leagueID, this.subleagueName, this.weeksSchedule, this.teamNames,this.leagueName);
  final String leagueID;
  final String leagueName;
  final String subleagueName;
  final List<String> teamNames;
  bool showLoader = false;
  DateTime datePicked;
  Map<String, List<Map<String, String>>> finalSchedule = {};

  final Map<int, List<List<String>>> weeksSchedule;
  List<List<String>> combinations = [];
  var controller = TextEditingController(text: '');
  final GlobalKey<FormState> _controllerKey = GlobalKey<FormState>();

 

  Future<void> selectDate() async {
    if (Platform.isAndroid) {
      datePicked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(Duration(seconds: 5)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 366)));
      if (datePicked != null) {
        setState(() {
          final DateFormat formatter = DateFormat('dd-MMM-yyyy');
          controller.text = formatter.format(datePicked).toString();
        });
      }
    } else {
      showModalBottomSheet<CupertinoDatePicker>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoDatePicker(
              onDateTimeChanged: (datePicked) {
                setState(() {
                  this.datePicked = datePicked;
                  final DateFormat formatter = DateFormat('dd-MMM-yyyy');
                  controller.text = formatter.format(datePicked).toString();
                });
              },
              initialDateTime: DateTime.now(),
              mode: CupertinoDatePickerMode.date,
              minimumYear: DateTime.now().year,
            );
          });
    }
  }

  Color buttonColor() {
    if(controller.text.trim().isNotEmpty && datePicked.isAfter(DateTime.now())){
      return Colors.orange;
    }
    return Colors.orange[200];
  }

  void startCreatingSchedule() {
    setState(() {
      showLoader = true;
    });
    final int numberOfWeeks = weeksSchedule.keys.toList().length;
    List<String> tempDatesList = [];
    var formatter = DateFormat('dd-MMM-yyyy');
    String startingDate = formatter.format(datePicked);
    tempDatesList.add(startingDate);
    for (int i = 0; i < numberOfWeeks - 1; i++) {
      datePicked = datePicked.add(Duration(days: 7));
      final String nextDateString = formatter.format(datePicked);
      tempDatesList.add(nextDateString);
    }
    print(tempDatesList);

    for (var i = 0; i < weeksSchedule.keys.toList().length; i++) {
      String tempDate = tempDatesList[i];
      List<List<String>> tempValue = weeksSchedule.values.toList()[i];
      List<ScheduleModel> scheduleFormat = createScheduleMaps(tempValue);
      List<Map<String, String>> scheduleObjects = scheduleFormat.map((element) {
        return {
          'fieldName': element.fieldName,
          'team1Logo': element.team1Logo,
          'team2Logo': element.team2Logo,
          'team2Name': element.team2Name,
          'team1Name': element.team1Name,
          'team1Score': element.team1Score,
          'team2Score': element.team2Score
        };
      }).toList();
      print(scheduleObjects);
      finalSchedule[tempDate] = scheduleObjects;
    }
  }

  Future<void> startMakingEntryInDatabase(String email) async {
    await Firestore.instance
        .collection('Leagues')
        .document(leagueName)
        .setData(<String, dynamic>{'leagueID': leagueID});

    await Firestore.instance
        .collection('Leagues')
        .document(leagueName)
        .collection('Admins')
        .document(email.replaceAll('.', '-'))
        .setData(<String, dynamic>{});

    // Store schedules.
    for (var each in this.finalSchedule.entries) {
      await Firestore.instance
          .collection('Leagues')
          .document(leagueName)
          .collection('Schedule')
          .document(each.key)
          .setData(<String, dynamic>{'schedule': each.value});
    }
    // Store subleague

    // Store all teams in database
    for (var team in teamNames) {
      await Firestore.instance
          .collection('Leagues')
          .document(leagueName)
          .collection('Subleagues')
          .document(widget.subleagueName)
          .setData(<String, dynamic>{});

      await Firestore.instance
          .collection('Leagues')
          .document(leagueName)
          .collection('Subleagues')
          .document(widget.subleagueName)
          .collection('Teams')
          .document(team)
          .setData(<String, dynamic>{});
    }
  }

  List<ScheduleModel> createScheduleMaps(List<List<String>> weeksDetails) {
    List<ScheduleModel> schedule = [];
    for (var eachCombo in weeksDetails) {
      ScheduleModel temp = ScheduleModel();
      temp.fieldName = '';
      temp.team1Logo = '';
      temp.team1Name = eachCombo.first;
      temp.team1Score = '';
      temp.team2Logo = '';
      temp.team2Name = eachCombo.last;
      temp.team2Score = '';
      schedule.add(temp);
    }
    return schedule;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Enter Start date'),
          backgroundColor: Colors.orange),
      backgroundColor: Themes.theme1['CardColor'],
      body: ModalProgressHUD(
          color: Themes.theme1['CardColor'],
          inAsyncCall: showLoader,
          child: Container(
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 100,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30, right: 30),
                  child: Center(
                    child: Form(
                        key: _controllerKey,
                        child: InkWell(
                          onTap: () {
                            selectDate();
                          },
                          child: IgnorePointer(
                            child: Form(
                              child: Theme(
                                child: TextFormField(
                                  controller: controller,
                                  autocorrect: false,
                                  onSaved: (String leagueName) {},
                                  validator: (String value) {
                                    if (value.isNotEmpty && datePicked.isAfter(DateTime.now())) {
                                      return null;
                                    }
                                    return '';
                                  },
                                  autovalidate: true,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: false, decimal: false),
                                  decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.cyan),
                                      ),
                                      errorBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Themes.theme1['SubTextColor']),
                                      hintText: 'DD-MMM-YYYY'),
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Themes.theme1['TextColor']),
                                ),
                                data: ThemeData(
                                    primaryColor: Colors.orange,
                                    accentColor: Colors.cyan),
                              ),
                              onChanged: () {
                                setState(() {});
                              },
                            ),
                          ),
                        )),
                  ),
                ),
                const SizedBox(height: 40,),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4), color: buttonColor()),
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  height: 40,
                  child: FlatButton(
                      onPressed: () async {
                        print(controller.text);
                        if (_controllerKey.currentState.validate()) {
                          print(weeksSchedule);
                          setState(() {
                            startCreatingSchedule();
                            showLoader = false;
                          });
                          FirebaseAuth.instance.currentUser().then((user) {
                              print(user.email);
                              startMakingEntryInDatabase(user.email);
                              Firestore.instance
                                  .collection('Leagues')
                                  .document(leagueName)
                                  .setData(<String, dynamic>{
                                'President': {
                                  'id': user.email.replaceAll('.', '-'),
                                  'name': 'Anonymous',
                                  'picture': '',
                                  'leagueID':leagueID
                                }
                              });
                              Navigator.of(context).popUntil((route) => route.isFirst);
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute<Dashboard>(
                                      builder: (BuildContext context) {
                                        return Dashboard(
                                            leagueName);
                                      }));
                          });
                        }                      },
                      child: const Text(
                        'Next',
                        style: TextStyle(color: Colors.black),
                      )),
                ),

                Spacer()
              ],
            ),
          )),
    );
  }
}
