import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'dart:convert';
import 'jsonLogic.dart';
import 'color_loader_3.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AllBuiltinExercises extends StatefulWidget {
  @override
  AllBuiltinExer createState() => AllBuiltinExer();
}

class AllBuiltinExer extends State<AllBuiltinExercises> {
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  final List<Exercises> exercises = [];

  DatabaseReference exercisesRef;

  String imageUrlStorage = "";
  String currentText = "";
  String textForEx;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future fetchPost() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/JSON/ExerciseDB.json");
    var jsonResponse = json.decode(data);

    for (var exer in jsonResponse) {
      Exercises wk = Exercises(
          exer['name'], exer['execution'], exer['image'], exer['category']);
      exercises.add(wk);
    }
    exercises.sort((a, b) => a.exerciseName.compareTo(b.exerciseName));
    return exercises;
  }

  @override
  Widget build(BuildContext context) {
    SvgPicture iconDep;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xFF232528),
          title:
              Text("Exercise List", style: TextStyle(fontFamily: "Montserrat")),
        ),
        resizeToAvoidBottomPadding: false,
        body: Container(
            child: FutureBuilder(
                future: fetchPost(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: new Stack(children: <Widget>[
                      Container(
                          color: Color(0xFFc9ada7),
                          alignment: Alignment.center,
                          child: ColorLoader3(
                            dotRadius: 5.0,
                            radius: 20.0,
                          )),
                      Container(
                          padding: EdgeInsets.only(top: 150.0),
                          alignment: Alignment.center,
                          child: new Text("Loading. . .",
                              style: new TextStyle(
                                  fontSize: screenWidth * 0.05, fontFamily: "Montserrat", color: Colors.white, fontWeight: FontWeight.w500)))
                    ]));
                  }
                  return Container(
                      child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            switch (snapshot.data[index].exerciseCategory) {
                              case "Chest":
                                iconDep = SvgPicture.asset(
                                  "assets/1.svg",
                                  height: 35,
                                  color: Colors.white,
                                );
                                break;
                              case "Back":
                                iconDep = SvgPicture.asset(
                                  "assets/2.svg",
                                  height: 35,
                                  color: Colors.white,
                                );
                                break;
                              case "Shoulders":
                                iconDep = SvgPicture.asset(
                                  "assets/3.svg",
                                  height: 35,
                                  color: Colors.white,
                                );
                                break;
                              case "Arms":
                                iconDep = SvgPicture.asset(
                                  "assets/4.svg",
                                  height: 35,
                                  color: Colors.white,
                                );
                                break;
                              case "Legs":
                                iconDep = SvgPicture.asset(
                                  "assets/5.svg",
                                  height: 35,
                                  color: Colors.white,
                                );
                                break;
                              case "Abs":
                                iconDep = SvgPicture.asset(
                                  "assets/6.svg",
                                  height: 35,
                                  color: Colors.white,
                                );
                                break;
                            }
                            return Container(
                                padding: EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 0.3, color: Color(0xFFc9ada7)),
                                  ),
                                ),
                                child: Column(children: <Widget>[
                                  new ExpansionTile(
                                    leading: Transform.translate(
                                        offset: Offset(-15, 0),
                                        child: Container(
                                          height: 75,
                                          width: 58,
                                          color: Color(0xFFc9ada7),
                                          padding: EdgeInsets.all(7),
                                          child: iconDep,
                                        )),
                                    title: Align(
                                        alignment: Alignment(
                                            -1 - (10 / screenWidth), 0.0),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              new Transform.translate(
                                                  offset: Offset(-15, 0),
                                                  child: Text(
                                                      snapshot.data[index]
                                                          .exerciseName,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontSize:
                                                              screenWidth *
                                                                  0.045,
                                                          color:
                                                              Color(0xFF22333B),
                                                          fontWeight:
                                                              FontWeight.w600)))
                                            ])),
                                    children: <Widget>[
                                      Container(
                                          decoration: new BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                  color: Color(0xFFc9ada7),
                                                  width: 1.0,
                                                ),
                                                top: BorderSide(
                                                  color: Color(0xFFc9ada7),
                                                  width: 1.0,
                                                )),
                                          ),
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Image.network(snapshot
                                              .data[index].exerciseImage)),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            top: 5,
                                            right: 10,
                                            bottom: 5),
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
