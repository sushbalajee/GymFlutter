import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginPageState();
  // TODO: implement createState
}

enum FormType{
  login,
  register
}

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
    if (validateAndSave()) {
      try{
      FirebaseUser user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print('Signed in: ${user.uid}');
      }
      catch(e){
        print('Error: $e');
      }
    }
  }

  void moveToRegister(){
setState(() {
  formType = FormType.register;
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
            children: 
              
              buildInputs() + buildSubmitButtons()
            
          )),
    ));
  }

  List<Widget> buildInputs(){
return[
new TextFormField(
                  decoration: new InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value.isEmpty ? 'Email can\'t be empty' : null,
                  onSaved: (value) => email = value),
              new TextFormField(
                  decoration: new InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) =>
                      value.isEmpty ? 'Password can\'t be empty' : null,
                  onSaved: (value) => password = value)
];
  }

  List<Widget> buildSubmitButtons(){
    return[
new RaisedButton(
                child: new Text(
                  "Login",
                  style: TextStyle(fontSize: 20.0),
                ),
                onPressed: validateAndSubmit,
              ),
              new FlatButton(
                child: new Text("Create an Account", style: new TextStyle(fontSize: 20.0)),
                onPressed: moveToRegister,
              )
    ];
  }
}
