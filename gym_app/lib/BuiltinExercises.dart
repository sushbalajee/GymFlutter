import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'dart:convert';
import 'jsonLogic.dart';

class BuiltinExercises extends StatefulWidget {
  final String value;

  BuiltinExercises({Key key, this.value}) : super(key: key);

  @override
  BuiltinExer createState() => BuiltinExer();
}

class BuiltinExer extends State<BuiltinExercises> {
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  final List<Exercises> exercises = [];

  DatabaseReference exercisesRef;

  String imageUrlStorage = "";
  String currentText = "";
  String textForEx;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future fetchPost(String hitMe) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/JSON/ExerciseDB.json");
    var jsonResponse = json.decode(data);

    for (var exer in jsonResponse) {
      Exercises wk = Exercises(exer['name'], exer['execution'], exer['image']);
      exercises.add(wk);
    }
    return exercises;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF232528),
          title: Text("widget.title", style: TextStyle(fontFamily: "Ubuntu")),
        ),
        resizeToAvoidBottomPadding: false,
        body: Container(
            child: FutureBuilder(
                future: fetchPost("Abs"),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return Container(
                      child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                                color: Colors.grey[100],
                                margin: EdgeInsets.all(1.0),
                                elevation: 0.6,
                                child: Column(children: <Widget>[
                                  new ExpansionTile(
                                    title: Align(
                                        alignment: Alignment(
                                            -1 - (10 / screenWidth), 0.0),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              new Text(
                                                  snapshot
                                                      .data[index].exerciseName,
                                                  style: TextStyle(
                                                      fontFamily: "Ubuntu",
                                                      fontSize:
                                                          screenWidth * 0.055,
                                                      color: Color(0xFF22333B),
                                                      fontWeight:
                                                          FontWeight.w600))
                                            ])),
                                    children: <Widget>[
                                      Container(
                                          child: Image.network(
                                              snapshot.data[index].exerciseImage
                                              //items[index].target
                                              )),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              new Text(
                                                  snapshot.data[index]
                                                      .exerciseExecution,
                                                  style: TextStyle(
                                                      fontFamily: "Prompt",
                                                      color: Color(0xFF22333B),
                                                      fontSize:
                                                          screenWidth * 0.04))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]));
                          }));
                })));
  }
}
