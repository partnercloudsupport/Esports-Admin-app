import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'utilities.dart';
import 'databaseOperations/Backend.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'isUserSignUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';
import 'package:flutter/cupertino.dart';

class IsUserLogin extends StatefulWidget {
  final String leagueID;
  final String subleagueName;
  final String leagueName;
  final List<String> teamNames;
  final Map<String,List<Map<String,String>>> weeksSchedule;
  IsUserLogin(this.leagueID,this.subleagueName,this.leagueName,this.weeksSchedule,this.teamNames);
  @override
  State<StatefulWidget> createState() {
    return IsUserLoginView(this.leagueID,this.subleagueName,this.leagueName,this.weeksSchedule,this.teamNames);
  }
}


class IsUserLoginView extends State<IsUserLogin> with TickerProviderStateMixin {
  final String leagueID;
  final String subleagueName;
  final String leagueName;
  final Map<String,List<Map<String,String>>> weeksSchedule;
  final List<String> teamNames;

  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userPic = "";
  FirebaseUser currentUser;
  IsUserLoginView(this.leagueID,this.subleagueName,this.leagueName,this.weeksSchedule,this.teamNames);
  var emailController = TextEditingController(text: "");
  var passwordController = TextEditingController(text: "");
  var forgotPasswordController = TextEditingController(text: "");
  final GoogleSignIn googleSignIn = GoogleSignIn();
  var _logging_in = false;
  var loginButtonPressed = false;
  final utilities = Utilities();
  AnimationController controller;
  Animation<double> animation;

