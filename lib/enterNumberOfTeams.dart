import 'package:flutter/material.dart';
import 'package:trotter/trotter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'colors.dart';
import 'databaseOperations/Backend.dart';
import 'enterStartDate.dart';
import 'utilities.dart';

class EnterTeamsCount extends StatefulWidget {
  const EnterTeamsCount(this.leagueName, this.leagueID, this.subleagueName);
  final String leagueName;
  final String leagueID;
  final String subleagueName;
  @override
  State<StatefulWidget> createState() {
    return EnterTeamsCountState(leagueName, leagueID, subleagueName);
  }
}

class EnterTeamsCountState extends State<EnterTeamsCount> {
  EnterTeamsCountState(this.leagueName, this.leagueID, this.subleagueName);

  final String leagueName;
  final String leagueID;
  final String subleagueName;
  bool isLoading = false;
  List<List<String>> combinations = [];
  Map<String, List<List<String>>> teams = {};
  List<String> teamNames = <String>[];
  TextEditingController controller = TextEditingController(text: '');
  final GlobalKey<FormState> _controllerKey = GlobalKey<FormState>();
  int weekCount = 0;
  Map<int, List<List<String>>> weeksSchedule = <int, List<List<String>>>{};

  Future<void> generatePossibleCombinations(int totalCount) {
    weekCount = 0;
    teamNames = <String>[];
    for (int i = 0; i < totalCount; i++) {
      teamNames.add('Team $i');
    }
    final Combinations combinations = Combinations(2, teamNames);
    print(combinations);
    print(totalCount);
    for (var combo in combinations()) {
      this.combinations.add([combo.first, combo.last]);
    }

    while (this.combinations.isNotEmpty) {
      startCreatingSchedule();
      weekCount += 1;
    }
    setState(() {
      isLoading = false;
    });
    Navigator.push<Object>(context,
        MaterialPageRoute<EnterStartDate>(builder: (BuildContext context) {
          return EnterStartDate(leagueID, subleagueName, weeksSchedule, teamNames,leagueName);
        }));
    print(weeksSchedule);
  }

  Color buttonColor() {
    if(controller.text.trim().isNotEmpty && int.parse(controller.text) >= 2){
      return Colors.orange;
    }
    return Colors.orange[200];
  }

  Future<void> nextButtonAction() async {
    if(controller.text.trim().isNotEmpty && int.parse(controller.text) >= 2){
      setState(() {
        isLoading = true;
      });
      await generatePossibleCombinations(int.parse(controller.text));
    }
  }

  // Pick first element from dictionary.
  Future<void> startCreatingSchedule() {
    var firstSelection = this.combinations.first;
    this.combinations.removeAt(0);
    List<String> teamsPart = [];
    teamNames.forEach((element) {
      teamsPart.add(element);
    });
    weeksSchedule[weekCount] = [firstSelection];
    teamsPart.remove(firstSelection.first);
    teamsPart.remove(firstSelection.last);
    var index = 0;
    List<List<String>> elementsToBeRemoved = [];
    while (index < this.combinations.length) {
      var selection = this.combinations[index];
      if (teamsPart.contains(selection.first) &&
          teamsPart.contains(selection.last)) {
        print(selection);
        this.weeksSchedule[weekCount].add(selection);
        elementsToBeRemoved.add(selection);
        teamsPart.remove(selection.first) && teamsPart.remove(selection.last);
      }
      index += 1;
    }

    for (var each in elementsToBeRemoved) {
      this.combinations.removeWhere((element) {
        return (element.first == each.first) && (element.last == each.last);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Enter Number of teams'),
          backgroundColor: Colors.orange),
      backgroundColor: Themes.theme1['CardColor'],
      body: ModalProgressHUD(inAsyncCall: isLoading, child: Container(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 100,),
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: Form(
                child: Theme(
                  child: TextFormField(
                    controller: controller,
                    autocorrect: false,
                    onSaved: (String leagueName) {},
                    validator: (String value) {
                      if (value.length >= 3) {
                        return null;
                      }
                      return '';
                    },
                    autovalidate: true,
                    keyboardType: const TextInputType.numberWithOptions(signed: false,decimal: false),
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
                        hintText: 'Enter Number of teams'),
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
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4), color: buttonColor()),
              margin: const EdgeInsets.only(left: 16, right: 16),
              height: 40,
              child: FlatButton(
                  onPressed: () async {
                    nextButtonAction();
                  },
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
