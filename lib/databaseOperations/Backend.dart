import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_revamp/utilities.dart';

class Backend {
  static List<DocumentSnapshot> leagues = <DocumentSnapshot>[];
  static Utilities utils = Utilities();

  static Future<String> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return '';
    } catch (e) {
      utils.logEvent('Log out error');
      utils.logEvent(e.toString());
      return e.toString();
    }
  }

  static Future<String> signUp(String email, String password, String league,
      bool president) async {
    utils.logEvent('Sign up');
    try {
      final FirebaseUser firebaseUser = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      sendEmail(email, league);
      if (president) {
        await Firestore.instance.collection('Leagues').document(league).setData(
            <String, dynamic>{
              'President': {
                'id': email.replaceAll('.', '-'),
                'name': 'Anonymous',
                'picture': ''
              }
            });
      }
      else {
        await Firestore.instance.collection('Leagues').document(league)
            .collection('Admins').document(email.replaceAll('.', '-'))
            .setData(<String, String>{
          'id': email.replaceAll('.', '-'),
          'name': 'Anonymous',
          'picture': ''
        });
      }
      return firebaseUser.toString();
    } catch (e) {
      utils.logEvent(e.toString());
      return e.toString();
    }
  }

  static Future<void> sendEmail(String to, String league) async {
    utils.logEvent('sendEmail');
    const String username = 'salutations@ironbearapps.com';
    const String password = 'Ironbear321!';
    final SmtpServer smtpServer = SmtpServer(
        'smtp.office365.com', username: username, password: password);

    final Message message = Message();
    message.from = Address('salutations@ironbearapps.com', 'Iron Bear Sports');
    message.recipients = <String>[to];
    message.bccRecipients = <String>['salutations@ironbearapps.com'];
    message.subject = 'Welcome';
    message.text = 'Your league is created with name $league .';
    message.html =
    '<h1>Test</h1><p>Your league is created with name $league .</p>';
    final List<SendReport> sendReports = await send(
        message, smtpServer, timeout: Duration(seconds: 15));
    for (SendReport report in sendReports) {
      if (report.sent) {
        utils.logEvent('Mail Sent');
      }
      else {
        utils.logEvent('Mail Failed');
        for (var p in report.validationProblems) {
          utils.logEvent('Problem: ${p.code}: ${p.msg}');
        }
      }
    }
  }

  static Future<void> uploadImage() async {
    String location;
    final File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    final String emailID = await getEmailID();

    final StorageUploadTask uploadTask = FirebaseStorage.instance.ref().child(
        emailID).putFile(image);
    location = await (await uploadTask.onComplete).ref.getDownloadURL();
    print(await (await uploadTask.onComplete).ref.getDownloadURL());

    final DocumentReference parent = Firestore.instance.collection('Parent')
        .document(emailID.replaceAll('.', '-'));
    final DocumentSnapshot getParentData = await parent.get();

    getParentData.data['image'] = location;
    parent.setData(getParentData.data);
  }

  static Future<String> getEmailID() async {
    String userEmail;
    await FirebaseAuth.instance.currentUser().then((value) {
      userEmail = value.email ?? '';
    });
    return userEmail;
  }

  static String checkLeagueID(String leagueID) {
    try {
      leagues.firstWhere((document) => document.data['leagueID'] == leagueID);
      return 'League already exists';
    }
    catch (e) {
      return '';
    }
  }

  static String checkLeagueName(String leagueName) {
    print('checkLeagueName');

    try {
      print(leagues);
      for (DocumentSnapshot each in leagues) {
        print(each.documentID);
      }
      leagues.firstWhere((DocumentSnapshot document) =>
      document.documentID == leagueName);
      return 'League already exists';
    }
    catch (e) {
      return '';
    }
  }


  static Future<bool> checkIfUserExistsInDatabase(String emailID,
      String leagueID) async {
    final String leagueName = await getLeagueNameFromLeagueID(leagueID);

    try {
      final dynamic parent = fetchAdminCollection(leagueName, emailID);
      return (await parent) != null;
    }
    catch (e) {
      return false;
    }
  }


  static Future<String> getLeagueNameFromLeagueID(String leagueID) async {
    DocumentSnapshot league;

    await readLeagueData();
    try {
      league = leagues.firstWhere((document) => document.data['leagueID'] ==
          leagueID);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(Utilities.LEAGUE_NAME, league.documentID.toString());
      return league.documentID.toString();
    }
    catch (e) {
      return '';
    }
  }

  static Future<Map<String, dynamic>> fetchParentCollection(String leagueName,
      String emailID) async {
    final DocumentSnapshot parentCollection = await Firestore.instance
        .collection('Leagues')
        .document(leagueName).collection('Parents').document(
        emailID.replaceAll('.', '-'))
        .get();
    return parentCollection.data;
  }

  static Future<void> readLeagueData() async {
    print('readLeagueData');
    QuerySnapshot tempDocRef;
    try {
      tempDocRef =
      await Firestore.instance.collection('Leagues').getDocuments();
      print(tempDocRef.documents);
    }
    catch (e) {
      print(e);
    }
    Backend.leagues = tempDocRef.documents;
  }

  static Future<Map<String, dynamic>> fetchAdminCollection(String leagueName,
      String emailID) async {
    final DocumentSnapshot adminCollection = await Firestore.instance
        .collection('Leagues')
        .document(leagueName).collection('Admins').document(
        emailID.replaceAll('.', '-'))
        .get();
    print(adminCollection.data);
    return adminCollection.data;
  }


  static Future<String> checkIfUserExists(String email) async {
    for (int i = 0; i < leagues.length; i++) {
      final String documentID = leagues[i].documentID;

      final QuerySnapshot data = await Firestore.instance.collection('Leagues')
          .document(documentID).collection('Parents')
          .getDocuments();

      for (int k = 0; k < data.documents.length; k++) {
        if (data.documents[k].documentID.replaceAll('.', '-') ==
            email.replaceAll('.', '-')) {
          sendLeagueIDEmail(email, leagues[i].data['leagueID']);
          return 'User exists';
        }
      }
      return 'User does not exists';
    }
    return '';
  }

  static Future<void> sendLeagueIDEmail(String email, String leagueID) async {
    const String username = 'salutations@ironbearapps.com';
    const String password = 'Ironbear321!';
    final SmtpServer smtpServer = SmtpServer(
        'smtp.office365.com', username: username, password: password);

    final Message message = Message();
    message.from = Address('salutations@ironbearapps.com', 'Iron Bear Sports');
    message.recipients = <String>[email];
    message.bccRecipients = <String>['salutations@ironbearapps.com'];
    message.ccRecipients = <String>[];
    message.subject = 'Welcome';
    message.text = 'Please find your league id.';
    message.html = '<h1>Test</h1><p>Your league id is $leagueID .</p>';
    final List<SendReport> sendReports = await send(
        message, smtpServer, timeout: Duration(seconds: 15));
    for (SendReport report in sendReports) {
      if (report.sent) {
        utils.logEvent('Mail sent');
      } else {
        utils.logEvent('Mail Failed');
        for (var p in report.validationProblems) {
          utils.logEvent('Problem: ${p.code}: ${p.msg}');
        }
      }
    }
  }

  static Future<String> login(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
    return '';
  }

  static Future<void> makeAnEntryInFirestore(String emailID, String leagueID,
      [String leagueNameProvided, String name, String userPic]) async {
    String leagueName = '';
    if (leagueNameProvided != null || leagueNameProvided != '') {
      leagueName = leagueNameProvided;
    }
    else {
      leagueName = await getLeagueNameFromLeagueID(leagueID);
    }
    try {
      Map<String, dynamic> map = <String, dynamic>{
        'id': emailID.replaceAll('.', '-'),
        'name': name,
        'picture': userPic
      };

      Firestore.instance.collection('Leagues').document(leagueName).collection(
          'Admins').document(emailID.replaceAll('.', '-')).setData(map);
    }
    catch (e) {
      print(e);
    }
  }

  static Future<String> createLeagueID(String leagueName) async {
    if (leagueName == null || leagueName.length < 3) {
      return 'League name should be atleast 3 characters long';
    }
    final List<String> words = leagueName.split(' ');
    String leagueID = '';
    for (int i = 0; i < words.length; i++) {
      words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      leagueID = leagueID + words[i];
    }

    final Random random = Random();
    final int randomNumber = 100 + random.nextInt(1000 - 100);
    leagueID = leagueID + '$randomNumber';

    if (Backend.checkLeagueID(leagueID) == 'League already exists') {
      return Backend.createLeagueID(leagueName);
    }

    return leagueID;
  }
}
