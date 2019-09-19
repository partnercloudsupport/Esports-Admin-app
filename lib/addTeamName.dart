import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'colors.dart';
import 'package:flutter/cupertino.dart';
import 'utilities.dart';

class TeamName extends StatefulWidget {
  TeamName(this.leagueName,this.callback,this.selectedSubleague);
  Function callback;
  final String leagueName;
  final dynamic selectedSubleague;

  @override
  State<StatefulWidget> createState() {
    return TeamNameState();
  }
}

class TeamNameState extends State<TeamName> {
  GlobalKey formKey = GlobalKey<FormState>();
  TextEditingController teamNameController = TextEditingController(text: '');

  bool isLoading = false;

  Color buttonColor() {
    if (teamNameController.text.length >= 4){
      return Colors.orange;
    }
    return Colors.orange[200];
  }

  Future<void> addTeamAction() async{

    if (teamNameController.text.length >= 4){
      setState(() {
        isLoading = true;
      });
      QuerySnapshot teams = await Firestore.instance.collection('Leagues').document(widget.leagueName).collection('Subleagues').document(widget.selectedSubleague).collection('Teams').getDocuments();
      bool teamExists = false;
      for(DocumentSnapshot doc in teams.documents){
        if(doc.documentID == teamNameController.text){
          teamExists = true;
          break;
        }
      }
      if(teamExists){
        if (Platform.isIOS) {
          showCupertinoDialog<CupertinoAlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('Name is already taken'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      isDefaultAction: true,
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
                  title: const Text('Name is already taken'),
                  actions: <Widget>[
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
        setState(() {
          isLoading = false;
        });
      } else {
        widget.callback(teamNameController.text,widget.selectedSubleague);

        Navigator.pop(context);
      }


    }
    else {

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a name'),
        backgroundColor: Colors.orange,
      ),
      resizeToAvoidBottomPadding: false,
      backgroundColor: Themes.theme1['CardColor'],
      body: ModalProgressHUD(inAsyncCall: isLoading, child: Column(
        children: <Widget>[
          Container(
            child: Container(
                height: 400,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                child: Form(
                  onChanged: (){
                    setState(() {

                    });
                  },
                  key: formKey,
                  child: ListView(
                    children: <Widget>[
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 16, right: 16),
                        child: Theme(
                          child: TextFormField(
                            controller: teamNameController,
                            autocorrect: false,
                            onSaved: (String email) {

                            },
                            validator: (String value) {
                              if (value.length >= 4) {
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
                                hintText: 'Team Name'),
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Themes.theme1['TextColor']),
                          ),
                          data: ThemeData(primaryColor: Colors.orange,accentColor: Colors.cyan),
                        ),
                      ),
                      Container(
                        height: 60,
                      ),
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),color: buttonColor())
                        ,margin: const EdgeInsets.fromLTRB(20, 40, 20, 10),
                        child:
                        FlatButton(
                          child: Text(
                            'Add name',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.normal,
                                fontSize: 14),
                          ),
                          onPressed: () {
                            addTeamAction();
                          },
                        ),)
                      ,
                    ],
                  ),
                )
            ),
          )
        ],
      )),
    );
  }
}
