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
  bool isLoading = false;
  Future<void> getAdmins() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    admins = await Firestore.instance
        .collection('Leagues')
        .document(widget.leagueName)
        .collection('Admins')
        .getDocuments();
    admins.documents.removeWhere((doc){
      if(doc.documentID == user.email.replaceAll('.', '-')){
        return true;
      }
      return false;
    });
    print(admins.documents.first.data);
    print(widget.leagueName);
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
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Themes.theme1['CardColor'],
            appBar: AppBar(
              backgroundColor: Colors.orange,
              title: const Text('Role Management'),
              bottom: const TabBar(tabs: [
                Tab(
                  text: 'Admin',
                ),
                Tab(
                  text: 'Coach',
                )
              ]),
            ),
            body: TabBarView(children: [adminTab(), const Text('Coach')]),
          )),
      inAsyncCall: isLoading,
    );
  }

  Widget adminTab() {
    if (admins == null) {
      return const Text('');
    }
    return ListView.builder(
        itemCount: admins.documents.length,
        itemBuilder: (BuildContext context, int index) {
          final String name = admins.documents[index]['name'] ?? 'Anonymous';
          final String url = admins.documents[index]['picture'] ??
              'https://firebasestorage.googleapis.com/v0/b/league2-33117.appspot.com/o/logo.png?alt=media&token=8a8b3791-7676-485a-a800-959d4a1b0325';
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child:FlatButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute<UpdateRole>(builder: (BuildContext context){
                return UpdateRole(widget.leagueName , admins.documents[index].documentID);
              }));
            }, child:  ListTile(
              leading: ClipRRect(
                child: FadeInImage.assetNetwork(
                    placeholder: 'images/logo.png', image: url),
                borderRadius: BorderRadius.circular(100),
              ),
              title: Text(
                name,
                style: TextStyle(
                    color: Colors.black, fontFamily: 'Poppins', fontSize: 18),
              ),
            )),
          );
        });
  }
}
