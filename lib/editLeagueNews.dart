import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'utilities.dart';

class EditLeagueNews extends StatefulWidget {
  final String leagueName;
  final List<dynamic> newsArray;
  final String changedNews;
  final int index;
  EditLeagueNews(this.leagueName, this.newsArray, this.changedNews, this.index);

  @override
  State<StatefulWidget> createState() {
    return EditLeagueNewsState();
  }
}

class EditLeagueNewsState extends State<EditLeagueNews> {
  var formKey = GlobalKey<FormState>();
  var newsController = TextEditingController(text: '');
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit League News'),
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
                                  hintText: widget.changedNews),
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
                                'Edit News',
                                style: CustomTextStyles.regularText,
                              ),
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                if (formKey.currentState.validate()) {
                                  formKey.currentState.save();
                                  print(widget.newsArray);
                                  final List<dynamic> temp = <dynamic>[];
                                  widget.newsArray.forEach(
                                      (dynamic each) => temp.add(each));
                                  temp[widget.index] = newsController.text;
                                  Firestore.instance
                                      .collection('Leagues')
                                      .document(widget.leagueName)
                                      .collection('League News')
                                      .document('News')
                                      .setData(<String, dynamic>{
                                    'News': temp
                                  }).then((vlaue) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.pop(context);
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
