import 'package:flutter/material.dart';
import 'dart:async';
import 'auth.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'personalisedWorkouts.dart';
import 'usersList.dart';
import 'package:firebase_database/firebase_database.dart';
import 'uploadClientWorkouts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => RootPageState();
}

enum AuthStatus { notSignedIn, signedIn, signedInAsPT }

class RootPageState extends State<RootPage> {
  RootPageState({this.auth, this.onSignedOut});

  final BaseAuth auth;
  final VoidCallback onSignedOut;

  bool typeOfUser;

  String uid;
  String statusOfUser;
  String relo = "";

  AuthStatus authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();

    widget.auth.currentUser().then((userId) {
      if (userId != null) {
        updateup();
        setState(() {
          if (typeOfUser == true) {
            authStatus = userId == null? AuthStatus.notSignedIn : AuthStatus.signedInAsPT;
            statusOfUser = "You are Logged in as a Personal Trainer";
          } else {
            authStatus =
                userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
            updateRelationship();
            print("You are logged in as a client");
          }
        });
      } else {
        print("User is Null");
      }
    });
  }

  void signedIn() {
    updateup();
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void signedInAsPT() {
    updateup();
    setState(() {
      authStatus = AuthStatus.signedInAsPT;
    });
  }

  void signedOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setBool('PTcheck', false);
    prefs.clear();

    setState(() {
      FirebaseAuth.instance.signOut();
      authStatus = AuthStatus.notSignedIn;
    });
  }

  void updateRelationship() async {
    SharedPreferences relations = await SharedPreferences.getInstance();
    relo = relations.getString('relationship');
  }

  Future updateup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    typeOfUser = prefs.getBool('PTcheck');
    print("typeOfUser: $typeOfUser");

    FirebaseAuth.instance.currentUser().then((userId) {
      if (userId != null) {
        uid = userId.uid;
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    updateup();

    if (authStatus == AuthStatus.notSignedIn) {
      if (typeOfUser == true) {
        return new Login(auth: widget.auth, onSignedIn: signedInAsPT);
      } else {
        return new Login(auth: widget.auth, onSignedIn: signedIn);
      }
    }

    if (authStatus == AuthStatus.signedInAsPT) {
      return new Column(children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 20.0),
          child: new Text(statusOfUser),
        ),
        Container(
          padding: EdgeInsets.all(20.0),
          alignment: Alignment.center,
          child: new RaisedButton(
            child: new Text("My Personalised Workouts"),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkoutsListPersonal(
                            value: relo,
                            userUid: uid,
                          )));
            },
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 20.0),
          alignment: Alignment.center,
          child: new RaisedButton(
            child: new Text("My Clients"),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UIDList(
                            trainerID: uid,
                          )));
            },
          ),
        ),
        RaisedButton(
            color: Colors.grey[900],
            child: new Text(
              "Sign Out",
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
            onPressed: signedOut,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0))),
      ]);
    }

    if (authStatus == AuthStatus.signedIn) {
      return new Column(children: <Widget>[
        Container(
          padding: EdgeInsets.all(20.0),
          alignment: Alignment.center,
          width: screenWidth,
          child: new FlatButton(
            child: new Text("My Personalised Workouts"),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkoutsListPersonal(
                            value: relo,
                            userUid: uid,
                          )));
            },
          ),
        ),
        RaisedButton(
            color: Colors.grey[900],
            child: new Text(
              "Sign Out",
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
            onPressed: signedOut,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0))),
      ]);
    }
  }
  //return null;
}
