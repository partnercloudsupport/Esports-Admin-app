import 'package:flutter/material.dart';
import 'colors.dart';
import 'utilities.dart';
import 'databaseOperations/Backend.dart';
import 'package:trotter/trotter.dart';
import 'enterStartDate.dart';

class EnterTeamsCount extends StatefulWidget {
  final String leagueName;
  final String leagueID;
  final String subleagueName;
  EnterTeamsCount(this.leagueName,this.leagueID,this.subleagueName);
  @override
  State<StatefulWidget> createState() {
    return EnterTeamsCountState(this.leagueName,this.leagueID,this.subleagueName);
  }
}

class EnterTeamsCountState extends State<EnterTeamsCount> {
  final String leagueName;
  final String leagueID;
  final String subleagueName;
  List<List<String >> combinations = [];
  Map<String,List<List<String>>> teams = {};
  List<String> teamNames = [];
  var controller = TextEditingController(text: "");
  final GlobalKey<FormState> _controllerKey = GlobalKey<FormState>();
  EnterTeamsCountState(this.leagueName,this.leagueID,this.subleagueName);
  int weekCount = 0;
  Map<int,List<List<String>>> weeksSchedule = {};
  @override
  void initState() {
    super.initState();
  }

  Future<void> generatePossibleCombinations(int totalCount) {
    this.weekCount = 0;
    this.teamNames = [];
    for(var i=0;i<totalCount;i++){
      this.teamNames.add("Team $i");
    }
    var combinations = Combinations(2,this.teamNames);
    for (var combo in combinations()) {
      this.combinations.add([combo.first,combo.last]);
    }
    print(this.teams);
    while(this.combinations.length >= 1){
      startCreatingSchedule();
      this.weekCount += 1;
    }
    Navigator.push<Object>(context, MaterialPageRoute(builder: (BuildContext context){
      return EnterStartDate(leagueID, subleagueName,this.weeksSchedule,this.teamNames);
    }));
    print(this.weeksSchedule);
  }


  // Pick first element from dictionary.
  Future<void> startCreatingSchedule() {

    var firstSelection = this.combinations.first;
    this.combinations.removeAt(0);
    List<String> teamsPart = [];
    this.teamNames.forEach((element){
      teamsPart.add(element);
    });
    this.weeksSchedule[this.weekCount] = [firstSelection];
    teamsPart.remove(firstSelection.first);
    teamsPart.remove(firstSelection.last);
    var index = 0;
    List<List<String>> elementsToBeRemoved = [];
    while(index < this.combinations.length){
      var selection = this.combinations[index];
      if(teamsPart.contains(selection.first) && teamsPart.contains(selection.last)){
        print(selection);
        this.weeksSchedule[this.weekCount].add(selection);
        elementsToBeRemoved.add(selection);
        teamsPart.remove(selection.first) && teamsPart.remove(selection.last);
      }
      index += 1;
    }

    for(var each in elementsToBeRemoved){
      this.combinations.removeWhere((element){
        return (element.first == each.first) && (element.last == each.last);
      });
    }


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.theme1["CardColor"],

      body: Container(decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.7,
                0.8
              ],
              colors: [
                Themes.theme1["CardColor"],
                Themes.theme1["PrimaryColor"]
              ])),child: Column(
        children: <Widget>[
          Spacer(),
          Container(margin: EdgeInsets.only(left: 30,right: 30,bottom: 30),child: Text("Please enter number of teams",style: TextStyle(fontSize: 25,fontFamily: 'Poppins',fontStyle: FontStyle.normal,fontWeight: FontWeight.bold,color: Colors.white),),)  ,
          Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            child: Center(
              child: Form(
                  key: _controllerKey,
                  child: TextFormField(
                    controller: controller,
                    validator: (String arg) {
                      if (int.parse(arg) == null){
                        return 'Please enter a valid number';
                      }
                      else {
                        return null;
                      }
                    },
                    style: TextStyle(
                      color: Themes.theme1["TextColor"],
                      fontFamily: "Arial",
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      errorStyle: TextStyle(fontSize: 14),
                      hintText: "Enter teams count",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      filled: true,
                      fillColor: Themes.theme1["TextFieldFillColor"],
                      hintStyle: CustomTextStyles.regularText,
                    ),
                  )),
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
                Themes.theme1["FirstGradientColor"],
                Themes.theme1["SecondGradientColor"]
              ]),
              onPressed: () {
                print(controller.text);
                if(this._controllerKey.currentState.validate()){
                  generatePossibleCombinations(int.parse(controller.text));
                }
              },
            ),
          ),
          Spacer()
        ],
      ),),
    );
  }
}
