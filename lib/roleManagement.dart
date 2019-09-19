import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'updateRole.dart';

class RoleManagement extends StatefulWidget {
  const RoleManagement(this.leagueName);
  final String leagueName;
  @override
  State<StatefulWidget> createState() {
    return RoleManagementState();
  }
}

class RoleManagementState extends State<RoleManagement> {
  QuerySnapshot admins;
  List<Map<String, dynamic>> users = <Map<String, dynamic>>[];
  bool isLoading = false;
  Future<void> getAdmins() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    admins = await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .collection('Admins')
        .getDocuments();
    admins.documents.removeWhere((doc) {
      if (doc.documentID == user.email.replaceAll('.', '-')) {
        return true;
      }
      return false;
    });
    for (DocumentSnapshot eachAdmin in admins.documents) {
      final DocumentSnapshot userData = await Firestore.instance
          .collection('Users')
          .document(eachAdmin.documentID)
          .get();
      users.add(userData.data);
    }
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    getAdmins().whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: Scaffold(
        body: adminTab(),
        appBar: AppBar(
          backgroundColor: Colors.orange,
        ),
        backgroundColor: Themes.theme1['CardColor'],
      ),
      inAsyncCall: isLoading,
    );
  }

  Widget adminTab() {
    if (users == null) {
      return const Text('');
    }
    return ListView.builder(
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          final String name = users[index]['gamerTag'] ?? 'Anonymous';
          final String url = users[index]['profileImage'] ??
              'https://firebasestorage.googleapis.com/v0/b/league2-33117.appspot.com/o/logo.png?alt=media&token=8a8b3791-7676-485a-a800-959d4a1b0325';
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: FlatButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute<UpdateRole>(
                      builder: (BuildContext context) {
                    return UpdateRole(
                        widget.leagueName, admins.documents[index].documentID);
                  }));
                },
                child: ListTile(
                  leading: ClipRRect(
                    child: FadeInImage.assetNetwork(
                        placeholder: 'images/logo.png', image: url,),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 18),
                  ),
                )),
          );
        });
  }
}
