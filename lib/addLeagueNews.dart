import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'colors.dart';
import 'utilities.dart';

class AddLeagueNews extends StatefulWidget {
  const AddLeagueNews(this.leagueName, this.newsArray);
  final String leagueName;
  final List<dynamic> newsArray;

  @override
  State<StatefulWidget> createState() {
    return AddLeagueNewsState();
  }
}

class AddLeagueNewsState extends State<AddLeagueNews> {

  Future<http.Response> sendNotification(
      String email, String title, String content) async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final String email = user.email.replaceAll('.', '-');
    return http.Client().post(
        'https://us-central1-league2-33117.cloudfunctions.net/genericNotification?email=$email&title=$title&content=$content');
  }

  var formKey = GlobalKey<FormState>();
  var newsController = TextEditingController(text: '');
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Text('Add League News'),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Themes.theme1['CardColor'],
      body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Column(
            children: <Widget>[
              Container(
                child: Container(
                  height: 400,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                  child: Form(
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
                              controller: newsController,
                              autocorrect: false,
                              onSaved: (String email) {},
                              validator: (String value) {
                                if (newsController.text.length >= 4) {
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
                                  hintText: 'Add News'),
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Themes.theme1['TextColor']),
                            ),
                            data: ThemeData(
                                primaryColor: Colors.orange,
                                accentColor: Colors.cyan),
                          ),
                        ),
                        Container(
                          height: 60,
                        ),
                        Container(
                          color: Colors.orange,
                          height: 50,
                          margin: const EdgeInsets.only(
                              top: 20, left: 40, right: 40),
                          child: FlatButton(
                              child: Text(
                                'Add News',
                                style: CustomTextStyles.regularText,
                              ),
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                if (formKey.currentState.validate()) {
                                  formKey.currentState.save();
                                  print(widget.newsArray);
                                  List<dynamic> temp = <dynamic>[];
                                  widget.newsArray.forEach(
                                      (dynamic each) => temp.add(each));
                                  temp.add(newsController.text);
                                  print(temp);
                                  Firestore.instance
                                      .collection('Leagues')
                                      .document(widget.leagueName)
                                      .collection('League News')
                                      .document('News')
                                      .setData(<String, dynamic>{
                                    'News': temp
                                  }).then((vlaue) async {
                                    QuerySnapshot admins = await Firestore.instance.collection('Leagues').document(widget.leagueName).collection('Admins').getDocuments();
                                    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
                                    for(DocumentSnapshot admin in admins.documents){
                                      if (currentUser.email.replaceAll('.', '-') != admin.documentID){
                                        sendNotification(admin.documentID, 'New news added', 'News of ' + widget.leagueName + 'is updated.');
                                      }
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (Platform.isIOS) {
                                      showCupertinoDialog<CupertinoAlertDialog>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CupertinoAlertDialog(
                                              title: const Text('Admins are notified about new news'),
                                              actions: <Widget>[
                                                CupertinoDialogAction(
                                                  child: const Text('OK'),
                                                  isDefaultAction: true,
                                                  onPressed: () {
                                                    Navigator.pop(context);
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
                                              title: const Text('Admins are notified about new news'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);

                                                  },
                                                )
                                              ],
                                            );
                                          });
                                    }
                                  });
                                }
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
