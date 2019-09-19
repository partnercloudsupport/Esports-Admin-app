import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utilities.dart';
import 'addSubleague.dart';

class SelectSubleague extends StatefulWidget {
  final String leagueName;
  List<dynamic> subleagues = <String>[''];
  Stream<QuerySnapshot> documents;
  dynamic subleague;

  String coachName = 'Rajesh Budhiraja';
  String teamImage = '';
  String playersCount = '10';

  List<DocumentSnapshot> teams = [];
  SelectSubleague(this.leagueName);
  @override
  State<StatefulWidget> createState() {
    return SelectSubleagueState();
  }
}

class SelectSubleagueState extends State<SelectSubleague> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> teamCards(String subleagueName) async {
    QuerySnapshot documents = await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .collection('Subleagues')
        .document(subleagueName)
        .collection('Teams')
        .getDocuments();
    setState(() {
      widget.teams = documents.documents ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: const Text('League Update'),
          backgroundColor: Colors.orange,
        ),
        backgroundColor: Themes.theme1['CardColor'],
        body: Container(
            child: ListView(
              physics: const  NeverScrollableScrollPhysics(),
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
                      margin: const EdgeInsets.only(left: 20, right: 20),
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
                  widget.subleagues = (snap as AsyncSnapshot<QuerySnapshot>)
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
                                    margin: const EdgeInsets.only(left: 20),
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
                                  margin:
                                      const EdgeInsets.only(top: 10, right: 20),
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
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (dynamic value) {
                                  setState(() {
                                    widget.subleague = value;
                                    teamCards(value);
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
            Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView.builder(
                  itemCount: widget.teams.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                         leading: Container(child: ClipRRect(
                            child: Image.network(
                                widget.teams[index].data['teamPhoto'],fit: BoxFit.fill,),
                            borderRadius: BorderRadius.circular(60),
                          ),width: 60,height: 60,),
                        title: Text(
                          widget.teams[index].documentID,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: 20),
                        ),
                        subtitle: widget.teams[index].data['coach'] == null
                            ? Text(
                                'No Coach',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontSize: 18),
                              )
                            : Text(
                                widget.teams[index].data['coach'],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontSize: 18),
                              ),
                      ),
                    );
                  }),
              margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4), color: Colors.orange),
              margin: const EdgeInsets.fromLTRB(20, 40, 20, 10),
              child: FlatButton(
                child: Text(
                  'Add Subleague',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 14),
                ),
                onPressed: () {
                  Navigator.push<Object>(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return AddSubleague(widget.leagueName);
                  }));
                },
              ),
            )
          ],
        )));
  }
}
