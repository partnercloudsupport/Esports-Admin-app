import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'utilities.dart';

class LeagueSettings extends StatefulWidget {
  final String leagueName;

  LeagueSettings(this.leagueName);

  @override
  State<StatefulWidget> createState() {
    return LeagueSettingsState();
  }
}

class LeagueSettingsState extends State<LeagueSettings> {
  String leaguePhoto = "";
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController idController = TextEditingController(text: "");
  String leagueID = "";
  Future<void> fetchLeaguePhoto() async {
    var temp = await Firestore.instance
        .collection("Leagues")
        .document(widget.leagueName)
        .get();
    setState(() {
      leaguePhoto = temp.data["leaguePhoto"] ?? "";
      leagueID = temp.data["leagueID"] ?? "";
    });

  }

  Future<void> chooseLeaguePic() async {
    String location;
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    StorageUploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child("LeaguePhotos/" + widget.leagueName)
        .putFile(image);
    location = await (await uploadTask.onComplete).ref.getDownloadURL();
    print(await (await uploadTask.onComplete).ref.getDownloadURL());
    await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .updateData(<String,dynamic>{"leaguePhoto": location});
    setState(() {
      leaguePhoto = location ?? "";
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
      backgroundColor: Themes.theme1["CardColor"],
      resizeToAvoidBottomPadding: false,
      body: Container(
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Spacer(),
                Text(
                  'League Settings',
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
              height: 40,
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
            SizedBox(
              height: 40,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: <Widget>[
                  Text(
                    'League Name',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
//                  margin: EdgeInsets.only(left: 20,right: 20),
                    child: Text(widget.leagueName,
                      style: TextStyle(
                        color: Themes.theme1["TextColor"],
                        fontFamily: "Arial",
                        fontSize: 18,
                      ),

                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: <Widget>[
                  Text(
                    'League ID        ',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
//                  margin: EdgeInsets.only(left: 20,right: 20),
                    child: TextField(
                      style: TextStyle(
                        color: Themes.theme1["TextColor"],
                        fontFamily: "Arial",
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 14),
                        hintText: leagueID,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        filled: true,
                        fillColor: Themes.theme1["TextFieldFillColor"],
                        hintStyle: CustomTextStyles.regularText,
                      ),
                      controller: idController,
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: RaisedGradientButton(
                child: Text(
                  'Update League Info',
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
                onPressed: () async{
                  Map<String,dynamic> map = <String,dynamic>{};
                  if (idController.text.trim().length > 0){
                      map["leagueID"] = idController.text;
                      await Firestore.instance
                          .collection("Leagues")
                          .document(widget.leagueName)
                          .updateData(map);
                  }
                  setState(() {
                    leagueID = idController.text;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