  bool validateForm() {
    emailFormKey.currentState.validate();
    passwordFormKey.currentState.validate();
    return emailFormKey.currentState.validate() &&
        passwordFormKey.currentState.validate();
  }
  Future<void> startMakingEntryInDatabase(String email) async {
    await Firestore.instance.collection('Leagues').document(this.leagueName).updateData(<String,dynamic>{
      "leagueID":this.leagueID
    });

    await Firestore.instance.collection('Leagues').document(this.leagueName).collection("Presidents").document(email.replaceAll(".", "-")).setData(<String,dynamic>{});
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

  Future<void> login(String email, String password) async{
    Backend.login(email, password).then((value) {
      String title;
      String description;
      _logging_in = false;
      loginButtonPressed = false;
      if (value == null) {
        utilities.logEvent("dashboard");
        startMakingEntryInDatabase(email);
        Navigator.push<Object>(context,
            MaterialPageRoute<Dashboard>(
                builder: (BuildContext context) => Dashboard(this.leagueName)));
      } else {
        if (value.contains('ERROR_USER_NOT_FOUND')) {
          title = "Incorrect Username/Password";
          description = "Please try again.";
        } else if (value.contains("ERROR_INVALID_EMAIL")) {
          title = "Email is invalid";
          description = "";
        } else if (value.contains("ERROR_WRONG_PASSWORD")) {
          title = "Incorrect Username/Password";
          description = "Please try again.";
        } else {
          print(value);
          title = "Some Error Occured";
          description = "";
        }
        if(Platform.isAndroid){
          showDialog<AlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return Utilities.alert(title, description, context);
              });
        }
        else{
          showDialog<CupertinoAlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return Utilities.iosAlert(title, description, context);
              });
        }

      }
    });
  }

  Future<String> useGoogle() async {
//    try{
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    if (googleUser == null){
      return "Failed";
    }
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

    final FirebaseUser user = await auth.signInWithCredential(credential);
    this.currentUser = await auth.currentUser();

    Backend.makeAnEntryInFirestore(currentUser.email, leagueID,leagueName,currentUser.displayName,currentUser.photoUrl ?? "");

    utilities.logEvent("dashboard_via_google");
    startMakingEntryInDatabase(currentUser.email);

    Navigator.push<Object>(

        context,
        MaterialPageRoute<Dashboard>(

            builder: (BuildContext context) => Dashboard(this.leagueName)));

    return "Done";
//    }
//    catch (e){
//      print(e);
//    }

  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this,duration: Duration(milliseconds: 600));
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: ModalProgressHUD(
            inAsyncCall: _logging_in,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Center(
                child: Container(
                  color: Themes.theme1["CardColor"],

                  child: Container(
                    margin: EdgeInsets.only(
                        top: 40, left: 20, right: 20, bottom: 40),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Utilities.cornerRadius),side:BorderSide(color: Themes.theme1["HighLightColor"],width: 2.0) ),
                      color: Themes.theme1["CardColor"],
                      child: FadeTransition(opacity: animation,child:

                      ListView(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Container(margin: EdgeInsets.only(left: 40,right: 40,bottom: 30),child: Text("Let's make this official",style: TextStyle(fontSize: 25,fontFamily: 'Poppins',fontStyle: FontStyle.normal,fontWeight: FontWeight.bold,color: Colors.white),),)  ,

                          Container(
                            height: 47 ,
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 40),
                            child: Form(
                              key: emailFormKey,
                              child: TextFormField(

                                controller: emailController,
                                style: TextStyle(
                                  color: Themes.theme1["TextColor"],
                                  fontFamily: "Arial",
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),filled: true, fillColor: Themes.theme1["TextFieldFillColor"],
                                    labelText: 'Enter your email',
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
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ),
                          Container(
                              height: 47,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 40),
                              child: Form(
                                key: passwordFormKey,
                                child: TextFormField(
                                  controller: passwordController,
                                  style: TextStyle(
                                      color: Themes.theme1["TextColor"],
                                      fontFamily: "Poppins",fontWeight: FontWeight.bold, fontSize: 14
                                  ),
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),filled: true, fillColor: Themes.theme1["TextFieldFillColor"],
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                          color: Themes.theme1["TextPlaceholderColor"]),
                                      errorStyle: TextStyle(fontSize: 14)),
                                  autovalidate: false,
                                  validator: (String value) {
                                    print(value);
                                    if (value.length < 8) {
                                      return "Password should be greater than 8";
                                    }
                                  },
                                ),
                              )),
                          Container(
                            margin: EdgeInsets.only(
                                top: 20, bottom: 10, left: 10, right: 10),
                            height: 55,

                            child: Container(

                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 30),
                              child: RaisedGradientButton(
                                child: Text(
                                  'Login',
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
                                  if (!loginButtonPressed) {
                                    if (validateForm()) {
                                      _logging_in = true;
                                      loginButtonPressed = true;

                                      this.login(
                                          emailController.text.toLowerCase(),
                                          passwordController.text);
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: 20, bottom: 10, left: 10, right: 10),

                            child: Container(
                              height: 50,
                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 30),
                              child: RaisedGradientButton(
                                child: Text(
                                  'Google',
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
                                  try {
                                    useGoogle();
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(border: Border.all(color:Themes.theme1["FirstGradientColor"])),
                            margin: EdgeInsets.only(top: 20,left: 40,right: 40),
                            child: FlatButton(

                                child: Row(children: <Widget>[
                                  Spacer(),
                                  Icon(Icons.star,color: Themes.theme1["FirstGradientColor"],),
                                  Text(
                                    'Sign Up?',
                                    style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.bold, fontSize: 14,color: Colors.white),
                                  ),Spacer()],),
                                onPressed: () {
                                  utilities.logEvent("sign_up_page");
                                  Navigator.push<Object>(
                                      context,
                                      MaterialPageRoute<IsUserSignUpPage>(
                                          builder: (BuildContext context) =>
                                              IsUserSignUpPage(leagueID, subleagueName, leagueName, weeksSchedule,this.teamNames))
                                  );
                                }),
                          )
                          ,Container(
                            margin: EdgeInsets.only(top: 10,left: 40,right: 40),

                            child: FlatButton(
                                child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.bold, fontSize: 14,color: Themes.theme1["TextPlaceholderColor"])
                                ),
                                onPressed: () {
                                  Navigator.push<Object>(context, MaterialPageRoute<Text>(builder: (BuildContext context){
                                    return Text("Forgot Password");
                                  }));

                                }),
                          )
                        ],
                      ),) ,
                    ),
                  ),
                ),
              ),
            ),
          )),
      onWillPop: () {
        return new Future(() => true);
      },
    );
  }
}


