import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ExerciseList extends StatefulWidget {
  final String value;

  ExerciseList({Key key, this.value}) : super(key: key);

  @override
  _NextPageState createState() => new _NextPageState();
}

class _NextPageState extends State<ExerciseList> {
  @override
  Widget build(BuildContext context) {
    
    loadData(widget.value);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("${widget.value}"),
      ),
      body: new Text("${widget.value}"),
    );
  }
}

loadData(String exe) async {
  var url = "https://gymapp-e8453.firebaseio.com/Category/$exe/Exercises.json";
  var httpClient = new Client();
  var response = await httpClient.get(url);
  print('Response' + response.body);
}