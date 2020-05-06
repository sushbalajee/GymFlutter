import 'package:flutter/material.dart';
import 'dart:async';
import 'auth.dart';
import 'database.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'personalisedWorkouts.dart';
import 'usersList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'color_loader_3.dart';
import 'package:flutter/services.dart';
import 'ptDiary.dart';
import 'upcomingSessions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_card/flip_card.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => RootPageState();
}

enum AuthStatus { notSignedIn, signedIn, signedInAsPT, notDetermined }

class RootPageState extends State<RootPage> {
  RootPageState({this.auth, this.onSignedOut});

    DatabaseReference clientNamesRef;

  final BaseAuth auth;
  final VoidCallback onSignedOut;

  List<String> userIDs;

  bool userType;

  String uid = "Please sign out and sign in\n to activate your Trainer ID";
  String xx = "unknown";
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

  Future fetchPost1() async {

TestingClientNames testclient;
testclient = TestingClientNames("", "");

final FirebaseDatabase database = FirebaseDatabase.instance;

    clientNamesRef = database
        .reference()
        .child('Workouts')
        .child('ClientNames')
        .child(uid);
        
    clientNamesRef.once().then((DataSnapshot snapshot) {
      
  Map<dynamic, dynamic> values = snapshot.value;
     values.forEach((key,values) {
      print(values["status"]);

    testclient.clientName = values["clientName"];
    testclient.status = "Deleted";  

    clientNamesRef.set(testclient.toJson());


      });




      //print(clientNamesRef.path);
      
      });

      //testclient.status = "Deleted";
      //clientNamesRef.push().set(testclient.toJson());

    //final response = await http.get(
      //  'https://gymapp-e8453.firebaseio.com/Workouts/ClientNames/' + uid + '.json');

   // var jsonResponse = json.decode(response.body);
    //print(jsonResponse);
    /*if (jsonResponse != "") {
      GetClientIDs post = new GetClientIDs.fromJson20(jsonResponse);
    } */
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

  Future<void> deleteUser() async {

    fetchPost1();
    
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    user.delete();
    confirmAccountDeleteDialog(context, "Account Deleted",
        "Your account has been successfully deleted");
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
      return new Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: new LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Column(children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: screenWidth / 8),
                color: Color(0xFF23395b),
                height: constraints.maxHeight / 3,
                width: constraints.maxWidth,
                child: FlatButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UIDList(
                                    ptID: uid,
                                  )));
                    },
                    icon: SvgPicture.asset(
                      "assets/gym.svg",
                      color: Colors.white,
                      height: constraints.maxWidth / 5,
                    ),
                    label: Text(
                      "    My Clients",
                      style: TextStyle(
                        fontSize: screenWidth / 15,
                        fontFamily: "Montserrat",
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: screenWidth / 8),
                  color: Color(0xFF4f5d75),
                  height: constraints.maxHeight / 3,
                  width: constraints.maxWidth,
                  child: FlatButton.icon(
                      icon: SvgPicture.asset("assets/diary.svg",
                          height: constraints.maxWidth / 5,
                          color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PTDiary(
                                      ptID: uid,
                                    )));
                      },
                      label: Text(
                        "    Sessions",
                        style: TextStyle(
                          fontSize: screenWidth / 15,
                          fontFamily: "Montserrat",
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ))),
              FlipCard(
                  direction: FlipDirection.HORIZONTAL, // default
                  front: new Stack(
                    children: <Widget>[
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: screenWidth / 8),
                          color: Color(0xFF788aa3),
                          height: constraints.maxHeight / 3,
                          width: constraints.maxWidth,
                          child: FlatButton.icon(
                              icon: SvgPicture.asset("assets/name.svg",
                                  height: constraints.maxWidth / 5,
                                  color: Colors.white),
                              onPressed: null,
                              label: Text(
                                "    Trainer ID",
                                style: TextStyle(
                                  fontSize: screenWidth / 15,
                                  fontFamily: "Montserrat",
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ))),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: PopupMenuButton(
                              color: Color(0xFF23395b),
                              offset: Offset(0, -50),
                              itemBuilder: (context) => [
                                    PopupMenuItem(
                                        child: Container(
                                      padding: EdgeInsets.only(left: 15),
                                      child: FlatButton(
                                          onPressed: signedOut,
                                          child: Text("Signout",
                                              style: TextStyle(
                                                  fontFamily: "Montserrat",
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w500))),
                                    )),
                                  ],
                              icon: Icon(
                                Icons.exit_to_app,
                                color: Colors.white,
                              )))
                    ],
                  ),
                  back: Container(
                      color: Color(0xFF788aa3),
                      child: Column(children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(left: 40.0, right: 40.0),
                            height: constraints.maxHeight / 6,
                            width: constraints.maxWidth,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                    "Send your unique Trainer ID to your clients to enter on registration:",
                                    style: TextStyle(
                                      fontSize: screenWidth / 25,
                                      fontFamily: "Montserrat",
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    )))),
                        Container(
                            padding: EdgeInsets.only(left: 40.0),
                            height: constraints.maxHeight / 6,
                            width: constraints.maxWidth,
                            child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: screenWidth,
                                  child: Row(
                                    children: <Widget>[
                                      Text("$uid",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth / 25,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.w700)),
                                      IconButton(
                                          icon: new Icon(Icons.content_copy,
                                              color: Colors.white),
                                          tooltip: "Copied to clipboard",
                                          onPressed: () {
                                            Clipboard.setData(
                                                new ClipboardData(text: uid));
                                          })
                                    ],
                                  ),
                                )))
                      ])))
            ]);
          }),
        ),
      );
    }

