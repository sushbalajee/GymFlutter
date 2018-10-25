import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
                  //createEndpoint(new Todo("1","2","3"));
                  updateUID();
                  _createMountain(userId);

                  }
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
          
            @override
            Widget build(BuildContext context) {
              double screenHeight = MediaQuery.of(context).size.height;
          
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
                  new FlatButton(
                    child: new Text("Create an Account",
                        style: new TextStyle(fontSize: 15.0)),
                    onPressed: moveToRegister,
                  )
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
                  new FlatButton(
                    child: new Text("Already have an account? Login in here",
                        style: new TextStyle(fontSize: 15.0)),
                    onPressed: moveToLogin,
                  )
                ];
              }
            }
          
            static const jsonCodec = const JsonCodec();
          
            createEndpoint(Todo todo) async {
              var jsonResponse = json.encode(todo);
              print("Json = $jsonResponse");
          
              var url = 'https://gymapp-e8453.firebaseio.com/Workouts.json';
              var response = await http.post(url, body: jsonResponse);
            
            }

              void _createMountain(String uid) {
    Database.createMountain(uid).then((String mountainKey) {
    });
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
    "musclegroup" :musclegroup};
  }
}


class Database {

  static Future<String> createMountain(String userUID) async {
    
    var mountain = <String, dynamic>{
      'name' : '',
    };

    DatabaseReference reference = FirebaseDatabase.instance
        .reference().child("Workouts")
        .child(userUID);
        //.child("mountains")
        // .push();

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
