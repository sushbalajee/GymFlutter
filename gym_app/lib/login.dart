import 'dart:async';
import 'database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'usersList.dart';
import 'color_loader_3.dart';

class Login extends StatefulWidget {
  Login({this.auth, this.onSignedIn, this.onSignedInAsPt});

  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final VoidCallback onSignedInAsPt;

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

//------------------------------------------------------------------------------//

enum FormType { login, register, loading }

class LoginPageState extends State<Login> {
  final TextEditingController _passController = new TextEditingController();
  final TextEditingController _confirmPassController = new TextEditingController();
  final formKey = new GlobalKey<FormState>();

  String email;
  String password;
  String personalTrainerID;

  bool validPTID;

  DatabaseReference relationshipEndpoint;
  List<String> userIds;
  FormType formType = FormType.login;

  //------------------------------------------------------------------------------//

  @override
  void initState() {
    super.initState();

    widget.auth.currentUser().then((userId) {
      if (userId != null) {
        print("This is the userID: $userId");
        fetchPost(userId);
      } else {
        print("User is Null");
      }
    });
  }

//------------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    if (formType == FormType.login) {
      return new Scaffold(
          resizeToAvoidBottomPadding: false,
          body: new Container(
            color: Colors.grey[100],
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            child: new Form(
                key: formKey,
                child: new ListView(
                    children: buildInputsForLogin() + buildSubmitButtons())),
          ));
    } else if (formType == FormType.register) {
      return new Scaffold(
          resizeToAvoidBottomPadding: false,
          body: new Container(
            color: Colors.grey[100],
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            child: new Form(
                key: formKey,
                child: new ListView(
                    children: buildInputsForRegister() + buildSubmitButtons())),
          ));
    } else {
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
                child: new Text("... Logging in ...",
                    style: new TextStyle(
                        fontSize: 20.0, fontFamily: "Montserrat")))
          ]));
    }
  }

//------------------------------------------------------------------------------//

  Future fetchPost(String userID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SharedPreferences relations = await SharedPreferences.getInstance();

    final FirebaseDatabase database = FirebaseDatabase.instance;
    relationshipEndpoint = database
        .reference()
        .child("Workouts")
        .child("Relationships")
        .child(userID);

    final response =
        await http.get('https://gymapp-e8453.firebaseio.com/Workouts.json');
    var jsonResponse = json.decode(response.body);

    GetUserId post = new GetUserId.fromJson10(jsonResponse);
    userIds = post.uiCode;

    if (userIds.contains(userID)) {
      await prefs.setBool('PTcheck', true);
      prefs.getBool('PTcheck');
      widget.onSignedInAsPt();
    } else {
      relationshipEndpoint.once().then((snapshot) {
        relations.setString('relationship', snapshot.value);
      });
      await prefs.setBool('PTcheck', false);
      prefs.getBool('PTcheck');
      widget.onSignedIn();
    }
    return userIds;
  }

//------------------------------------------------------------------------------//

  Future checkPTDexists(String personalTrainer) async {
    final response =
        await http.get('https://gymapp-e8453.firebaseio.com/Workouts.json');
    var jsonResponse = json.decode(response.body);

    GetUserId post = new GetUserId.fromJson10(jsonResponse);
    userIds = post.uiCode;

    if (userIds.contains(personalTrainer)) {
      validPTID = true;
    } else {
      print("SCAM! boiiiii"); //do something
    }
    return userIds;
  }

//------------------------------------------------------------------------------//

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (formType == FormType.login) {
          moveToLoading();
          String userId =
              await widget.auth.signInWithEmailAndPassword(email, password);
          await fetchPost(userId);
        } else {
          await checkPTDexists(personalTrainerID);
          if (validPTID == true) {
            moveToLoading();
            String userId = await widget.auth
                .createUserWithEmailAndPassword(email, password);
            await fetchPost(userId);
            _createRelationship(userId, personalTrainerID);
          } else {
            print("UNLUGGY USO"); //do something
          }
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void validateAndSubmitRegisterPT() async {
    print(widget.auth.currentUser());
    if (validateAndSave()) {
      if (personalTrainerID == null || personalTrainerID == "") {
        try {
          moveToLoading();
          String userId =
              await widget.auth.createUserWithEmailAndPassword(email, password);
          print('Created user with id: $userId');
          updateUID();
          _createPTendpoint(userId);
          print("I am a PT!");
          widget.onSignedInAsPt();
        } catch (e) {
          print('Error: $e');
        }
      } else {
        print("DO NOT ENTER A PT ID"); //do something
      }
    }
  }

//------------------------------------------------------------------------------//

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      formType = FormType.login;
    });
  }

  void moveToLoading() {
    formKey.currentState.reset();
    setState(() {
      formType = FormType.loading;
    });
  }

