import 'package:flutter/material.dart';
import 'colors.dart';
import 'utilities.dart';
import 'databaseOperations/Backend.dart';
import 'enterNumberOfTeams.dart';

class EnterSubleagueName extends StatefulWidget {
  final String leagueName;
  EnterSubleagueName(this.leagueName);
  @override
  State<StatefulWidget> createState() {
    return EnterSubleagueNameState(this.leagueName);
  }
}

class EnterSubleagueNameState extends State<EnterSubleagueName> {
  var controller = TextEditingController(text: "");
  final GlobalKey<FormState> _controllerKey = GlobalKey<FormState>();
  final String leagueName;
  String leagueID = "";
  EnterSubleagueNameState(this.leagueName);

  @override
  void initState() {
    super.initState();
    initializeLeagueID();
  }

  Future<void> initializeLeagueID() async{
    this.leagueID = await Backend.createLeagueID(leagueName);
    setState(() {
      print(this.leagueID);
    });
  }

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
          Container(margin: EdgeInsets.only(left: 30,right: 30,bottom: 30),child: Text("League ID: $leagueID",style: TextStyle(fontSize: 25,fontFamily: 'Poppins',fontStyle: FontStyle.normal,fontWeight: FontWeight.bold,color: Colors.white),),)  ,
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
                      hintText: "Enter your first subleague name",
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
              onPressed: () {
                print(controller.text);
                Navigator.push<Object>(context, MaterialPageRoute<EnterTeamsCount>(builder: (BuildContext context){
                  return EnterTeamsCount(leagueName, leagueID, controller.text);
                }));
              },
            ),
          ),
          Spacer()
        ],
      ),),
    );
  }
}
