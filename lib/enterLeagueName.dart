import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'databaseOperations/Backend.dart';
import 'enterSubleagueName.dart';
import 'utilities.dart';

class EnterLeagueName extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EnterLeagueNameState();
  }
}

class EnterLeagueNameState extends State<EnterLeagueName> {
  TextEditingController controller = TextEditingController(text: '');
  bool isNameValid = false;
  bool isLoading = true;

  @override
  void initState() {
    Backend.readLeagueData().whenComplete((){
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  Color buttonColor() {
    if (controller.text.length >= 3) {
      return Colors.orange;
    }
    return Colors.orange[200];
  }


  Future<void> nextButtonAction() async {
    if(isNameValid){
      if(Backend.checkLeagueName(controller.text) == 'League already exists'){
        if (Platform.isIOS) {
          showCupertinoDialog<CupertinoAlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('League already exists'),
                  content: const Text('Please choose another name'),
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
        }
        else {
          showDialog<AlertDialog>(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: const Text('League already exists'),
              content: const Text('Please choose another name'),
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
      }
      else {
        Navigator.push<Object>(context, MaterialPageRoute<EnterSubleagueName>(builder: (BuildContext context){
          return EnterSubleagueName(controller.text);
        }));
      }

      }


    }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Enter league name'),
          backgroundColor: Colors.orange),
      backgroundColor: Themes.theme1['CardColor'],
      body: Container(
        child: ModalProgressHUD(inAsyncCall: isLoading, child: Column(
          children: <Widget>[
            const SizedBox(
              height: 100,
            ),
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: Form(child: Theme(
                child: TextFormField(
                  controller: controller,
                  autocorrect: false,

                  onSaved: (String leagueName) {},
                  validator: (String value) {
                    if (value.length >= 3) {
                      isNameValid = true;
                      return null;
                    }
                    isNameValid = false;
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
                      hintText: 'New league name'),
                  style: TextStyle(
                      fontFamily: 'Poppins', color: Themes.theme1['TextColor']),
                ),
                data: ThemeData(
                    primaryColor: Colors.orange, accentColor: Colors.cyan),
              ),onChanged: (){
                setState(() {

                });
              },),
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
                    await nextButtonAction();
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Colors.black),
                  )),
            ),
            Spacer()
          ],
        )),
      ),
    );
  }
}
