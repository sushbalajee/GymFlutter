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
import 'ptDiary.dart';
import 'upcomingSessions.dart';

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

  List<String> userIDs;

  bool userType;

  String uid = "Please sign out and sign in\n to activate your Trainer ID";
  String statusOfUser;
  String relationship = "";

  AuthStatus authStatus = AuthStatus.notDetermined;

  @override
  void initState() {
    super.initState();

    widget.auth.currentUser().then((userId) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userType = prefs.getBool('PTcheck');

      if (userId != null) {
        updateUserID();
        setState(() {
          if (userType == true) {
            authStatus = AuthStatus.signedInAsPT;
            statusOfUser = "You are Logged in as a Personal Trainer";
          } else {
            updateRelationship();
            authStatus =
                userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
          }
        });
      } else {
        setState(() {
          authStatus = AuthStatus.notSignedIn;
        });
      }
    });
  }

  Future fetchPost(String userID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response =
        await http.get('https://gymapp-e8453.firebaseio.com/Workouts.json');
    var jsonResponse = json.decode(response.body);

    GetUserId post = new GetUserId.fromJson10(jsonResponse);
    userIDs = post.uiCode;

    if (userIDs.contains(userID)) {
      await prefs.setBool('PTcheck', true);
      authStatus = AuthStatus.signedInAsPT;
    } else {
      await prefs.setBool('PTcheck', false);
    }

    return userIDs;
  }

  void signedIn() {
    updateUserID();
    updateRelationship();
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

//------------------------------------------------------------------------------//

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
                child: new Text("Loading",
                    style: new TextStyle(
                        fontSize: 20.0, fontFamily: "Montserrat")))
          ]));
    }

//------------------------------------------------------------------------------//

    if (authStatus == AuthStatus.notSignedIn) {
      return new Login(
          auth: widget.auth,
          onSignedIn: signedIn,
          onSignedInAsPt: signedInAsPT);
    }

//------------------------------------------------------------------------------//

    if (authStatus == AuthStatus.signedInAsPT) {
      return new Column(children: <Widget>[
        Card(
            margin: EdgeInsets.all(15.0),
            shape: Border.all(
                color: Color(0xFF4A657A), width: 1.5, style: BorderStyle.solid),
            child: new Container(
              height: screenHeight / 4,
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
                                ptID: uid,
                              )));
                },
              ),
            )),
        Card(
            margin: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 20.0),
            shape: Border.all(
                color: Color(0xFF4A657A), width: 1.5, style: BorderStyle.solid),
            child: new Container(
              height: screenHeight / 4,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/journal1.jpeg"),
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.65), BlendMode.dstATop),
                ),
              ),
              width: screenWidth,
              child: FlatButton(
                  child: new Text("Session Planner",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontSize: 25.0,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w700)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PTDiary(
                                  ptID: uid,
                                )));
                  }),
            )),
        Container(
          width: screenWidth - 30,
          height: 40.0,
          color: Color(0xFF4A657A),
          child: new FlatButton(
            child: new Text("Sign Out",
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            onPressed: signedOut,
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
          child: Text(
            "Send your unique Trainer ID to your clients to enter on registration:",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 15.0,
              fontFamily: "Montserrat",
            ),
          ),
        ),
        Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("$uid",
                    style: TextStyle(
                        fontSize: 13.0,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w700)),
                IconButton(
                    icon: new Icon(Icons.content_copy),
                    tooltip: "Copied to clipboard",
                    onPressed: () {
                      Clipboard.setData(new ClipboardData(text: uid));
                    })
              ],
            )),
      ]);
    }

//------------------------------------------------------------------------------//

    if (authStatus == AuthStatus.signedIn) {
      return new Column(children: <Widget>[
        Card(
            margin: EdgeInsets.all(15.0),
            shape: Border.all(
                color: Colors.grey[900], width: 4.5, style: BorderStyle.solid),
            child: new Container(
              height: screenHeight / 4,
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
                          builder: (context) => PersonalisedWorkouts(
                                ptID: relationship,
                                clientID: uid,
                              )));
                },
              ),
            )),
        Card(
            margin: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 20.0),
            shape: Border.all(
                color: Color(0xFF4A657A), width: 3.5, style: BorderStyle.solid),
            child: new Container(
              height: screenHeight / 4,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/journal1.jpeg"),
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.65), BlendMode.dstATop),
                ),
              ),
              width: screenWidth,
              child: FlatButton(
                  child: new Text("Upcoming Sessions",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontSize: 25.0,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w700)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClientSessionsClientSide(
                                  clientID: uid,
                                  ptID: relationship,
                                )));
                  }),
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
