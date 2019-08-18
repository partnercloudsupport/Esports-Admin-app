import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './././databaseOperations/Backend.dart';
import 'colors.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utilities.dart';
import 'dashboard.dart';

class ExistingLogin extends StatefulWidget {
  final String leagueID;
  ExistingLogin(this.leagueID);
  @override
  State<StatefulWidget> createState() {
    return ExistingLoginView(leagueID);
  }
}

class ExistingLoginView extends State<ExistingLogin> with TickerProviderStateMixin {
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userPic = '';
  FirebaseUser currentUser;
  final String leagueID;
  ExistingLoginView(this.leagueID);
  var emailController = TextEditingController(text: '');
  var passwordController = TextEditingController(text: '');
  var forgotPasswordController = TextEditingController(text: '');
  final GoogleSignIn googleSignIn = GoogleSignIn();

  var _logging_in = false;
  var loginButtonPressed = false;
  final utilities = Utilities();

  AnimationController controller;
  Animation<double> animation;

  bool validateForm() {
    emailFormKey.currentState.validate();
    passwordFormKey.currentState.validate();
    return emailFormKey.currentState.validate() &&
        passwordFormKey.currentState.validate();
  }

  Future <String> getLeagueIdOfUser(String emailID) async{
    var leagues = await Firestore.instance.collection('Leagues').getDocuments();
    // Filtering league by parent
    for(var i =0;i<leagues.documents.length;i++){
      var parentData = await Firestore.instance.collection('Leagues').document(leagues.documents[i].documentID).collection('Parents').getDocuments();
      // Filtering parents by emailID
      var parent = parentData.documents.firstWhere((data)=>data.documentID == emailID.replaceAll('.', '-'),orElse:(){return null;});
      if (parent != null){
        var leagueData = await Firestore.instance.collection('Leagues').document(leagues.documents[i].documentID).get();
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString('LeagueID', leagueData.data['leagueID']);
        return leagueData.data['leagueID'];
      }
    }
    return null;

  }

//  void initiateFacebookLogin() async {
//    var facebookLogin = FacebookLogin();
//    var facebookLoginResult =
//    await facebookLogin.logInWithReadPermissions(['email']);
//    switch (facebookLoginResult.status) {
//      case FacebookLoginStatus.error:
//        print('Error');
//        break;
//      case FacebookLoginStatus.cancelledByUser:
//        print('CancelledByUser');
//        break;
//      case FacebookLoginStatus.loggedIn:
//        print('LoggedIn');
//
//        final token = facebookLoginResult.accessToken.token;
//        final graphResponse = await http.get(
//            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${token}',headers: {'accept':'application/json'});
//        final profile = json.decode(graphResponse.body);
//        if (profile['email'] == null || profile['email'] == '') {
//          showDialog(
//              context: context,
//              builder: (BuildContext context) {
//                return AlertDialog(
//                  backgroundColor: Themes.theme1['CardColor'],
//                  title: Text(
//                    'No email found',
//                    style: TextStyle(
//                      color: Themes.theme1['TextColor'],
//                    ),
//                  ),
//                  content: Text(
//                    'We need email to work. Please try another method',
//                    style: TextStyle(
//                      color: Themes.theme1['TextColor'],
//                    ),
//                  ),
//                  actions: <Widget>[
//                    IconButton(
//                      icon: Icon(Icons.done),
//                      color: Themes.theme1['TextColor'],
//                      onPressed: () {
//                        Navigator.pop(context);
//                        return;
//                      },
//                    )
//                  ],
//                );
//              });
//        } else {
//          if (!(await Backend.checkIfUserExistsInDatabase(
//              profile['email'], this.leagueID))) {
//            Backend.makeAnEntryInFirestore(profile['email'], leagueID,profile['first_name']+' '+profile['last_name'],(profile['picture'] ?? ''));
//          }
//          utilities.logEvent('dashboard_via_fb');
//          Navigator.push(
//              context,
//              MaterialPageRoute(
//                  builder: (BuildContext context) => Dashboard(Backend.getLeagueNameFromLeagueID(leagueID),profile['email'])));
//          break;
//        }
//    }
//  }

