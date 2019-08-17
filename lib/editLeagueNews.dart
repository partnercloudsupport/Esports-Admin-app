import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'colors.dart';
import 'utilities.dart';

class EditLeagueNews extends StatefulWidget {
  final String leagueName;
  final List<dynamic> newsArray;
  final String changedNews;
  final int index;
  EditLeagueNews(this.leagueName,this.newsArray,this.changedNews,this.index);

  @override
  State<StatefulWidget> createState() {
    return EditLeagueNewsState();
  }
}

class EditLeagueNewsState extends State<EditLeagueNews> {

  var formKey = GlobalKey<FormState>();
  var newsController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Themes.theme1['CardColor'],
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 40),
            child: Text(
              'Edit League News',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          Container(
            child: Container(
              height: 400,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Utilities.cornerRadius),
                    side: BorderSide(
                        color: Themes.theme1['HighLightColor'], width: 2)),
                color: Themes.theme1['CardColor'],
                margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Form(

                  key: formKey,
                  child: ListView(
                    children: <Widget>[
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                        height: 60,
                        child: TextFormField(
                            style: CustomTextStyles.regularText,
                            controller: newsController,
                            onSaved: (value) {
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                                filled: true,
                                fillColor: Themes.theme1['TextFieldFillColor'],
                                labelText: widget.changedNews,
                                labelStyle: TextStyle(
                                    color:
                                    Themes.theme1['TextPlaceholderColor'],
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                                errorStyle: TextStyle(fontSize: 14)),
                            autovalidate: false,
                            validator: (String news) {
                              if (news.trim().isEmpty) {
                                return 'News cant be empty.';
                              }
                            }),
                        margin: EdgeInsets.only(left: 40, right: 40),
                      ),
                      Container(
                        height: 60,
                      ),
                      Container(
                        height: 50,
                        margin: EdgeInsets.only(top: 20, left: 40, right: 40),
                        child: RaisedGradientButton(
                            child: Text(
                              'Edit News',
                              style: CustomTextStyles.boldLargeText,
                            ),
                            gradient: LinearGradient(colors: [
                              Themes.theme1['FirstGradientColor'],
                              Themes.theme1['SecondGradientColor']
                            ]),
                            onPressed: () {
                              if (formKey.currentState.validate()) {
                                formKey.currentState.save();
                                print(widget.newsArray);
                                List<dynamic> temp = <dynamic>[];
                                widget.newsArray.forEach((dynamic each) => temp.add(each));
                                temp[widget.index] = newsController.text;
                                Firestore.instance.collection('Leagues').document(widget.leagueName).collection('League News').document('News').setData(<String,dynamic>{'News':temp}).then((vlaue){
                                  Navigator.pop(context);
                                });
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
