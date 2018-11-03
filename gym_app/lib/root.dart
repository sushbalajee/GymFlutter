import 'package:flutter/material.dart';
import 'dart:async';
import 'auth.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'personalisedWorkouts.dart';
import 'usersList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'color_loader_3.dart';
import 'package:flutter/services.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => RootPageState();
}

enum AuthStatus { notSignedIn, signedIn, signedInAsPT, notDetermined }

class RootPageState extends State<RootPage> {
  RootPageState({this.auth, this.onSignedOut});

  final BaseAuth auth;
  final VoidCallback onSignedOut;

  List<String> userIds;

  bool typeOfUser;

  String uid = "Please sign out and sign in\n to activate your Trainer ID";
  String statusOfUser;
  String relationship = "";

  AuthStatus authStatus = AuthStatus.notDetermined;

  @override
  void initState() {
    super.initState();

    widget.auth.currentUser().then((userId) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      typeOfUser = prefs.getBool('PTcheck');

      if (userId != null) {
        updateUserID();
        setState(() {
          if (typeOfUser == true) {
            authStatus = AuthStatus.signedInAsPT;
            statusOfUser = "You are Logged in as a Personal Trainer";
          } else {
            authStatus =
                userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
            updateRelationship();
          }
        });
      } else {
        setState(() {
          authStatus = AuthStatus.notSignedIn;
        }); //do something?
      }
    });
  }

  Future fetchPost(String userID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response =
        await http.get('https://gymapp-e8453.firebaseio.com/Workouts.json');
    var jsonResponse = json.decode(response.body);

    GetUserId post = new GetUserId.fromJson10(jsonResponse);
    userIds = post.uiCode;

    if (userIds.contains(userID)) {
      await prefs.setBool('PTcheck', true);
      authStatus = AuthStatus.signedInAsPT;
    } else {
      await prefs.setBool('PTcheck', false);
    }
    return userIds;
  }

  void signedIn() {
    updateUserID();
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void signedInAsPT() {
    updateUserID();
    setState(() {
      authStatus = AuthStatus.signedInAsPT;
    });
  }

  void signedOut() async {
    setState(() {
      FirebaseAuth.instance.signOut();
      authStatus = AuthStatus.notSignedIn;
    });
  }

  void updateRelationship() async {
    SharedPreferences relations = await SharedPreferences.getInstance();
    relationship = relations.getString('relationship');
  }

  Future updateUserID() async {
    FirebaseAuth.instance.currentUser().then((userId) {
      if (userId != null) {
        uid = userId.uid;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (authStatus == AuthStatus.notDetermined) {
      updateUserID();
      return new Scaffold(
          resizeToAvoidBottomPadding: false,
          body: new Stack(children: <Widget>[
            Container(
                alignment: Alignment.center,
                child: ColorLoader3(
                  dotRadius: 5.0,
                  radius: 20.0,
                )),
            Container(
                padding: EdgeInsets.only(top: 100.0),
                alignment: Alignment.center,
                child: new Text("... Loading ...",
                    style: new TextStyle(
                        fontSize: 20.0, fontFamily: "Montserrat")))
          ]));
    }

    if (authStatus == AuthStatus.notSignedIn) {
      return new Login(
          auth: widget.auth,
          onSignedIn: signedIn,
          onSignedInAsPt: signedInAsPT);
    }

    if (authStatus == AuthStatus.signedInAsPT) {
      return new Column(children: <Widget>[
         
        Card(
            margin: EdgeInsets.all(15.0),
            shape: Border.all(
                color: Colors.grey[900], width: 4.5, style: BorderStyle.solid),
            child: new Container(
              height: screenHeight / 3,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/personalized.jpeg"),
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.85), BlendMode.dstATop),
                ),
              ),
              width: screenWidth,
              child: FlatButton(
                child: new Text("My Clients",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontSize: 25.0,
                        fontFamily: "Montserrat",
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UIDList(
                                trainerID: uid,
                              )));
                },
              ),
            )),

            Container(
          padding: EdgeInsets.only(left: 20.0, right:20.0),
          child: Text("Send your unique Trainer ID to your clients to enter on registration:", textAlign: TextAlign.left,
          style: TextStyle(
                fontSize: 15.0,
                fontFamily: "Montserrat",
              ),),
        ),
        Container(
          padding: EdgeInsets.only(left: 20.0, right:20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("$uid",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w700
                    )),
                IconButton(
                    icon: new Icon(Icons.content_copy),
                    tooltip: "Copied to clipboard",
                    onPressed: () {
                      Clipboard.setData(new ClipboardData(text: uid));
                    })
              ],
            )),
            Container( 
              padding: EdgeInsets.only(top: 50.0),
              child:
        RaisedButton(
            color: Colors.grey[900],
            child: new Text(
              "Sign Out",
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.white,
                fontFamily: "Montserrat",
              ),
            ),
            onPressed: signedOut,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0))),
      )]);
    }

    if (authStatus == AuthStatus.signedIn) {
      return new Column(children: <Widget>[
        Card(
            margin: EdgeInsets.all(15.0),
            shape: Border.all(
                color: Colors.grey[900], width: 4.5, style: BorderStyle.solid),
            child: new Container(
              height: screenHeight / 3,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/4.jpg"),
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.9), BlendMode.dstATop),
                ),
              ),
              width: screenWidth,
              child: FlatButton(
                child: new Text("Your Personalised Workouts",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontSize: 25.0,
                        fontFamily: "Montserrat",
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WorkoutsListPersonal(
                                value: relationship,
                                userUid: uid,
                              )));
                },
              ),
            )),
        RaisedButton(
            color: Colors.grey[900],
            child: new Text(
              "Sign Out",
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.white,
                fontFamily: "Montserrat",
              ),
            ),
            onPressed: signedOut,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0))),
      ]);
    }
    return null;
  }
}
