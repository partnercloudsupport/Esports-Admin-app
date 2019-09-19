import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'colors.dart';
import 'editGamerTag.dart';
import 'leagueInfoPage.dart';
import 'models/FetchLeague.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;
  String profileImage =
      'https://firebasestorage.googleapis.com/v0/b/league2-33117.appspot.com/o/logo.png?alt=media&token=8a8b3791-7676-485a-a800-959d4a1b0325';
  String gamerTag = 'Anonymous';
  String email = '';
  String phone = '';

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final DocumentSnapshot usersData = await Firestore.instance
        .collection('Users')
        .document(user.email.replaceAll('.', '-'))
        .get();
    email = user.email;
    if (usersData.data['gamerTag'] != null) {
      gamerTag = usersData.data['gamerTag'].toString();
    }
    if (usersData.data['profileImage'] != null) {
      profileImage = usersData.data['profileImage'].toString();
    }

    if (usersData.data['phone'] != null) {
      phone = usersData.data['phone'].toString();
    }
  }

  void refresh() {
    setState(() {
      fetchData().whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  @override
  void initState() {
    fetchData().whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  Future<void> updateData() async {
    setState(() {
      isLoading = true;
    });
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final DocumentSnapshot usersData = await Firestore.instance
        .collection('Users')
        .document(user.email.replaceAll('.', '-'))
        .get();
    usersData.data['gamerTag'] = gamerTag;
    usersData.data['profileImage'] = profileImage;
    usersData.data['phone'] = phone;
    await Firestore.instance
        .collection('Users')
        .document(user.email.replaceAll('.', '-'))
        .updateData(usersData.data);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> chooseProfilePic() async {
    try {
      String location;
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      final String username = user.email.replaceAll('.', '-');
      final File image =
          await ImagePicker.pickImage(source: ImageSource.gallery);

      final StorageUploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('UserPhotos/' + username)
          .putFile(image);
      location = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(await (await uploadTask.onComplete).ref.getDownloadURL());
      await Firestore.instance
          .collection('Users')
          .document(username)
          .updateData(<String, dynamic>{'profileImage': location});
      setState(() {
        profileImage = location ?? '';
      });
    } catch (e) {
      print(e);
    }
  }

  Widget profile() {
    return Container(
      color: Themes.theme1['CardColor'],
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
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
                      child: Image.network(
                        profileImage,
                        fit: BoxFit.fill,
                      ),
                      color: Colors.deepPurple,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(120)),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  chooseProfilePic().whenComplete(() {
                    setState(() {
                      isLoading = false;
                    });
                  });
                },
              ),
              Spacer(),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Row(
              children: <Widget>[
                Spacer(),
                Text(
                  gamerTag,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    final FirebaseUser user =
                        await FirebaseAuth.instance.currentUser();

                    Navigator.push(context, MaterialPageRoute<EditGamerTag>(
                        builder: (BuildContext context) {
                      return EditGamerTag(
                          gamerTag, user.email.replaceAll('.', '-'), refresh);
                    }));
                  },
                ),
                Spacer(),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            child: Row(
              children: <Widget>[
                Spacer(),
                Text(
                  'Email:',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Poppins', fontSize: 18),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  email,
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Poppins', fontSize: 18),
                ),
                Spacer()
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<http.Response> fetchLeaguesData() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();

    final String email = user.email.replaceAll('.', '-');
    print(email);
    return http.Client().get(
        'https://us-central1-league2-33117.cloudfunctions.net/readAllLeagues?email=$email');
  }

  String roleString(bool admin, bool coach) {
    if (admin && coach) {
      return 'Admin & Coach';
    } else if (admin) {
      return 'Admin';
    } else if (coach) {
      return 'Coach';
    }
    return '';
  }

  Widget leadingWidget(bool president) {
    if (president) {
      return Container(
        child: Image.asset('images/crown.png'),
      );
    }
    return const Text('');
  }


  Widget league() {
    return Scaffold(
        backgroundColor: Themes.theme1['CardColor'],
        body: ModalProgressHUD(
            inAsyncCall: isLoading,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                const SizedBox(
                  height: 40,
                ),
                FutureBuilder<http.Response>(
                  future: fetchLeaguesData(),
                  builder: (BuildContext context,
                      AsyncSnapshot<http.Response> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done ||
                        snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.data == null) {
                        return CupertinoAlertDialog(
                          title: const Text('Some error occurred'),
                          content: const Text(
                              'Data fetching failed. Please try again.'),
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
                      }
                      if (snapshot.data.statusCode != 200) {
                        if (Platform.isIOS) {
                          showCupertinoDialog<CupertinoAlertDialog>(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title: const Text('Some error occurred'),
                                  content: const Text(
                                      'Data fetching failed. Please try again.'),
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
                                  title: const Text('Some error occurred'),
                                  content: const Text(
                                      'Data fetching failed. Please try again.'),
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
                      } else if (snapshot.data.body != '[]') {
                        final FetchLeagues leagues =
                        FetchLeagues.fromJson(snapshot.data.body);
                        return Container(
                          constraints: BoxConstraints(
                              maxHeight:
                              MediaQuery.of(context).size.height * 0.9,
                              minHeight: 200),
                          child: ListView.builder(
                            itemCount: leagues.leagues.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              String roles = roleString(
                                  leagues.leagues[index].admin.toString() ==
                                      'true',
                                  leagues.leagues[index].coach.toString() ==
                                      'true');
                              return FlatButton(
                                child: ListTile(
                                  trailing: leadingWidget(leagues
                                      .leagues[index].president
                                      .toString() ==
                                      'true'),
                                  leading: ClipRRect(
                                    child: Container(
                                      height: 50,width: 50,
                                      child: FadeInImage.assetNetwork(fit: BoxFit.fill,
                                          placeholder: 'images/logo.png',
                                          image: leagues
                                              .leagues[index].leaguePhoto ??
                                              'https://firebasestorage.googleapis.com/v0/b/league2-33117.appspot.com/o/logo.png?alt=media&token=8a8b3791-7676-485a-a800-959d4a1b0325'),
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  subtitle: Container(
                                    child: Text(
                                      roles,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins'),
                                    ),
                                  ),
                                  title: Text(leagues.leagues[index].leagueName,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins')),
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute<LeagueInfoPage>(builder: (BuildContext context){
                                    return LeagueInfoPage(leagues.leagues[index].leagueName);
                                  }));
                                },
                              );
                            },
                          ),
                        );
                      }
                      return Column(
                        children: <Widget>[
                          Container(
                            child: Image.asset('images/emptyBox.png'),
                          ),
                          Text(
                            'No Leagues',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 18),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: const CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                             ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.orange,
              bottom: TabBar(tabs: [
                Container(
                  child: Text(
                    'Profile',
                    style: TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                  ),
                  height: 40,
                ),
                Container(
                  child: Text(
                    'Leagues',
                    style: TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                  ),
                  height: 40,
                )
              ]),
            ),
            body: TabBarView(children: [profile(), league()])));
  }
}
