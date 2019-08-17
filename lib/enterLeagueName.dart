import 'package:flutter/material.dart';
import 'colors.dart';
import 'utilities.dart';
import 'enterSubleagueName.dart';
import 'databaseOperations/Backend.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class EnterLeagueName extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EnterLeagueNameState();
  }
}

class EnterLeagueNameState extends State<EnterLeagueName> {
  var controller = TextEditingController(text: "");
  final GlobalKey<FormState> _controllerKey = GlobalKey<FormState>();

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
                      hintText: "Enter new league name",
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
              onPressed: () async{
                print(controller.text);
                if(Backend.checkLeagueName(controller.text) == "League already exists"){
                if(Platform.isIOS){
                  showDialog<CupertinoAlertDialog>(
                      context: context,
                      builder: (BuildContext context) {
                        return Utilities.iosAlert(
                            "League already exists", "Please choose another name.", context);
                      });
                }
                else{
                  showDialog<AlertDialog>(
                      context: context,
                      builder: (BuildContext context) {
                        return Utilities.alert(
                            "League already exists", "Please choose another name.", context);
                      });
                }
                } else{
                  Navigator.push<Object>(context, MaterialPageRoute<EnterSubleagueName>(builder: (BuildContext context){
                    return EnterSubleagueName(this.controller.text);
                  }));
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
