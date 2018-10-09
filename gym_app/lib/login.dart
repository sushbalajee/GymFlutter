import 'package:flutter/material.dart';
import 'auth.dart';

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
        if(formType == FormType.login){
        String userId = await widget.auth.signInWithEmailAndPassword(email, password);
        print('Signed in user with id: $userId');
        }
        else{
          String userId = await widget.auth.createUserWithEmailAndPassword(email, password);
          print('Created user with id: $userId');
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

  void moveToLogin(){
    formKey.currentState.reset();
    setState(() {
      formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Container(
      padding: EdgeInsets.all(20.0),
      child: new Form(
          key: formKey,
          child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buildInputs() + buildSubmitButtons())),
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
    if(formType == FormType.login){
    return [
      new RaisedButton(
        child: new Text("Login",
          style: TextStyle(fontSize: 20.0),
        ),
        onPressed: validateAndSubmit,
      ),
      new FlatButton(
        child:
            new Text("Create an Account", style: new TextStyle(fontSize: 15.0)),
        onPressed: moveToRegister,
      )
    ];}
    else{
      return [
      new RaisedButton(
        child: new Text("Create an account",
          style: TextStyle(fontSize: 20.0),
        ),
        onPressed: validateAndSubmit,
      ),
      new FlatButton(
        child:
            new Text("Already have an account? Login in here", style: new TextStyle(fontSize: 15.0)),
        onPressed: moveToLogin,
      )
    ];
    }
  }
}