//------------------------------------------------------------------------------//

  List<Widget> buildInputsForLogin() {
    return [
      new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Email',
              labelStyle:
                  new TextStyle(fontSize: 15.0, fontFamily: "Montserrat"),
              icon: new Icon(Icons.email, color: Colors.grey[900])),
          validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
          onSaved: (value) => email = value),
      new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Password',
              labelStyle:
                  new TextStyle(fontSize: 15.0, fontFamily: "Montserrat"),
              icon: new Icon(Icons.lock, color: Colors.grey[900])),
          obscureText: true,
          validator: (value) =>
              value.isEmpty ? 'Password can\'t be empty' : null,
          onSaved: (value) => password = value)
    ];
  }

  List<Widget> buildInputsForRegister() {
    return [
      new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Email',
              labelStyle:
                  new TextStyle(fontSize: 15.0, fontFamily: "Montserrat"),
              icon: new Icon(Icons.email, color: Colors.grey[900])),
          validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
          onSaved: (value) => email = value),
      new TextFormField(
          controller: _passController,
          decoration: new InputDecoration(
              labelText: 'Password',
              labelStyle:
                  new TextStyle(fontSize: 15.0, fontFamily: "Montserrat"),
              icon: new Icon(Icons.lock, color: Colors.grey[900])),
          obscureText: true,
          validator: (value) =>
              value.isEmpty ? 'Password can\'t be empty' : null,
          onSaved: (value) => password = value),
      new TextFormField(
          controller: _confirmPassController,
          decoration: new InputDecoration(
              labelText: 'Confirm Password',
              labelStyle:
                  new TextStyle(fontSize: 15.0, fontFamily: "Montserrat"),
              icon: new Icon(Icons.lock, color: Colors.grey[900])),
          obscureText: true,
          validator: (value) {
            if (value != _passController.text) {
              return "Passwords Do Not Match";
            }
          }),
      new TextFormField(
          decoration: new InputDecoration(
              labelText: 'Personal Trainer ID',
              labelStyle:
                  new TextStyle(fontSize: 15.0, fontFamily: "Montserrat"),
              icon: new Icon(Icons.person, color: Colors.grey[900])),
          onSaved: (value) => personalTrainerID = value)
    ];
  }

//------------------------------------------------------------------------------//

  List<Widget> buildSubmitButtons() {
    if (formType == FormType.login) {
      return [
        new Container(
            padding: EdgeInsets.only(top: 20.0),
            child: new FlatButton(
                color: Colors.grey[900],
                child: new Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w400),
                ),
                onPressed: () async {
                  validateAndSubmit();
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0)))),
        new OutlineButton(
            borderSide: BorderSide(color: Colors.grey[400]),
            child: new Text("Create an Account",
                style: new TextStyle(fontSize: 15.0, fontFamily: "Montserrat")),
            onPressed: moveToRegister,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
            ))
      ];
    } else {
      return [
        new Container(
            padding: EdgeInsets.only(top: 20.0),
            child: new RaisedButton(
                color: Colors.grey[900],
                child: new Text(
                  "Register",
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontFamily: "Montserrat"),
                ),
                onPressed: validateAndSubmit,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0)))),
        new OutlineButton(
          borderSide: BorderSide(color: Colors.grey[400]),
          padding: EdgeInsets.all(10.0),
          child: new Text("Already have an account? Login in here",
              textAlign: TextAlign.center,
              style: new TextStyle(fontSize: 15.0, fontFamily: "Montserrat")),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5.0),
          ),
          onPressed: moveToLogin,
        ),
        new Container(
            //padding: EdgeInsets.only(top: screenHeight/6),
            child: new FlatButton(
                color: Colors.grey[300],
                child: new Text("Register as a Trainer",
                    style: new TextStyle(
                        fontSize: 15.0, fontFamily: "Montserrat")),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                onPressed: () {
                  validateAndSubmitRegisterPT();
                }))
      ];
    }
  }

//------------------------------------------------------------------------------//

  static const jsonCodec = const JsonCodec();

  void _createPTendpoint(String uid) {
    Database.createPTendpoint(uid).then((String unusedKey) {});
  }

  void _createRelationship(String clientUID, String personalTrainerUID) {
    Database.createRelationship(clientUID, personalTrainerUID)
        .then((String unusedKey) {});
    Database.createClientEndpoint(clientUID, personalTrainerUID)
        .then((String unusedKey) {});
  }
}

String uid;

void updateUID() {
  FirebaseAuth.instance.currentUser().then((userId) {
    uid = userId.uid;
  });
}

//------------------------------------------------------------------------------//

Future<Null> confirmDialog(BuildContext context, String why, String execution) {
  return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text("Login Failed - " + why),
          content: new Text(execution),
          actions: <Widget>[
            new FlatButton(
              child: const Text('CLOSE'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

//------------------------------------------------------------------------------//
