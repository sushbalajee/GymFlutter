import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'dart:convert';
import 'jsonLogic.dart';
import 'color_loader_3.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AllBuiltinExercises extends StatefulWidget {
  final String filter;

  AllBuiltinExercises({Key key, this.filter}) : super(key: key);

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

  Future fetchPost(String filter) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/JSON/ExerciseDB.json");
    var jsonResponse = json.decode(data);

    for (var exer in jsonResponse) {
      Exercises wk = Exercises(
          exer['name'], exer['execution'], exer['image'], exer['category']);
      if (filter != "No Filter") {
        if (exer['category'] == filter) {
          exercises.add(wk);
        }
      } else {
        exercises.add(wk);
      }
    }
    exercises.sort((a, b) => a.exerciseName.compareTo(b.exerciseName));
    return exercises;
  }

  String dropdownValue = 'One';

  @override
  Widget build(BuildContext context) {
    SvgPicture iconDep;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xFF14171A),
          title:
              /*Text("Exercise List", style: TextStyle(fontFamily: "Montserrat"))*/
              Container(
                  width: screenWidth,
                  child: Stack(children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        width: screenWidth * 0.65,
                        child: Text("Exercise List",
                            style: TextStyle(fontFamily: "Montserrat"))),
                    new Positioned(
                      top: -10,
                      right: 10,
                      child: new InkWell(
                          child: DropdownButton<String>(
                        icon: Icon(Icons.filter_list),
                        iconEnabledColor: Colors.white,
                        iconSize: 30,
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Montserrat",
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600),
                        onChanged: (String newValue) {
                          Navigator.of(context)
                              .pushReplacement(new MaterialPageRoute<String>(
                                  builder: (context) => new AllBuiltinExercises(
                                        filter: newValue,
                                      )))
                              .then((String value) {
                            print(value);
                          });
                        },
                        items: <String>[
                          'Chest',
                          'Shoulders',
                          'Arms',
                          'Legs',
                          'Abs',
                          'Back'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ))
                      /*onTap: () {
                            Navigator.of(context)
                                .pushReplacement(new MaterialPageRoute<String>(
                                    builder: (context) =>
                                        new AllBuiltinExercises(filter: "Chest",)))
                                .then((String value) {
                              print(value);
                            });
                          },
                          child: Container(child: Icon(Icons.filter_list)))*/
                      ,
                    )
                  ])),
        ),
        resizeToAvoidBottomPadding: false,
        body: Container(
            child: FutureBuilder(
                future: fetchPost(widget.filter),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: new Stack(children: <Widget>[
                      Container(
                          color: Color(0xFF5E030C),
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
                                  fontSize: screenWidth * 0.05,
                                  fontFamily: "Montserrat",
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)))
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
                                  color: Color(0xFF9C1C26),
                                );
                                break;
                              case "Back":
                                iconDep = SvgPicture.asset(
                                  "assets/2.svg",
                                  height: 35,
                                  color: Color(0xFF9C1C26),
                                );
                                break;
                              case "Shoulders":
                                iconDep = SvgPicture.asset(
                                  "assets/3.svg",
                                  height: 35,
                                  color: Color(0xFF9C1C26),
                                );
                                break;
                              case "Arms":
                                iconDep = SvgPicture.asset(
                                  "assets/4.svg",
                                  height: 35,
                                  color: Color(0xFF9C1C26),
                                );
                                break;
                              case "Legs":
                                iconDep = SvgPicture.asset(
                                  "assets/5.svg",
                                  height: 35,
                                  color: Color(0xFF9C1C26),
                                );
                                break;
                              case "Abs":
                                iconDep = SvgPicture.asset(
                                  "assets/6.svg",
                                  height: 35,
                                  color: Color(0xFF9C1C26),
                                );
                                break;
                            }
                            return Container(
                                padding: EdgeInsets.all(0),
                                /*decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width:0.0, color: Color(0xFF9C1C26)),
                                  ),
                                ),*/
                                child: Column(children: <Widget>[
                                  new ExpansionTile(
                                    backgroundColor: Colors.white,
                                    leading: Transform.translate(
                                        offset: Offset(-15, 0),
                                        child: Container(
                                          height: 85,
                                          width: 58,
                                          //color: Color(0xFF9C1C26),
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
                                                  color: Color(0xFF9C1C26),
                                                  width: 1.0,
                                                ),
                                                top: BorderSide(
                                                  color: Color(0xFF9C1C26),
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
