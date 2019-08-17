import 'package:flutter/material.dart';
import 'colors.dart';
import 'utilities.dart';
import 'databaseOperations/Backend.dart';
import 'package:trotter/trotter.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_revamp/isUserLoggedIn.dart';
import 'models/ScheduleModel.dart';

class EnterStartDate extends StatefulWidget {
  final String leagueName;
  final String leagueID;
  final String subleagueName;
  final List<String> teamNames;
  final Map<int,List<List<String>>> weeksSchedule;
  EnterStartDate(this.leagueName,this.leagueID,this.subleagueName,this.weeksSchedule,this.teamNames);
  @override
  State<StatefulWidget> createState() {
    return EnterStartDateState(this.leagueName,this.leagueID,this.subleagueName,weeksSchedule,this.teamNames);
  }
}

class EnterStartDateState extends State<EnterStartDate> {
  final String leagueName;
  final String leagueID;
  final String subleagueName;
  final List<String> teamNames;

  bool showLoader = false;
  DateTime datePicked;
  Map<String,List<Map<String,String>>> finalSchedule = {};

  final Map<int,List<List<String>>> weeksSchedule;
  List<List<String >> combinations = [];
  var controller = TextEditingController(text: "");
  final GlobalKey<FormState> _controllerKey = GlobalKey<FormState>();
  EnterStartDateState(this.leagueName,this.leagueID,this.subleagueName,this.weeksSchedule,this.teamNames);
  @override
  void initState() {
    super.initState();
  }

  Future<void> selectDate() async{
    
    if(Platform.isAndroid){
      datePicked = await showDatePicker(context: context, initialDate: DateTime.now().add(Duration(seconds: 5)), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 366)));
      if(datePicked != null){
        setState(() {
          var formatter = new DateFormat('dd-MMM-yyyy');
          controller.text = formatter.format(datePicked).toString();
        });
      }
    }
    else {
      showModalBottomSheet<CupertinoDatePicker>(context: context, builder: (context){
        return CupertinoDatePicker(onDateTimeChanged: (datePicked){
          setState(() {
            this.datePicked = datePicked;
            var formatter = new DateFormat('dd-MMM-yyyy');
            controller.text = formatter.format(datePicked).toString();
          });
        },initialDateTime: DateTime.now(),
          mode: CupertinoDatePickerMode.date,minimumYear: DateTime.now().year,);
      });
    }
  }

 void startCreatingSchedule(){
    setState(() {
      showLoader = true;
    });
    int numberOfWeeks = this.weeksSchedule.keys.toList().length;
    List<String> tempDatesList = [];
    var formatter = new DateFormat('dd-MMM-yyyy');
    String startingDate = formatter.format(this.datePicked);
    tempDatesList.add(startingDate);
    for(var i = 0; i<numberOfWeeks-1 ; i++){
      this.datePicked = this.datePicked.add(Duration(days: 7));
      String nextDateString = formatter.format(datePicked);
      tempDatesList.add(nextDateString);
    }
    print(tempDatesList);

    for (var i=0;i<this.weeksSchedule.keys.toList().length;i++){
      String tempDate = tempDatesList[i];
      List<List<String>> tempValue = this.weeksSchedule.values.toList()[i];
      List<ScheduleModel> scheduleFormat = createScheduleMaps(tempValue);
      List<Map<String,String>> scheduleObjects = scheduleFormat.map((element){
        return {
          'fieldName':element.fieldName,'team1Logo':element.team1Logo,'team2Logo':element.team2Logo,'team2Name':element.team2Name,'team1Name':element.team1Name,'team1Score':element.team1Score,'team2Score':element.team2Score
        };
      }).toList();
      print(scheduleObjects);
      finalSchedule[tempDate] = scheduleObjects;
//      tempSchedule.add({tempDate:scheduleObjects});
    }
  }

  List<ScheduleModel> createScheduleMaps(List<List<String>> weeksDetails){
    List<ScheduleModel> schedule = [];
    for(var eachCombo in weeksDetails){
      ScheduleModel temp = ScheduleModel();
      temp.fieldName = "";
      temp.team1Logo = "";
      temp.team1Name = eachCombo.first;
      temp.team1Score = "";
      temp.team2Logo = "";
      temp.team2Name  = eachCombo.last;
      temp.team2Score = "";
      schedule.add(temp);
    }
    return schedule;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.theme1['CardColor'],

      body: ModalProgressHUD(color:Themes.theme1['CardColor'],inAsyncCall: showLoader, child: Container(decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.7,
                0.8
              ],
              colors: [
                Themes.theme1['CardColor'],
                Themes.theme1['PrimaryColor']
              ])),child: Column(
        children: <Widget>[
          Spacer(),
          Container(margin: EdgeInsets.only(left: 30,right: 30,bottom: 30),child: Text('Please enter start date.  ',style: TextStyle(fontSize: 25,fontFamily: 'Poppins',fontStyle: FontStyle.normal,fontWeight: FontWeight.bold,color: Colors.white),),)  ,
          Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            child: Center(
              child: Form(
                  key: _controllerKey,
                  child: InkWell(
                    onTap: (){
                      this.selectDate();
                    },
                    child: IgnorePointer(child: TextFormField(
                    controller: controller,
                    validator: (value){
                      if(this.datePicked == null){
                        return 'Please choose a date';
                      }
                      else{
                        return null;
                      }
                    },
                    style: TextStyle(
                      color: Themes.theme1['TextColor'],
                      fontFamily: 'Arial',
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      errorStyle: TextStyle(fontSize: 14),
                      hintText: 'DD-MMM-YYYY',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      filled: true,
                      fillColor: Themes.theme1['TextFieldFillColor'],
                      hintStyle: CustomTextStyles.regularText,
                    ),
                  ),),)),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            child: RaisedGradientButton(
              child: Text(
                'Next',
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
                print(controller.text);
                if(this._controllerKey.currentState.validate()){
                  print(this.weeksSchedule);
                  setState(() {
                    startCreatingSchedule();
                    showLoader = false;
                  });
                  FirebaseAuth.instance.currentUser().then((user){
                    if(user == null){
                      Navigator.push<Object>(context, MaterialPageRoute<IsUserLogin>(builder: (BuildContext context){
                        return IsUserLogin(leagueID, subleagueName, leagueName, finalSchedule,this.teamNames);
                      }));
                    }
                    else{
                      print(user);
                    }
                  }
                  );

                }
              },
            ),
          ),
          Spacer()
        ],
      ),)),
    );
  }
}