//------------------------------------------------------------------------------//

    if (authStatus == AuthStatus.signedIn) {
      //fetchPost1();
      return new Scaffold(
          backgroundColor: Colors.grey[100],
          body: SafeArea(child: new LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Column(children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: screenWidth / 8),
                color: Color(0xFF23395b),
                height: constraints.maxHeight / 3,
                width: constraints.maxWidth,
                child: FlatButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PersonalisedWorkouts(
                                    ptID: relationship,
                                    clientID: uid,
                                  )));
                    },
                    icon: SvgPicture.asset(
                      "assets/gym.svg",
                      color: Colors.white,
                      height: constraints.maxWidth / 5,
                    ),
                    label: Text(
                      "    My Workouts",
                      style: TextStyle(
                        fontSize: screenWidth / 15,
                        fontFamily: "Montserrat",
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: screenWidth / 8),
                  color: Color(0xFF4f5d75),
                  height: constraints.maxHeight / 3,
                  width: constraints.maxWidth,
                  child: FlatButton.icon(
                      icon: SvgPicture.asset("assets/diary.svg",
                          height: constraints.maxWidth / 5,
                          color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClientSessionsClientSide(
                                      clientID: uid,
                                      ptID: relationship,
                                    )));
                      },
                      label: Text(
                        "    My Sessions",
                        style: TextStyle(
                          fontSize: screenWidth / 15,
                          fontFamily: "Montserrat",
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ))),
              FlipCard(
                  direction: FlipDirection.HORIZONTAL, // default
                  front: new Stack(
                    children: <Widget>[
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: screenWidth / 8),
                          color: Color(0xFF788aa3),
                          height: constraints.maxHeight / 3,
                          width: constraints.maxWidth,
                          child: FlatButton.icon(
                              icon: SvgPicture.asset("assets/name.svg",
                                  height: constraints.maxWidth / 5,
                                  color: Colors.white),
                              onPressed: null,
                              label: Text(
                                "    My Account",
                                style: TextStyle(
                                  fontSize: screenWidth / 15,
                                  fontFamily: "Montserrat",
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ))),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: PopupMenuButton(
                              color: Color(0xFF23395b),
                              offset: Offset(0, -50),
                              itemBuilder: (context) => [
                                    PopupMenuItem(
                                        child: Container(
                                      child: FlatButton(
                                          onPressed: signedOut,
                                          child: Text("Signout",
                                              style: TextStyle(
                                                  fontFamily: "Montserrat",
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w500))),
                                    )),
                                  ],
                              icon: Icon(
                                Icons.exit_to_app,
                                color: Colors.white,
                              )))
                    ],
                  ),
                  back: Container(
                      height: constraints.maxHeight / 3,
                      width: screenWidth,
                      color: Color(0xFF788aa3),
                      child: Column(children: <Widget>[
                        Container(
                          child: new FlatButton(
                            child: new Text("Delete My Account",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            onPressed: () {
                              
                              print(xx);
                              confirmDeleteDialog(context, "Delete Account",
                                  "Are you sure you would like to delete your account? \n\nYou will no longer have access to any workouts associated with this account.");
                            },
                          ),
                        ),
                      ])))
            ]);
          })));
    }
    return null;
  }

  Future<bool> confirmDeleteDialog(
      BuildContext context, String why, String subtitle) {

return new Alert(
    context: context,
    //style: alertStyle,
    closeFunction: () => null,
    type: AlertType.warning,
    title: why,
    desc: subtitle,
    buttons: [
      DialogButton(
        child: Text(
          "Cancel",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontFamily: "Montserrat"),
        ),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
        color: Color(0xFF4f5d75),
        radius: BorderRadius.circular(5.0),
      ),
      DialogButton(
        child: Text(
          "Delete",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontFamily: "Montserrat"),
        ),
        onPressed: () {
          print("test");
          deleteUser();
          Navigator.of(context, rootNavigator: true).pop();
        },
        color: Colors.red,
        radius: BorderRadius.circular(5.0),
      ),
    ],
  ).show();
  }

  Future<bool> confirmAccountDeleteDialog(
      BuildContext context, String why, String subtitle) {


return new Alert(
    context: context,
    //style: alertStyle,
    closeFunction: () => null,
    type: AlertType.success,
    title: why,
    desc: subtitle,
    buttons: [
      DialogButton(
        child: Text(
          "Close",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontFamily: "Montserrat"),
        ),
        onPressed: () {
          signedOut();
          Navigator.of(context, rootNavigator: true).pop();
        },
        color: Color(0xFF4f5d75),
        radius: BorderRadius.circular(5.0),
      ),
    ],
  ).show();
  }
}

class Constants {
  static const String SignOut = 'Sign out';
  static const List<String> choices = <String>[SignOut];
}
