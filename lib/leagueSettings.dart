import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'colors.dart';

import 'utilities.dart';

class LeagueSettings extends StatefulWidget {
  const LeagueSettings(this.leagueName);
  final String leagueName;
  @override
  State<StatefulWidget> createState() {
    return LeagueSettingsState();
  }
}

class LeagueSettingsState extends State<LeagueSettings> {
  String leaguePhoto = '';
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController idController = TextEditingController(text: '');
  String leagueID = '';
  bool isLoading = false;
  Future<void> fetchLeaguePhoto() async {
    var temp = await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .get();
    setState(() {
      leaguePhoto = temp.data['leaguePhoto'] ?? '';
      leagueID = temp.data['leagueID'] ?? '';
    });
  }

  Color buttonColor() {
    if (idController.text.length >= 3) {
      return Colors.orange;
    }
    return Colors.orange[200];
  }

  Future<void> updateLeagueInfo() async{
    if (idController.text.length >= 3) {
      setState(() {
        isLoading = true;
      });
      bool leagueExist = false;
      Map<String, dynamic> map = <String, dynamic>{};
      if (idController.text.trim().isNotEmpty) {
        map['leagueID'] = idController.text;
        QuerySnapshot docs = await Firestore.instance.collection('Leagues').getDocuments();
        for(DocumentSnapshot doc in docs.documents){
          if (doc.data['President']['leagueID'] == idController.text.trim()){
            leagueExist = true;
          }
        }

        setState(() {
          isLoading = false;
        });
        if (leagueExist){
          if (Platform.isIOS) {
            showCupertinoDialog<CupertinoAlertDialog>(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                    title: const Text('League iD already exist'),
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
                    title: const Text('League ID Does not exist'),
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
        } else{
          final DocumentSnapshot presidentData = await Firestore.instance
              .collection('Leagues')
              .document(widget.leagueName)
              .get();
          presidentData.data['President']['leagueID'] = idController.text.trim();

          await Firestore.instance.collection('Leagues').document(widget.leagueName).setData(presidentData.data);
          setState(() {
            isLoading = false;
            leagueID = idController.text;
          });
          Navigator.pop(context);
        }

      }
    } else {

    }
  }

  Future<void> chooseLeaguePic() async {
    String location;
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    StorageUploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child('LeaguePhotos/' + widget.leagueName)
        .putFile(image);
    location = await (await uploadTask.onComplete).ref.getDownloadURL();
    print(await (await uploadTask.onComplete).ref.getDownloadURL());
    await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .updateData(<String, dynamic>{'leaguePhoto': location});
    setState(() {
      leaguePhoto = location ?? '';
    });
  }

  @override
  void initState() {
    fetchLeaguePhoto();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('League Settings'),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Themes.theme1['CardColor'],
      resizeToAvoidBottomPadding: false,
      body: ModalProgressHUD(inAsyncCall: isLoading, child: Container(
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Spacer(),
                FlatButton(
                  child: Container(
                    width: 120,
                    child: ClipRRect(
                      child: Container(
                        height: 120,
                        width: 120,
                        child: FadeInImage.assetNetwork(
                            placeholder: 'images/medal.png',
                            image: leaguePhoto),
                        color: Colors.deepPurple,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(120)),
                    ),
                  ),
                  onPressed: () {
                    chooseLeaguePic();
                  },
                ),
                Spacer(),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: <Widget>[
                  Text(
                    'League Name',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
//                  margin: EdgeInsets.only(left: 20,right: 20),
                    child: Text(
                      widget.leagueName,
                      style: TextStyle(
                        color: Themes.theme1['TextColor'],
                        fontFamily: 'Arial',
                        fontSize: 18,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: <Widget>[
                  Text(
                    'League ID        ',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
//                  margin: EdgeInsets.only(left: 20,right: 20),
                    child: Container(
                      margin: const EdgeInsets.only(left: 16, right: 16),
                      child: Theme(
                        child: Form(child: TextFormField(
                          controller: idController,
                          autocorrect: false,
                          onSaved: (String id) {},
                          validator: (String value) {
                            if (value.length >= 3) {
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
                              hintText: leagueID),
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Themes.theme1['TextColor']),
                        ),onChanged: (){
                          setState(() {

                          });
                        },),
                        data: ThemeData(
                            primaryColor: Colors.orange,
                            accentColor: Colors.cyan),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: buttonColor(), borderRadius: BorderRadius.circular(4)),
              margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: FlatButton(
                child: Text(
                  'Update League Info',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 14),
                ),
                onPressed: () async{
                  await updateLeagueInfo();
                },
              ),
            ),
          ],
        ),
      )),
    );
  }
}
