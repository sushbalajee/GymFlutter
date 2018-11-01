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

class Login extends StatefulWidget {
  Login({this.auth, this.onSignedIn, this.onSignedInAsPt});

  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final VoidCallback onSignedInAsPt;

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

enum FormType { login, register }

class LoginPageState extends State<Login> {

  final TextEditingController _passController = new TextEditingController();
  final TextEditingController _confirmPassController =
      new TextEditingController();
  final formKey = new GlobalKey<FormState>();

  String email;
  String password;
  String personalTrainerID;

  DatabaseReference relationshipRef;

  List<String> userIds;

  FormType formType = FormType.login;

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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    if (formType == FormType.login) {
      return new Scaffold(
          resizeToAvoidBottomPadding: false,
          body: new Container(
            color: Colors.grey[100],
            alignment: Alignment.center,
            padding:
                EdgeInsets.only(left: 20.0, right: 20.0, top: screenHeight / 8),
            child: new Form(
                key: formKey,
                child: new ListView(
                    children: buildInputsForLogin() + buildSubmitButtons())),
          ));
    } else {
      return new Scaffold(
          resizeToAvoidBottomPadding: false,
          body: new Container(
            color: Colors.grey[100],
            alignment: Alignment.center,
            padding:
                EdgeInsets.only(left: 20.0, right: 20.0, top: screenHeight / 8),
            child: new Form(
                key: formKey,
                child: new ListView(
                    children: buildInputsForRegister() + buildSubmitButtons())),
          ));
    }
  }

  Future fetchPost(String userID) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    SharedPreferences relations = await SharedPreferences.getInstance();
    
    final FirebaseDatabase database = FirebaseDatabase.instance;
    relationshipRef = database.reference().child("Workouts").child("Relationships").child(userID);


    final response =
        await http.get('https://gymapp-e8453.firebaseio.com/Workouts.json');
    var jsonResponse = json.decode(response.body);

    GetUserId post = new GetUserId.fromJson10(jsonResponse);
    userIds = post.uiCode;


    if (userIds.contains(userID)){
      await prefs.setBool('PTcheck', true);
      prefs.getBool('PTcheck');
      widget.onSignedInAsPt();
      

    } else {
      relationshipRef.once().then((snapshot){
      relations.setString('relationship', snapshot.value);
      });
      await prefs.setBool('PTcheck', false);
      prefs.getBool('PTcheck');
      widget.onSignedIn();
    }
    return userIds;
  }

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
          String userId =
              await widget.auth.signInWithEmailAndPassword(email, password);
          await fetchPost(userId);
          print('Signed in user with id: $userId');
        } else {
          String userId =
              await widget.auth.createUserWithEmailAndPassword(email, password);
          await fetchPost(userId);
          print('Created user with id: $userId');
          print("Testing: $personalTrainerID");
          //updateUID();
          _createRelationship(userId, personalTrainerID);
        }
        //widget.onSignedIn();
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void validateAndSubmitRegisterPT() async {
    print(widget.auth.currentUser());
    if (validateAndSave()) {
      try {
        String userId =
            await widget.auth.createUserWithEmailAndPassword(email, password);
        fetchPost(userId);
        print('Created user with id: $userId');
        updateUID();
        _createPTendpoint(userId);
        print("I am a PT!");
        widget.onSignedIn();
      } catch (e) {
        print('Error: $e');
      }
    }
  }

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

  List<Widget> buildInputsForLogin() {
    return [
      new TextFormField(
          decoration: new InputDecoration(labelText: 'Email'),
          validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
          onSaved: (value) => email = value),
      new TextFormField(
          decoration: new InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: (value) =>
              value.isEmpty ? 'Password can\'t be empty' : null,
          onSaved: (value) => password = value)
    ];
  }

  List<Widget> buildInputsForRegister() {
    return [
      new TextFormField(
          decoration: new InputDecoration(labelText: 'Email'),
          validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
          onSaved: (value) => email = value),
      new TextFormField(
          controller: _passController,
          decoration: new InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: (value) =>
              value.isEmpty ? 'Password can\'t be empty' : null,
          onSaved: (value) => password = value),
      new TextFormField(
          controller: _confirmPassController,
          decoration: new InputDecoration(labelText: 'Confirm Password'),
          obscureText: true,
          validator: (value) {
            if (value != _passController.text) {
              return "Passwords Do Not Match";
            }
          }),
      new TextFormField(
          decoration: new InputDecoration(labelText: 'Personal Trainer ID'),
          onSaved: (value) => personalTrainerID = value)
    ];
  }

  List<Widget> buildSubmitButtons() {
    if (formType == FormType.login) {
      return [
        new Container(
            padding: EdgeInsets.only(top: 20.0),
            child: new FlatButton(
                color: Colors.grey[900],
                child: new Text(
                  "Login",
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                onPressed: () async{
                  validateAndSubmit();
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)))),
        new OutlineButton(
            borderSide: BorderSide(color: Colors.grey[500]),
            child: new Text("Create an Account",
                style: new TextStyle(fontSize: 15.0)),
            onPressed: moveToRegister,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20.0),
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
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                onPressed: validateAndSubmit,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)))),
        new OutlineButton(
          borderSide: BorderSide(color: Colors.grey[500]),
          child: new Text("Already have an account? Login in here",
              style: new TextStyle(fontSize: 15.0)),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0),
          ),
          onPressed: moveToLogin,
        ),
        new RaisedButton(
            child: new Text("Register as a PT"), onPressed: validateAndSubmitRegisterPT)
      ];
    }
  }

  static const jsonCodec = const JsonCodec();

  void _createPTendpoint(String uid) {
    Database.createPTendpoint(uid).then((String unusedKey) {});
  }

  void _createRelationship(String clientUID, String personalTrainerUID) {
    Database.createRelationship(clientUID, personalTrainerUID).then((String unusedKey) {});
    Database.createClientEndpoint(clientUID, personalTrainerUID).then((String unusedKey) {});
  }

}

class Todo {
  String description;
  String workoutname;
  String musclegroup;

  Todo(this.workoutname, this.description, this.musclegroup);

  toJson() {
    return {
      "description": description,
      "workoutname": workoutname,
      "musclegroup": musclegroup
    };
  }
}

String uid;

void updateUID() {
  FirebaseAuth.instance.currentUser().then((userId) {
    uid = userId.uid;
  });
}

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
