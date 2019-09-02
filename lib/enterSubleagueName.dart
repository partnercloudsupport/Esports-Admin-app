import 'package:flutter/material.dart';
import 'colors.dart';
import 'databaseOperations/Backend.dart';
import 'enterNumberOfTeams.dart';
import 'utilities.dart';

class EnterSubleagueName extends StatefulWidget {
  const EnterSubleagueName(this.leagueName);
  final String leagueName;
  @override
  State<StatefulWidget> createState() {
    return EnterSubleagueNameState(leagueName);
  }
}

class EnterSubleagueNameState extends State<EnterSubleagueName> {
  EnterSubleagueNameState(this.leagueName);
  TextEditingController controller = TextEditingController(text: '');
  final String leagueName;
  String leagueID = '';

  void nextButtonAction() {
    if (controller.text.length >= 3) {
      Navigator.push(context,
          MaterialPageRoute<EnterTeamsCount>(builder: (BuildContext context) {
        return EnterTeamsCount(leagueName, leagueID, controller.text);
      }));
    }
  }

  @override
  void initState() {
    super.initState();
    initializeLeagueID();
  }

  Color buttonColor() {
    if (controller.text.length >= 3) {
      return Colors.orange;
    }
    return Colors.orange[200];
  }

  Future<void> initializeLeagueID() async {
    leagueID = await Backend.createLeagueID(leagueName);
    setState(() {
      print(leagueID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Enter Subleague name'),
          backgroundColor: Colors.orange),
      backgroundColor: Themes.theme1['CardColor'],
      body: Container(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 100,
            ),
            Container(
              margin: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
              child: Text(
                'League ID:  $leagueID',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.white),
              ),
            ),
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
                        hintText: 'Enter Subleague name'),
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
              height: 40,
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
      ),
    );
  }
}
