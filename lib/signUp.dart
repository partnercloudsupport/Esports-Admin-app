import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'databaseOperations/Backend.dart';
import 'utilities.dart';
import 'colors.dart';
import 'utilities.dart';
import 'dart:io';

class SignUpPage extends StatefulWidget {
  String leagueID;
  SignUpPage(this.leagueID);
  String leagueName ;

  Future<void> getLeagueName() async{
    this.leagueName = await Backend.getLeagueNameFromLeagueID(leagueID);
  }

  @override
  State<StatefulWidget> createState() {
    getLeagueName();
    return SignUpPageState(leagueName,this.leagueID);
  }
}

class SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  String leagueName;
  String leagueID;
  //Signup method

  var formKey = GlobalKey<FormState>();
  Map<String, String> signupData = {"email": "", "password": ""};
  SignUpPageState(this.leagueName,this.leagueID);
  final utilites = Utilities();
  AnimationController controller;
  Animation<double> animation;

  initState(){
    getLeagueName();
    controller = AnimationController(vsync: this,duration: Duration(milliseconds: 600));
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  Future<void> getLeagueName() async{
    this.leagueName = await Backend.getLeagueNameFromLeagueID(leagueID);
  }

  Future<void> signup(String email, String password,String league) {
    Backend.signUp(email, password,league, false).then((value){
      String title = "";
      String description = "";
      if (value.contains("providerData")) {
        utilites.logEvent("dashboard_via_sign_up");
        Navigator.pushReplacement<Object,Object>(
            context,
            MaterialPageRoute(
                builder:
                    (BuildContext context) =>
                    Text("Dashboard")));
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


            body:FadeTransition(opacity: animation,child: Column(children: <Widget>[Container(margin: EdgeInsets.only(top: 40),child: Text("Sign Up",style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontStyle: FontStyle.normal,fontWeight: FontWeight.bold,color: Colors.white),),),


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

