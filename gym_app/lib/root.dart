import 'package:flutter/material.dart';
import 'auth.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'personalisedWorkouts.dart';
import 'workouts.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class RootPageState extends State<RootPage> {
  RootPageState({this.auth, this.onSignedOut});

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  String uid;

  AuthStatus authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void signedIn() {
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

  void signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  void updateup() {
    FirebaseAuth.instance.currentUser().then((userId) {
      uid = userId.uid;
    });
  }

  @override
  Widget build(BuildContext context) {

    updateup();

    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new Login(auth: widget.auth, onSignedIn: signedIn);
      case AuthStatus.signedIn:
        return new Column( 
          children: <Widget>[ 
          Container(
            padding: EdgeInsets.all(20.0),
            alignment: Alignment.center,
            child: new RaisedButton( child: new Text("My Personalised Workouts"),
            onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WorkoutsListPersonal(
                              value: "Test",
                              userUid: uid,
                            ))
                   );
            },),
            ),
          RaisedButton( 
            color: Colors.grey[900],
            child: new Text("Sign Out", style: TextStyle(fontSize: 15.0, color: Colors.white),),
            onPressed: signedOut,
            shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0))),
        ]);
    }
    return null;
  }
}