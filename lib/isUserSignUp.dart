import 'package:flutter/material.dart';
import 'databaseOperations/Backend.dart';
import 'utilities.dart';
import 'colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'dashboard.dart';

class IsUserSignUpPage extends StatefulWidget {
  final String leagueID;
  final String subleagueName;
  final String leagueName;
  final List<String> teamNames;

  final Map<String,List<Map<String,String>>> weeksSchedule;
  IsUserSignUpPage(this.leagueID,this.subleagueName,this.leagueName,this.weeksSchedule,this.teamNames);
  @override
  State<StatefulWidget> createState() {
    var leagueName = Backend.getLeagueNameFromLeagueID(leagueID);
    return IsUserSignUpPageState(this.leagueID,this.subleagueName,this.leagueName,this.weeksSchedule,this.teamNames);
  }
}

class IsUserSignUpPageState extends State<IsUserSignUpPage> with TickerProviderStateMixin {
  final String leagueID;
  final String subleagueName;
  final String leagueName;
  final List<String> teamNames;
  final Map<String,List<Map<String,String>>> weeksSchedule;
  //Signup method
  var formKey = GlobalKey<FormState>();
  Map<String, String> signupData = {"email": "", "password": ""};
  IsUserSignUpPageState(this.leagueID,this.subleagueName,this.leagueName,this.weeksSchedule,this.teamNames);
  final utilites = Utilities();
  AnimationController controller;
  Animation<double> animation;

  initState(){
    controller = AnimationController(vsync: this,duration: Duration(milliseconds: 600));
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  Future<void> startMakingEntryInDatabase(String email) async {
    // Create league
    await Firestore.instance.collection('Leagues').document(this.leagueName).updateData(<String,dynamic>{
      "leagueID":this.leagueID
    });

    await Firestore.instance.collection('Leagues').document(this.leagueName).collection("Admins").document(email.replaceAll(".", "-")).setData(<String,dynamic>{});
    // Store subleague

    // Store all teams in database
    for(var team in this.teamNames){
      await Firestore.instance.collection('Leagues').document(this.leagueName).collection("Subleagues").document(this.subleagueName).collection("Teams").document(team).setData(<String,dynamic>{
      });
    }
    // Store schedules.
    for (var each in this.weeksSchedule.entries){
      await Firestore.instance.collection('Leagues').document(this.leagueName).collection('Schedule').document(each.key).setData(<String,dynamic>{"schedule":each.value});
    }

  }
  Future<void> signup(String email, String password,String league) {
    Backend.signUp(email, password,league, true).then((value){
      String title = "";
      String description = "";
      if (value.contains("providerData")) {
        utilites.logEvent("dashboard_via_sign_up");
        startMakingEntryInDatabase(email);
        Navigator.pushReplacement<Object,Object>(
            context,
            MaterialPageRoute(
                builder:
                    (BuildContext context) =>
                    Dashboard()));
      } else {
        if (value.contains(
            "ERROR_EMAIL_ALREADY_IN_USE")) {
          title = "User Exists";
          description =
          "Email Id already in use. Kindly sign in.";
        } else {
          title = "Some error occurred";
        }
        if(Platform.isIOS){
          showDialog<CupertinoAlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return Utilities.iosAlert(
                    title, description, context);
              });
        }
        else{
          showDialog<AlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return Utilities.alert(
                    title, description, context);
              });
        }

      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(child: Scaffold(
        resizeToAvoidBottomPadding: false,

        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },

          child: Scaffold(backgroundColor: Themes.theme1["CardColor"],
            resizeToAvoidBottomPadding: false,


            body:FadeTransition(opacity: animation,child: Column(children: <Widget>[
              SizedBox(
                height: 40,
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  Text(
                    'Sign Up',
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
                height: 10,
              ),

              Container(
                child: Container(
                  height: 400,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Utilities.cornerRadius),side:BorderSide(color: Themes.theme1["HighLightColor"],width: 2) ),

                    color: Themes.theme1["CardColor"],
                    margin: EdgeInsets.only(top: 20,left: 20,right: 20),
                    child:


                    Form(
                      key: formKey,
                      child: ListView(
                        children: <Widget>[
                          SizedBox(height: 40,)
                          ,                  Container(
                            height: 60,
                            child: TextFormField(style: CustomTextStyles.regularText,
                                onSaved: (value) {
                                  signupData["email"] = value.toLowerCase();
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),filled: true, fillColor: Themes.theme1["TextFieldFillColor"],
                                    labelText: 'Email ',
                                    labelStyle: TextStyle(
                                        color: Themes.theme1["TextPlaceholderColor"],fontFamily: 'Poppins',fontWeight: FontWeight.bold, fontSize: 14
                                    ),
                                    errorStyle: TextStyle(fontSize: 14)),
                                autovalidate: false,
                                validator: (String emailID) {
                                  if (emailID.isEmpty) {
                                    return "Please enter your email id.";
                                  } else if (RegExp(
                                      r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(emailID) ==
                                      false) {
                                    return "Entered email is not valid";
                                  }
                                }
                            ),
                            margin: EdgeInsets.only(left: 40, right: 40),
                          ),
                          Container(
                            height: 60,
                            child: TextFormField(style: CustomTextStyles.regularText,
                              onSaved: (value) {
                                signupData["password"] = value;
                              },
                              obscureText: true,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),filled: true, fillColor: Themes.theme1["TextFieldFillColor"],
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                      color: Themes.theme1["TextPlaceholderColor"],fontFamily: 'Poppins',fontWeight: FontWeight.bold, fontSize: 14
                                  ),
                                  errorStyle: TextStyle(fontSize: 14)),
                              autovalidate: false,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter password';
                                } else if (value.length <= 8) {
                                  return 'Password should be atleast 8 characters long';
                                }
                              },
                            ),
                            margin: EdgeInsets.only(top: 20,left: 40, right: 40),
                          ),
                          Container(
                            height: 50,
                            margin: EdgeInsets.only(top:20,left: 40,right: 40),
                            child: RaisedGradientButton(
                                child: Text(
                                  'Sign Up',
                                  style: CustomTextStyles.boldLargeText,
                                ), gradient: LinearGradient(colors: [
                              Themes.theme1["FirstGradientColor"],
                              Themes.theme1["SecondGradientColor"]
                            ]),
                                onPressed: () {
                                  if (formKey.currentState.validate()) {
                                    formKey.currentState.save();
                                    this.signup(this.signupData["email"],
                                        this.signupData["password"],this.leagueName);


                                  }
                                }
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15),child: FlatButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: Text('Back to login',
                            style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.bold, fontSize: 14,color: Themes.theme1["TextPlaceholderColor"])
                            ,)),)
                        ],
                      ),
                    ),),),
              )],),),),
        )),onWillPop: (){
      return new Future(() => true);
    },);
  }
}