import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'editSubleagueName.dart';
import 'utilities.dart';
import 'addSubleague.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubleagueSettings extends StatefulWidget {
  final String leagueName;
  SubleagueSettings(this.leagueName);

  @override
  State<StatefulWidget> createState() {
    return SubleagueSettingsState();
  }
}

class SubleagueSettingsState extends State<SubleagueSettings> {
  List<dynamic> subleagues = <dynamic>[];
  SlidableController slidableController = SlidableController();

  Future<void> deleteSubleague(String subleagueName) async{
    await Firestore.instance
        .runTransaction((Transaction myTransaction) async {
      await myTransaction.delete(Firestore.instance
          .collection("Leagues")
          .document(widget.leagueName)
          .collection("Subleagues")
          .document(subleagueName));
    });  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('League Settings'),
        backgroundColor: Colors.orange,
      ),
      resizeToAvoidBottomPadding: false,
      backgroundColor: Themes.theme1["CardColor"],
      body: Container(
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Spacer(),
                Text(
                  'Subleague Settings',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
                Spacer()
              ],
            ),
            SizedBox(
              height: 40,
            ),
            ClipRRect(
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                height: MediaQuery.of(context).size.height * 0.7,
                child: StreamBuilder(
                    stream: Firestore.instance
                        .collection("Leagues")
                        .document(widget.leagueName)
                        .collection("Subleagues")
                        .snapshots(),
                    builder: (context, snapshot) {
                      print(snapshot);
                      if (snapshot.connectionState == ConnectionState.done ||
                          snapshot.connectionState == ConnectionState.active) {
                        if (!snapshot.hasData) {
                          return Text(
                            "No Subleagues",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          );
                        } else {
                          if (snapshot.data.documents.length == 0) {
                            this.subleagues = <dynamic>[];
                          } else {
                            QuerySnapshot data = snapshot.data;
                            this.subleagues = data.documents
                                .map((doc) => doc.documentID)
                                .toList();
                          }
                          if (this.subleagues.isEmpty) {
                            return Text("No Subleagues",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center);
                          }
                          return Container(
                            color: Themes.theme1["PrimaryColor"],
                            child: ListView.builder(
                                itemCount: this.subleagues.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: <Widget>[
                                      Container(
                                        child: Slidable(
                                            controller: slidableController,
                                            key: Key("$index"),
                                            child: ListTile(
                                              title: Text(
                                                this.subleagues[
                                                    this.subleagues.length -
                                                        1 -
                                                        index],
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: "Poppins",
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16),
                                              ),
//                                        leading: FadeInFadeOutIcons(Icons.blur_circular, Icons.blur_circular, Duration(milliseconds: 100)),
                                            ),
                                            actionPane:
                                                SlidableDrawerActionPane(),
                                            actions: <Widget>[
                                              IconSlideAction(
                                                color: Themes.theme1[
                                                "TextPlaceholderColor"],
                                                icon: Icons.delete,
                                                onTap: () {
                                                  deleteSubleague(this.subleagues[this.subleagues.length - index - 1]);
                                                },
                                              )
                                            ],
                                            secondaryActions: <Widget>[
                                              IconSlideAction(
                                                color: Themes.theme1[
                                                    "TextPlaceholderColor"],
                                                icon: Icons.edit,
                                                onTap: () {
                                                  Navigator.push<Object>(context,
                                                      MaterialPageRoute(builder:
                                                          (BuildContext
                                                              context) {
                                                    return EditSubleagueName(
                                                        widget.leagueName,
                                                        this.subleagues[this
                                                                .subleagues
                                                                .length -
                                                            index -
                                                            1]);
                                                  }));
//
                                                },
                                              )
                                            ],),
                                        height: 50,
                                      ),
                                      Container(
                                        child: Divider(
                                          color: Colors.white,
                                        ),
                                        margin: EdgeInsets.only(
                                            left: 20, right: 20),
                                      )
                                    ],
                                  );
                                }),
                          );
                        }
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }),
              ),
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ),
            Container(
              height: 50,
              margin: EdgeInsets.only(top: 20, left: 40, right: 40),
              child: RaisedGradientButton(
                  child: Text(
                    'Add Subleague',
                    style: CustomTextStyles.boldLargeText,
                  ),
                  gradient: LinearGradient(colors: [
                    Themes.theme1["FirstGradientColor"],
                    Themes.theme1["SecondGradientColor"]
                  ]),
                  onPressed: () {
                    Navigator.push<Object>(context, MaterialPageRoute(builder: (BuildContext context){
                      return AddSubleague(widget.leagueName);
                    }));

                  }),
            ),
          ],
        ),
      ),
    );
  }
}
