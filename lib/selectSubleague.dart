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
        .document(this.widget.leagueName)
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
                        gradient: LinearGradient(colors: [
                          Colors.orange,
                          Colors.yellow
                        ])),
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
                                  margin: const EdgeInsets.only(top: 10, right: 20),
                                ),
                                value: widget.subleague,
                                items: widget.subleagues
                                    .map((dynamic e) => DropdownMenuItem<dynamic>(
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
                                            margin: const EdgeInsets.only(left: 10),
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
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height*0.5),
              child: ListView.builder(
                  itemCount: widget.teams.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      height: 170,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          gradient: LinearGradient(
                              colors: [Colors.blue, Colors.deepPurple]),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: <Widget>[
                          Container(
                              width: 100,
                              margin: const EdgeInsets.only(top: 20, left: 10),
                              child: ClipRRect(
                                child: Container(child: FadeInImage.assetNetwork(
                                    placeholder: 'images/coach.png',
                                    image: widget.teams[index]
                                        .data['teamImage'] ??
                                        ''),color: Colors.deepPurple,),
                                borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                              )),
                          Container(
                              child:
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: 200,
                                    child: Text(
                                      widget.teams[index].documentID,
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10))),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: 200,
                                    child:
                                    Text(
                                        widget.teams[index].data['coachName'] ??
                                            'Coach',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white)),),
                                  Row(
                                    children: <Widget>[
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        width: 200,
                                        child:
                                        Text(
                                            'Players - ' +
                                                (widget.teams[index]
                                                    .data['playersCount'] ?? '0'),
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.white)),),
                                      const SizedBox(
                                        width: 20,
                                      ),

                                    ],
                                  ),
                                  Row(children: <Widget>[
                                    FlatButton(
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.white),
                                            borderRadius:
                                            const BorderRadius.all(Radius.circular(4))),
                                        child:
                                        Container(
                                          width: 90,
                                          child:
                                          Text(' See details ',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.white)),),
                                      ),
                                    )],)
                                ],
                              )),

                        ],
                      ),
                    );
                  }),
              margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
            ),
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),color: Colors.orange)
              ,margin: const EdgeInsets.fromLTRB(20, 40, 20, 10),
              child: 
            FlatButton(
              child: Text(
                'Add Subleague',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 14),
              ),
              onPressed: () {
              Navigator.push<Object>(context, MaterialPageRoute(builder: (BuildContext context){
                return AddSubleague(widget.leagueName);
              }));
              },
            ),)
          ],
        )));
  }
}
