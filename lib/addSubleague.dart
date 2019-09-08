import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'colors.dart';
import 'utilities.dart';

class AddSubleague extends StatefulWidget {
  final String leagueName;
  AddSubleague(this.leagueName);

  @override
  State<StatefulWidget> createState() {
    return AddSubleagueState();
  }
}

class AddSubleagueState extends State<AddSubleague> {
  GlobalKey formKey = GlobalKey<FormState>();
  TextEditingController subLeagueController = TextEditingController(text: '');

  bool isLoading = false;

  Color buttonColor() {
    if (subLeagueController.text.length >= 3){
      return Colors.orange;
    }
    return Colors.orange[200];
  }

  void addSubleagueAction() {
    if (subLeagueController.text.length >= 3){
      setState(() {
        isLoading = true;
      });
      Firestore.instance
          .collection('Leagues')
          .document(widget.leagueName)
          .collection('Subleagues')
          .document(subLeagueController.text)
          .setData(<String,dynamic>{}).then((value) {
            setState(() {
              isLoading = false;
            });
        return Navigator.pop(context);
      });
    }
    else {

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subleague'),
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
                      controller: subLeagueController,
                      autocorrect: false,
                      onSaved: (String email) {

                      },
                      validator: (String value) {
                        if (value.length >=3) {
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
                          hintText: 'Subleague Name'),
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
                      'Add Subleague',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                          fontSize: 14),
                    ),
                    onPressed: () {
                      addSubleagueAction();
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
