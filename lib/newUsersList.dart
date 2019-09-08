import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RolesEnum.dart';
import 'colors.dart';
import 'newUsersCheckBoxes.dart';

class NewUsersList extends StatefulWidget {
  const NewUsersList(this.leagueName);
  final String leagueName;
  @override
  State<StatefulWidget> createState() {
    return NewUsersListState();
  }
}

class NewUsersListState extends State<NewUsersList> {





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.theme1['CardColor'],
      appBar: AppBar(
        title: const Text('New Users'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        child: FutureBuilder<QuerySnapshot>(
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == null) {
                return const Text('No data',style: TextStyle(color: Colors.white),);
              }
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: Colors.white,
                      child: FlatButton(
                        child: Text(
                          snapshot.data.documents[index].documentID.replaceAll('-', '.'),
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: 18),
                        ),onPressed: (){
                         Navigator.push(context, MaterialPageRoute<NewUsersChecks>(builder: (BuildContext context){
                           return  NewUsersChecks(widget.leagueName,snapshot.data.documents[index].documentID.replaceAll('-', '.'));
                         }));
                      },
                      ),
                    );
                  });
            }
            return Center(
              child: const CircularProgressIndicator(),
            );
          },
          future: Firestore.instance
              .collection('Leagues')
              .document(widget.leagueName)
              .collection('New Users')
              .getDocuments(),
        ),
      ),
    );
  }
}
