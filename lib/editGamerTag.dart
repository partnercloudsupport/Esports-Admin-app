import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'utilities.dart';

class EditGamerTag extends StatefulWidget {
  EditGamerTag(this.gamerTag, this.email,this.callback);
  Function callback;
  final String gamerTag;
  final String email;
  @override
  State<StatefulWidget> createState() {
    return EditGamerTagState();
  }
}

class EditGamerTagState extends State<EditGamerTag> {
  var formKey = GlobalKey<FormState>();
  TextEditingController gamerTagController = TextEditingController(text: '');
  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Gamertag'),
        backgroundColor: Colors.orange,
      ),
      resizeToAvoidBottomPadding: false,
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
                              controller: gamerTagController,
                              autocorrect: false,
                              onSaved: (String email) {},
                              validator: (String value) {
                                if (gamerTagController.text.length >= 6) {
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
                                  hintText: widget.gamerTag),
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
                                'Edit Gamertag',
                                style: CustomTextStyles.regularText,
                              ),
                              onPressed: () async{

                                if (formKey.currentState.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  formKey.currentState.save();
                                  QuerySnapshot users = await Firestore.instance.collection('Users').getDocuments();
                                  bool userExists = false;
                                  for(DocumentSnapshot snap in users.documents){
                                    if (snap.data['gamerTag'].toString().toLowerCase() == gamerTagController.text.toLowerCase()){
                                      userExists = true;
                                      break;
                                    }
                                  }

                                  if(userExists){
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (Platform.isIOS) {
                                      showCupertinoDialog<CupertinoAlertDialog>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CupertinoAlertDialog(
                                              title: const Text('Name is already taken'),
                                              actions: <Widget>[
                                                CupertinoDialogAction(
                                                  child: const Text('OK'),
                                                  isDefaultAction: false,
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    } else {
                                      showDialog<AlertDialog>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Name is already taken'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),

                                              ],
                                            );
                                          });
                                    }
                                  } else {
                                    Firestore.instance
                                        .collection('Users')
                                        .document(widget.email)
                                        .updateData(<String, dynamic>{
                                      'gamerTag': gamerTagController.text.toLowerCase()
                                    }).whenComplete((){
                                      setState(() {
                                        isLoading = false;
                                        widget.callback();
                                        Navigator.pop(context);
                                      });
                                    });
                                  }

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
