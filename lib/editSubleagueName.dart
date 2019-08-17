import 'package:flutter/material.dart';
import 'colors.dart';
import 'utilities.dart';
import 'databaseOperations/Backend.dart';
import 'enterNumberOfTeams.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditSubleagueName extends StatefulWidget {
  final String leagueName;
  final String subleagueName;
  EditSubleagueName(this.leagueName, this.subleagueName);
  @override
  State<StatefulWidget> createState() {
    return EditSubleagueNameState(this.leagueName);
  }
}

class EditSubleagueNameState extends State<EditSubleagueName> {
  var controller = TextEditingController(text: "");
  final GlobalKey<FormState> _controllerKey = GlobalKey<FormState>();
  final String leagueName;
  String leagueID = "";
  EditSubleagueNameState(this.leagueName);

  @override
  void initState() {
    super.initState();
    initializeLeagueID();
  }

  Future<void> initializeLeagueID() async {
    this.leagueID = await Backend.createLeagueID(leagueName);
    setState(() {
      print(this.leagueID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.theme1["CardColor"],
      body: Container(
        decoration: BoxDecoration(
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
            ])),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, bottom: 10),
              child: Text(
                widget.leagueName,
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: 60,
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Center(
                child: Form(
                    key: _controllerKey,
                    child: TextFormField(
                      controller: controller,
                      validator: (String arg) {
                        if (arg.length < 3)
                          return 'League name must be atleast 3 characters long';
                        else
                          return null;
                      },
                      style: TextStyle(
                        color: Themes.theme1["TextColor"],
                        fontFamily: "Arial",
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 14),
                        hintText: widget.subleagueName,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
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
                  'Update Name',
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
                onPressed: () async {
                  var oldData = await Firestore.instance
                      .collection("Leagues")
                      .document(widget.leagueName)
                      .collection("Subleagues")
                      .document(widget.subleagueName)
                      .get();
                  var oldTeam = await Firestore.instance
                      .collection("Leagues")
                      .document(widget.leagueName)
                      .collection("Subleagues")
                      .document(widget.subleagueName)
                      .collection("Teams")
                      .getDocuments();

                  if (controller.text.trim().length > 0) {
                    await Firestore.instance
                        .collection("Leagues")
                        .document(widget.leagueName)
                        .collection("Subleagues")
                        .document(controller.text)
                        .setData(oldData.data);
                    for (var eachTeam in oldTeam.documents) {
                      await Firestore.instance
                          .collection("Leagues")
                          .document(widget.leagueName)
                          .collection("Subleagues")
                          .document(controller.text)
                          .collection("Teams")
                          .document(eachTeam.documentID)
                          .setData(eachTeam.data);
                    }
                    await Firestore.instance
                        .runTransaction((Transaction myTransaction) async {
                      await myTransaction.delete(Firestore.instance
                          .collection('Leagues')
                          .document(widget.leagueName)
                          .collection('Subleagues')
                          .document(widget.subleagueName));
                    });
                    Navigator.pop(context);
                  }

                },
              ),
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}
