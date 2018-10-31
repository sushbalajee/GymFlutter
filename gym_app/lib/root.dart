import 'package:flutter/material.dart';
import 'auth.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'personalisedWorkouts.dart';
import 'usersList.dart';
import 'package:firebase_database/firebase_database.dart';
import 'uploadClientWorkouts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<Item> items = List();
  Item item;

  String uid;
  String statusOfUser;

  DatabaseReference itemRef;

  AuthStatus authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();

    widget.auth.currentUser().then((userId) {
      if (userId != null) {
        updateup();
        //print(userId);

        final FirebaseDatabase database = FirebaseDatabase.instance;
        itemRef = database.reference().child('Workouts').child(userId);
        itemRef.onChildAdded.listen(_onEntryAdded);

        setState(() {
          if (typeOfUser == true) {
            authStatus =
                userId == null ? AuthStatus.signedIn : AuthStatus.signedInAsPT;
            statusOfUser = "You are Logged in as a Personal Trainer";
          } else {
            authStatus =
                userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
            print("You are logged in as a client");
          }
        });
      } else { 
        print("User is Null");
      }
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  void signedIn() {
    updateup();
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void signedOut() {
    setState(() {
      FirebaseAuth.instance.signOut();
      authStatus = AuthStatus.notSignedIn;
    });
  }

  void updateup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    typeOfUser = prefs.getBool('PTcheck');

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

    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new Login(auth: widget.auth, onSignedIn: signedIn);

      case AuthStatus.signedIn:
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
                              value: "Test",
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

      case AuthStatus.signedInAsPT:
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
                              value: "Test",
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UIDList()));
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