  Future<void> login(String email, String password) async {
    String leagueID = await getLeagueIdOfUser(email);
    var leagueName = await Backend.getLeagueNameFromLeagueID(leagueID);
    if(leagueID != null){
      Backend.login(email, password).then((value) {
        String title;
        String description;
        _logging_in = false;
        loginButtonPressed = false;
        if (value == null) {
          utilities.logEvent('dashboard');
          Navigator.push<Object>(context,
              MaterialPageRoute<Dashboard>(
                  builder: (BuildContext context) => Dashboard()));
        } else {
          if (value.contains('ERROR_USER_NOT_FOUND')) {
            title = 'Incorrect Username/Password';
            description = 'Please try again.';
          } else if (value.contains('ERROR_INVALID_EMAIL')) {
            title = 'Email is invalid';
            description = '';
          } else if (value.contains('ERROR_WRONG_PASSWORD')) {
            title = 'Incorrect Username/Password';
            description = 'Please try again.';
          } else {
            print(value);
            title = 'Some Error Occured';
            description = '';
          }
          showDialog<AlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return Utilities.alert(title, description, context);
              });
        }
      });
    }

  }

  Future<String> useGoogle() async {
//    try{
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    if (googleUser == null){
      return 'Failed';
    }
    var emailID = googleUser.email;
    String leagueID = await getLeagueIdOfUser(emailID);
    var leagueName = await Backend.getLeagueNameFromLeagueID(leagueID);
    if(leagueID != null){
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

      final FirebaseUser user = await auth.signInWithCredential(credential);

      this.currentUser = await auth.currentUser();


      if (!(await Backend.checkIfUserExistsInDatabase(
          currentUser.email, leagueID))) {
        Backend.makeAnEntryInFirestore(currentUser.email, leagueID,currentUser.displayName,currentUser.photoUrl ?? '');
      }
      utilities.logEvent('direct_login_via_google');
      Navigator.push<Object>(

          context,
          MaterialPageRoute<Dashboard>(

              builder: (BuildContext context) => Dashboard()));

      return 'Done';
    }



  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this,duration: Duration(seconds: 1));
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
    logInIfTokenIsValid();
  }

  Future<void> logInIfTokenIsValid() async{
    var prefs = await SharedPreferences.getInstance();
    String leagueID = await prefs.get('LeagueID');
    var leagueName = await Backend.getLeagueNameFromLeagueID(leagueID);

    var currentUser = await FirebaseAuth.instance.currentUser();
    if(currentUser != null){
      var email = currentUser.email;
      if (!(await Backend.checkIfUserExistsInDatabase(
          email, this.leagueID))) {
        Backend.makeAnEntryInFirestore(email, leagueID,currentUser.displayName,(currentUser.photoUrl ?? ''));
      }
      utilities.logEvent('dashboard_via_firebase');
      Navigator.push<Object>(
          context,
          MaterialPageRoute<Dashboard>(
              builder: (BuildContext context) =>Dashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: ModalProgressHUD(
            inAsyncCall: _logging_in,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Themes.theme1['CardColor'],
                  ),
                  child: Container(
                    margin: EdgeInsets.only(
                        top: 40, left: 20, right: 20, bottom: 40),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50),side:BorderSide(color: Themes.theme1['HighLightColor']) ),
                      color: Themes.theme1['CardColor'],
                      child: FadeTransition(opacity: animation,child:



                      ListView(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 40),
                            child: Form(
                              key: emailFormKey,
                              child: TextFormField(
                                controller: emailController,
                                style: TextStyle(
                                  color: Themes.theme1['TextColor'],
                                  fontFamily: 'Arial',
                                  fontSize: 18,
                                ),
                                decoration: InputDecoration(
                                    errorStyle: TextStyle(fontSize: 14),
                                    hintText: 'Email ID',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),filled: true, fillColor: Themes.theme1['TextFieldFillColor'],
                                    hintStyle: CustomTextStyles.regularText,
                                    suffixIcon: Icon(
                                      Icons.search,
                                      color: Themes.theme1['TextColor'],
                                    )),
                                autovalidate: false,
                                validator: (String emailID) {
                                  if (emailID.isEmpty) {
                                    return 'Please enter your email id.';
                                  } else if (RegExp(
                                      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                                      .hasMatch(emailID) ==
                                      false) {
                                    return 'Entered email is not valid';
                                  }
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 40),
                              child: Form(
                                key: passwordFormKey,
                                child: TextFormField(
                                  controller: passwordController,
                                  style: TextStyle(
                                      color: Themes.theme1['TextColor'],
                                      fontFamily: 'Arial',
                                      fontSize: 18),
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      errorStyle: TextStyle(fontSize: 14),
                                      hintText: 'Password',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),filled: true, fillColor: Themes.theme1['TextFieldFillColor'],
                                      hintStyle: CustomTextStyles.regularText,
                                      suffixIcon: Icon(
                                        Icons.search,
                                        color: Themes.theme1['TextColor'],
                                      )),
                                  autovalidate: false,
                                  validator: (String value) {
                                    print(value);
                                    if (value.length < 8) {
                                      return 'Password should be greater than 8';
                                    }
                                  },
                                ),
                              )),
                          Container(
                            margin: EdgeInsets.only(
                                top: 40, bottom: 10, left: 40, right: 40),

                            child: Container(

                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 30),
                              child: RaisedGradientButton(
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Arial',
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                gradient: LinearGradient(colors: [
                                  Themes.theme1['FirstGradientColor'],
                                  Themes.theme1['SecondGradientColor']
                                ]),
                                onPressed: () {
                                  if (!loginButtonPressed) {
                                    if (validateForm()) {
                                      _logging_in = true;
                                      loginButtonPressed = true;

                                      this.login(
                                          emailController.text.toLowerCase(),
                                          passwordController.text);
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: 10, bottom: 10, left: 40, right: 40),

                            child: Container(

                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 30),
                              child: RaisedGradientButton(
                                child: Text(
                                  'Google',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Arial',
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                gradient: LinearGradient(colors: [
                                  Themes.theme1['FirstGradientColor'],
                                  Themes.theme1['SecondGradientColor']
                                ]),
                                onPressed: () {
                                  try {
                                    useGoogle();
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                            ),
                          ),
//                          Container(
//                            margin: EdgeInsets.only(
//                                top: 10, bottom: 10, left: 40, right: 40),
//
//                            child: Container(
//
//                              margin: EdgeInsets.symmetric(
//                                  vertical: 0, horizontal: 30),
//                              child: RaisedGradientButton(
//                                child: Text(
//                                  'Facebook',
//                                  style: TextStyle(
//                                      color: Colors.white,
//                                      fontFamily: 'Arial',
//                                      letterSpacing: 2,
//                                      fontWeight: FontWeight.bold,
//                                      fontSize: 20),
//                                ),
//                                gradient: LinearGradient(colors: [
//                                  Themes.theme1['FirstGradientColor'],
//                                  Themes.theme1['SecondGradientColor']
//                                ]),
//                                onPressed: () {
//                                  initiateFacebookLogin();
//                                },
//                              ),
//                            ),
//                          )

                          Container(
                            margin: EdgeInsets.only(top: 10,left: 40,right: 40),

                            child: FlatButton(
                                child: Text(
                                  'Forgot Password?',
                                  style: CustomTextStyles.regularText,
                                ),
                                onPressed: () {
                                  showDialog<AlertDialog>(context: context,builder: (BuildContext context){
                                    forgotPasswordController.text = '';
                                    return AlertDialog(

                                      backgroundColor:
                                      Themes.theme1['CardColor'],

                                      title: TextField(
                                        controller:forgotPasswordController,style: TextStyle(
                                        color: Themes.theme1['TextColor'],),decoration: InputDecoration(hintText: 'Email ID',hintStyle:TextStyle(
                                        color: Themes.theme1['TextColor'],) ),),actions: <Widget>[IconButton(icon: Icon(Icons.done,color: Themes.theme1['TextColor'],),onPressed: (){
                                      if(forgotPasswordController.text.trim() == ''){
                                        Navigator.pop(context);
                                      }
                                      else{
                                        FirebaseAuth auth = FirebaseAuth.instance;
                                        auth.sendPasswordResetEmail(email: forgotPasswordController.text);
                                        Navigator.pop(context);
                                      }


                                    },)],);
                                  });
                                }),
                          )
                        ],
                      ),) ,
                    ),
                  ),
                ),
              ),
            ),
          )),
      onWillPop: () {
        return new Future(() => true);
      },
    );
  }
}


