import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'colors.dart';
import 'forgetPassword.dart';
import 'selectDesiredLegue.dart';

class WelcomePage extends StatefulWidget {
  static const List<String> PRODUCT_IDS = <String>['1eleague_54'];

  @override
  State<StatefulWidget> createState() {
    return WelcomeState();
  }
}

class WelcomeState extends State<WelcomePage> {
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;

  void showBottomActionSheet(BuildContext context) {
    if (Platform.isAndroid) {
      showModalBottomSheet<Widget>(
          context: context,
          builder: (BuildContext buildContext) {
            return Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    title: const Text('Forgot Password'),
                    onTap: () {
                      Navigator.push<Object>(context,
                          MaterialPageRoute<ForgotPassword>(
                              builder: (BuildContext context) {
                        return ForgotPassword();
                      }));
                    },
                  ),
                ],
              ),
            );
          });
    } else {
      showCupertinoModalPopup<CupertinoActionSheet>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: const Text('Forgot Password?'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push<Object>(context,
                      MaterialPageRoute<ForgotPassword>(
                          builder: (BuildContext context) {
                    return ForgotPassword();
                  }));
                },
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              child: const Text('Cancel'),
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
            )),
      );
    }
  }

  bool lock = true;
  bool showText = true;
  bool showLoader = false;
  var formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController password = TextEditingController(text: '');

  Icon lockIcon() {
    if (lock) {
      return Icon(
        Icons.lock,
        color: Colors.white,
      );
    } else {
      return Icon(
        Icons.lock_open,
        color: Colors.white,
      );
    }
  }

  void toggle() {
    setState(() {
      if (lock) {
        lock = false;
        showText = false;
      } else {
        lock = true;
        showText = true;
      }
    });
  }

  Color buttonColor() {
    if (emailController.text.length >= 5 && password.text.length >=8){
      return Colors.orange;
    }
    return Colors.orange[200];
  }

  Future<void> signInAction() async{
    if (emailController.text.length >= 5 && password.text.length >=8){
      try{
        final List<InternetAddress> result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          setState(() {
            showLoader = true;
          });
          final FirebaseAuth instance = FirebaseAuth.instance;
          final FirebaseUser user = await instance.signInWithEmailAndPassword(
              email: emailController.text, password: password.text);
          setState(() {
            showLoader = false;
          });
          Navigator.push<Object>(context, MaterialPageRoute<SelectDesiredLeague>(builder: (BuildContext context){
            return SelectDesiredLeague();
          }));

        }
      } catch (e) {
        print(e);
        setState(() {
          showLoader = false;
        });
        if (Platform.isIOS) {
          showCupertinoDialog<CupertinoAlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('Some error occurred'),
                  content: const Text('Sign in failed.'),
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
              title: const Text('Some error occurred'),
              content: const Text('Sign in failed.'),
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
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(title: const Text('Sign in'),backgroundColor: Colors.orange,),
      body: GestureDetector(
        child: ModalProgressHUD(inAsyncCall: showLoader, child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: formKey,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                const SizedBox(
                  height: 16,
                ),
                Container(
                  child: Align(
                    child: Container(
                      child: FlatButton(
                          onPressed: () {
                            showBottomActionSheet(context);
                          },
                          child: Text(
                            'Help',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Themes.theme1['TextColor'],
                                fontSize: 16),
                          )),
                      width: 100,
                    ),
                    alignment: Alignment.topRight,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 16, top: 16),
                  child: Text(
                    'Sign in with your email address',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Themes.theme1['TextColor']),
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  child: Theme(
                    child: TextFormField(
                      controller: emailController,
                      autocorrect: false,
                      onSaved: (String email) {

                      },
                      validator: (String value) {
                        if (RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                            .hasMatch(value)||value.length<=1) {
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
                          hintText: 'Email address'),
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Themes.theme1['TextColor']),
                    ),
                    data: ThemeData(primaryColor: Colors.orange,accentColor: Colors.cyan),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  child: Theme(
                    child: TextFormField(
                      controller: password,

                      autocorrect: false,
                      onSaved: (String password) {

                      },
                      validator: (String value) {
                        if (value.length>=8 || value.length<=1) {
                          return null;
                        }
                        return '';
                      },
                      autovalidate: true,
                      obscureText: showText,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: lockIcon(),
                              onPressed: () {
                                toggle();
                              }),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyan),
                          ),
                          hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Themes.theme1['SubTextColor']),
                          hintText: 'Password'),
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Themes.theme1['TextColor']),
                    ),
                    data: ThemeData(primaryColor: Colors.orange),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: buttonColor()),
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  height: 40,
                  child: FlatButton(

                      onPressed: (){
                        signInAction();
                      }, child: const Text('Sign in',style: TextStyle(color: Colors.black),)),
                )
              ],
            ),
          ),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Themes.theme1['CardColor'],
            Themes.theme1['PrimaryColor']
          ], stops: const <double>[
            1,
            0.0
          ])),
        )),
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
      ),
    );
  }


}
