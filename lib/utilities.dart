import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'databaseOperations/Backend.dart';
import 'main.dart';
import 'colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:async';
import 'checkLeague.dart';

class Utilities {
  static const String LEAGUE_ID = "leagueID";
  static const String LEAGUE_NAME = "leagueName";


  static String appID = "ca-app-pub-4647236573650320~3783616629";
  static String bannerID = "ca-app-pub-4647236573650320/8765793643";
  static BuildContext context;
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  static double cornerRadius = 40;
  static Timer sessionTimer;

  Future<void> logEvent(String eventName) async{
   await this.analytics.logEvent(name: eventName);
  }
//  static bool isEsports = false;
//  static Ads showBannerAds() {
//    return Ads(Utilities.appID,bannerUnitId: Utilities.bannerID,keywords: ["Baseball","Sports","League","Jersey"]);
//  }
  static AlertDialog alert(String title, String content, BuildContext context) {
    return AlertDialog(
      title: Text(title,style: TextStyle(color: Themes.theme1["TextColor"]),),
      backgroundColor:
      Themes.theme1["CardColor"],
      content: Text(content,style: TextStyle(color: Themes.theme1["TextColor"]),),
      actions: <Widget>[
        FlatButton(
          child: Text('OK',style: TextStyle(color: Themes.theme1["TextColor"])),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
  static void logCrash(String message){
    DiagnosticsNode.message(message);
    FlutterErrorDetails errorDetails = FlutterErrorDetails(context: DiagnosticsNode.message(message));
    Crashlytics.instance.recordFlutterError(errorDetails);
  }

  static CupertinoAlertDialog iosAlert(String title, String content, BuildContext context){
    return CupertinoAlertDialog(title: Text(title),content: Text(content),actions: <Widget>[CupertinoDialogAction(child: Text("OK"),isDefaultAction: true,onPressed: (){
      Navigator.pop(context,"Ok");
    },)],);
  }
//  static Widget home = Container(
//    child: FlatButton(
//      child: Row(
//        children: <Widget>[
//          Text(
//            "Home",
//            textAlign: TextAlign.start,
//            style: TextStyle(fontSize: 25, color: Colors.brown),
//          ),
//        ],
//      ),
//      onPressed: () {
//        Navigator.pushReplacement(context,
//            MaterialPageRoute(builder: (BuildContext context) => Dashboard()));
//      },
//    ),
//  );

  static Widget logout = Container(
    child: FlatButton(
      child: Row(
        children: <Widget>[
          Text(
            "Logout",
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 25, color: Colors.brown),
          ),
        ],
      ),
      onPressed: () {
        Backend.logout().then((value) {
          print(value);
        });
        Navigator.pushReplacement<Object,Object>(context,
            MaterialPageRoute(builder: (BuildContext context) => MyApp()));
      },
    ),
  );


}

class Menu extends StatefulWidget {
  static String name = "";
  static String lastName = "";
  static String emailID = "";

  @override
  State<StatefulWidget> createState() {
    return MenuState();
  }
}

class MenuState extends State<Menu> {
  static String imageURL = 'https://firebasestorage.googleapis.com/v0/b/league2-33117.appspot.com/o/user.jpg?alt=media&token=9cd6e456-2422-48d0-98b5-f5729c226d20';

  String emailID;

  @override
  void initState() {
    print('init');
//    Backend.getImageURL().then((value) {
//      print('ImageURL $value');
//      if(value != null){
//        imageURL = value;
//      }
//    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(imageURL);

    Utilities.context = context;
    return Drawer(
        child: Container(
      height: 300,
      child: ListView(children: selectMenu()),
    ));
  }

  List selectMenu() {
    try {
      List<Widget> menuItems = [
        UserAccountsDrawerHeader(
          accountName: Text(
            Menu.name + " " + Menu.lastName,
            style: TextStyle(fontSize: 20),
          ),
          accountEmail: Text(
            Menu.emailID,
            style: TextStyle(fontSize: 20),
          ),
          currentAccountPicture: SizedBox(height: 120,width: 120,child: OutlineButton(
              onPressed: () {
                Backend.uploadImage();
              },
              child: FadeInImage(image: NetworkImage(imageURL,),
                placeholder: AssetImage('images/user.jpg'),
                fit: BoxFit.fill,)
          ),),
        ),
//        Utilities.home,

      ];

      menuItems.add(Utilities.logout);

      return menuItems;
    }
    catch (e){
      print(e);
    }


  }


}

class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;

  const RaisedGradientButton({
    Key key,
    @required this.child,
    this.gradient,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(

      width: width,
      height: 50.0,
      decoration: BoxDecoration(gradient: gradient, boxShadow: [
        BoxShadow(
          color: Colors.grey[500],
          offset: Offset(0.0, 1.5),
          blurRadius: 1.5,
        ),
      ]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            child: Center(
              child: child,
            )),
      ),
    );
  }
}

class CustomTextStyles{
  static var boldLargeText = TextStyle(
      color: Themes.theme1["TextColor"],fontFamily: 'Poppins',fontWeight: FontWeight.bold, fontSize: 18);

  static var regularText = TextStyle(color: Themes.theme1["TextColor"],fontFamily: 'Poppins',fontWeight: FontWeight.normal, fontSize: 18);
}