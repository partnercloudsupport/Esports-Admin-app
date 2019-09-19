import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'addTeamName.dart';
import 'colors.dart';

class AddTeam extends StatefulWidget {
  AddTeam(this.leagueName);
  final String leagueName;
  List<dynamic> subleagues = <String>[''];
  static dynamic subleague;
  bool isLoading = false;
  TextEditingController teamNameController = TextEditingController(text: '');
  static String teamName = '';
  static String teamPhoto = '';
  static Icon newNameIcon = Icon(
    Icons.warning,
    color: Colors.yellow,
  );
  static Icon newImageIcon = Icon(
    Icons.warning,
    color: Colors.yellow,
  );
  Icon doneIcon = Icon(
    Icons.done,
    color: Colors.green,
  );
  Icon cancelIcon = Icon(
    Icons.cancel,
    color: Colors.red,
  );

  @override
  State<StatefulWidget> createState() {
    return AddTeamState();
  }
}

class AddTeamState extends State<AddTeam> {

  @override
  void initState(){
    AddTeam.teamName = '';
    AddTeam.teamPhoto = '';
    AddTeam.newNameIcon = Icon(
      Icons.warning,
      color: Colors.yellow,
    );
    AddTeam.newImageIcon = Icon(
      Icons.warning,
      color: Colors.yellow,
    );

  }
  Widget createButton() {
    if (AddTeam.subleague != null &&
        AddTeam.teamName.length >= 4 &&
        AddTeam.teamPhoto.length >= 4) {
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4), color: Colors.orange),
        margin: const EdgeInsets.only(left: 16, right: 16, top: 60),
        height: 40,
        child: FlatButton(
            onPressed: () {
              print(AddTeam.teamPhoto);
              print(AddTeam.teamName);
              print(widget.leagueName);
              setState(() {
                widget.isLoading = true;
              });
              Firestore.instance
                  .collection('Leagues')
                  .document(widget.leagueName)
                  .collection('Subleagues').document(AddTeam.subleague).collection('Teams')
                  .document(AddTeam.teamName)
                  .setData(
                      <String, dynamic>{'teamPhoto': AddTeam.teamPhoto}).whenComplete((){
                        setState(() {
                          widget.isLoading = false;
                          if (Platform.isIOS) {
                            showCupertinoDialog<CupertinoAlertDialog>(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    title: const Text('Team created successfully'),
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
                          } else {
                            showDialog<AlertDialog>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Team created successfully'),
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
                        });
              });
            },
            child: const Text(
              'Create Team',
              style: TextStyle(color: Colors.black),
            )),
      );
    }
    return const Text('');
  }

  Future<void> chooseTeamPic() async {
    try {
      setState(() {
        widget.isLoading = true;
      });
      String location;
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      final String username = user.email.replaceAll('.', '-');
      final File image =
          await ImagePicker.pickImage(source: ImageSource.gallery);

      final StorageUploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('TeamPhotos/' + AddTeam.teamName)
          .putFile(image);
      StorageTaskSnapshot task = await uploadTask.onComplete;
      print(task);
      task.ref.getDownloadURL().then((dynamic value) {
        location = value.toString();
        print(value);
        setState(() {
          widget.isLoading = false;
          AddTeam.teamPhoto = location;
          AddTeam.newImageIcon = widget.doneIcon;
        });
      });
    } catch (e) {
      setState(() {
        widget.isLoading = false;
        AddTeam.newImageIcon = widget.cancelIcon;
      });
      print(e);
    }
  }

  void assignTeamName(String teamname, dynamic subleagueName) {
    AddTeam.teamName = teamname;
    AddTeam.subleague = subleagueName;
    setState(() {
      if (teamname.length >= 4) {
        AddTeam.newNameIcon = widget.doneIcon;
      } else {
        AddTeam.newNameIcon = widget.cancelIcon;
      }
    });
  }

  Widget addTeamNameTextfield() {
    if (AddTeam.subleague != null) {
      return Container(
        margin: const EdgeInsets.only(left: 20, top: 20, right: 20),
        child: ListTile(
          title: FlatButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute<TeamName>(
                    builder: (BuildContext context) {
                  return TeamName(
                      widget.leagueName, assignTeamName, AddTeam.subleague);
                }));
              },
              child: Text(
                'Give new team a name',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Poppins', fontSize: 18),
              )),
          trailing: AddTeam.newNameIcon,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
        ),
      );
    }
    return const Text('');
  }

  Widget addTeamPhoto() {
    if (AddTeam.subleague != null && AddTeam.teamName.length >= 4) {
      return Container(
        margin: const EdgeInsets.only(left: 20, top: 20, right: 20),
        child: ListTile(
          title: FlatButton(
              onPressed: () {
                chooseTeamPic();
              },
              child: Text(
                'Upload a photo',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Poppins', fontSize: 18),
              )),
          trailing: AddTeam.newImageIcon,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
        ),
      );
    }
    return const Text('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Team'),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Themes.theme1['CardColor'],
      resizeToAvoidBottomPadding: false,
      body: ModalProgressHUD(
          inAsyncCall: widget.isLoading,
          child: Container(
              child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 40,
                child: Text(
                  'Select a subleague',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                      color: Colors.white),
                ),
                margin: const EdgeInsets.only(left: 20),
              ),
              StreamBuilder(
                stream: Firestore.instance
                    .collection('Leagues')
                    .document(widget.leagueName)
                    .collection('Subleagues')
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot snap) {
                  if (snap.connectionState == ConnectionState.done ||
                      snap.connectionState == ConnectionState.active) {
                    if (!snap.hasData) {
                      return Container(
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [
                              Themes.theme1['FirstGradientColor'],
                              Themes.theme1['SecondGradientColor']
                            ])),
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: Container(
                          child: Text(
                            'No Subleagues',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white),
                          ),
                          margin: EdgeInsets.only(top: 20, left: 10),
                        ),
                      );
                    }
                    widget.subleagues = (snap as AsyncSnapshot<QuerySnapshot>)
                        .data
                        .documents
                        .map((e) => e.documentID)
                        .toList();
                    return Container(
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                              colors: [Colors.orange, Colors.yellow])),
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Theme(
                          data: ThemeData.dark(),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<dynamic>(
                                  hint: Container(
                                      margin: const EdgeInsets.only(left: 20),
                                      child: Text(
                                        'Please select a subleague',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.normal,
                                            fontSize: 16,
                                            color: Colors.white),
                                      )),
                                  isExpanded: true,
                                  icon: Container(
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                    margin: const EdgeInsets.only(
                                        top: 10, right: 20),
                                  ),
                                  value: AddTeam.subleague,
                                  items: widget.subleagues
                                      .map((dynamic e) =>
                                          DropdownMenuItem<dynamic>(
                                            value: e,
                                            child: Container(
                                              child: Text(
                                                e,
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                              margin: const EdgeInsets.only(
                                                  left: 10),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (dynamic value) {
                                    setState(() {
                                      AddTeam.subleague = value;
                                      AddTeam.teamName = '';
                                      AddTeam.teamPhoto = '';
                                      AddTeam.newNameIcon = Icon(
                                        Icons.warning,
                                        color: Colors.yellow,
                                      );
                                      AddTeam.newImageIcon = Icon(
                                        Icons.warning,
                                        color: Colors.yellow,
                                      );
                                      print(AddTeam.subleague);
                                    });
                                  }))),
                    );
                  } else {
                    return Center(
                      child: const CircularProgressIndicator(),
                    );
                  }
                },
              ),
              addTeamNameTextfield(),
              addTeamPhoto(),
              createButton()
            ],
          ))),
    );
  }
}
