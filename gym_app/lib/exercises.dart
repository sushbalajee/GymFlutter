import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ExerciseList extends StatefulWidget {
  final String value;

  ExerciseList({Key key, this.value}) : super(key: key);

  @override
  _NextPageState createState() => new _NextPageState();
}

class _NextPageState extends State<ExerciseList> {

Future<List<Exercises>> _secondLoad (String val) async {
var data = await http.get("https://gymapp-e8453.firebaseio.com/$val.json");
var jsonData = json.decode(data.body);
List<Exercises> exer = [];
for(var u in jsonData){
  Exercises ex = Exercises(u["name"],u["description"]);
  print(ex.name + " " + ex.descrip);
  exer.add(ex);
}
print(exer.length);
}

  @override
  Widget build(BuildContext context) {
    
    _secondLoad(widget.value);
    //loadData(widget.value);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("${widget.value}"),
      ),
      body: new Text("${widget.value}"),
    );
  }
}

/*loadData(String exe) async {
  var url = "https://gymapp-e8453.firebaseio.com/Category/$exe/Exercises.json";
  var httpClient = new Client();
  var response = await httpClient.get(url);
  print('Response' + response.body);
}*/



class Exercises {
  final String name;
  final String descrip;

  Exercises(this.name, this.descrip);
}