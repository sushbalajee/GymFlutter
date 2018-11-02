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

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => RootPageState();
}

enum AuthStatus { notSignedIn, signedIn, signedInAsPT, notDetermined}

class RootPageState extends State<RootPage> {

  RootPageState({this.auth, this.onSignedOut});

  final BaseAuth auth;
  final VoidCallback onSignedOut;

  List<String> userIds;

  bool typeOfUser;

  String uid;
  String statusOfUser;
  String relationship = "";

  AuthStatus authStatus = AuthStatus.notDetermined;

  @override
  void initState() {
    super.initState();

    widget.auth.currentUser().then((userId) async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    typeOfUser = prefs.getBool('PTcheck');
    print(typeOfUser);

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
                });//do something?
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

    if (userIds.contains(userID)){
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

    if(authStatus == AuthStatus.notDetermined){
      return new Text("Waiting");//change
    }
    
    if (authStatus == AuthStatus.notSignedIn) {
        return new Login(auth: widget.auth, onSignedIn: signedIn, onSignedInAsPt: signedInAsPT);
    }

    if (authStatus == AuthStatus.signedInAsPT) {
      return new Column(children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 20.0),
          child: new Text (""),
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
                            value: relationship,
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
    return null;
  }
}
