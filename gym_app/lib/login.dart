import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  Login({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

enum FormType { login, register }

class LoginPageState extends State<Login> {

  final TextEditingController _passController = new TextEditingController();
  final TextEditingController _confirmPassController = new TextEditingController();
  final formKey = new GlobalKey<FormState>();

  String email;
  String password;
  FormType formType = FormType.login;

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
    print(widget.auth.currentUser());
    if (validateAndSave()) {
      try {
        if (formType == FormType.login) {
          String userId =
              await widget.auth.signInWithEmailAndPassword(email, password);
          print('Signed in user with id: $userId');
        } else {
          String userId =
              await widget.auth.createUserWithEmailAndPassword(email, password);
          print('Created user with id: $userId');
          updateUID();
          _createMountain(userId);
        }
        widget.onSignedIn();
      } catch (e) {
        if ("$e" ==
            "PlatformException(exception, The email address is badly formatted., null)") {
          confirmDialog(context, "Invalid Email",
              "Please check that you have entered your email address correctly and try again");
        } else if ("$e" ==
            "PlatformException(exception, There is no user record corresponding to this identifier. The user may have been deleted., null)") {
          confirmDialog(context, "Invalid User",
              "Please check that you have entered your email address correctly and try again");
        } else if ("$e" ==
            "PlatformException(exception, The password is invalid or the user does not have a password., null)") {
          confirmDialog(context, "Incorrect Password",
              "Please check that you have entered your password correctly and try again");
        } else if ("$e" ==
            "PlatformException(exception, The given password is invalid. [ Password should be at least 6 characters ], null)") {
          confirmDialog(context, "Password too short",
              "Please enter a password that is atleast 6 characters");
        }
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

if(formType == FormType.login){
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: new Container(
          color: Colors.grey[100],
          alignment: Alignment.center,
          padding:
              EdgeInsets.only(left: 20.0, right: 20.0, top: screenHeight / 8),
          child: new Form(
              key: formKey,
              child:
                  new ListView(children: buildInputs() + buildSubmitButtons())),
        ));
}
else{
   return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: new Container(
          color: Colors.grey[100],
          alignment: Alignment.center,
          padding:
              EdgeInsets.only(left: 20.0, right: 20.0, top: screenHeight / 8),
          child: new Form(
              key: formKey,
              child:
                  new ListView(children: buildInputs2() + buildSubmitButtons())),
        ));
}

  }

  List<Widget> buildInputs() {
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

List<Widget> buildInputs2() {
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
          if(value != _passController.text){
            return "Passwords Do Not Match";
          }})
              //value.isEmpty ? 'Passwords do not match' : null,)
          //onSaved: (value) => password = value)
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
                onPressed: validateAndSubmit,
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
        )
      ];
    }
  }

  static const jsonCodec = const JsonCodec();

  void _createMountain(String uid) {
    Database.createMountain(uid).then((String mountainKey) {});
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

class Database {
  static Future<String> createMountain(String userUID) async {
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("Workouts").child(userUID);

    reference.set("");

    return reference.key;
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
