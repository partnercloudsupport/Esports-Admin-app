import 'package:flutter/material.dart';

import 'databaseOperations/Backend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'utilities.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ForgotPasswordState();
  }
}

class ForgotPasswordState extends State<ForgotPassword> with TickerProviderStateMixin {

  AnimationController controller;
  Animation<double> animation;
  var formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController(text: "");
  initState(){
    controller = AnimationController(vsync: this,duration: Duration(milliseconds: 600));
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
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


            body:FadeTransition(opacity: animation,child: Column(children: <Widget>[Container(margin: EdgeInsets.only(top: 40),child: Text("Forgot Password?",style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontStyle: FontStyle.normal,fontWeight: FontWeight.bold,color: Colors.white),),),


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
                                  this.email.text = value.toLowerCase();
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
                            height: 50,
                            margin: EdgeInsets.only(top:20,left: 40,right: 40),
                            child: RaisedGradientButton(
                                child: Text(
                                  'Reset Password',
                                  style: CustomTextStyles.boldLargeText,
                                ), gradient: LinearGradient(colors: [
                              Themes.theme1["FirstGradientColor"],
                              Themes.theme1["SecondGradientColor"]
                            ]),
                                onPressed: () {
                                  if (formKey.currentState.validate()) {
                                    formKey.currentState.save();

                                    FirebaseAuth auth = FirebaseAuth.instance;
                                    auth.sendPasswordResetEmail(email: email.text.trim());
                                    Navigator.pop(context);


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
