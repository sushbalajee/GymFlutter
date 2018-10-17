import 'package:flutter/material.dart';
import 'workoutDetails.dart';
import 'jsonLogic.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

//-----------------------------------------------------------------------------------//

class WorkoutsListPersonal extends StatefulWidget {
  final String userUid;
  final String value;

  WorkoutsListPersonal({Key key, this.value, this.userUid}) : super(key: key);

  @override
  _NextPageStatePersonal createState() => new _NextPageStatePersonal();
}

//-----------------------------------------------------------------------------------//

class _NextPageStatePersonal extends State<WorkoutsListPersonal> {
  List<Workouts> users = [];
  final List<Workouts> workouts = [];
  String uid;

  Future fetchPost(String hitMe) async {

    final response =
        await http.get('https://gymapp-e8453.firebaseio.com/Workouts.json');
    var jsonResponse = json.decode(response.body);
    WorkoutCategory post = new WorkoutCategory.fromJson(jsonResponse, hitMe);
    //print("Snakes: " + post.uiCode);
    workouts.clear();
    for (var work in post.workouts) {
      Workouts wk = Workouts(work.workoutname, work.musclegroup,
          work.listOfExercises, work.description);
      workouts.add(wk);
    }
    return workouts;
  }

//-----------------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    int workoutNumber = 0;
    
    double screenWidth = MediaQuery.of(context).size.width;
    return new Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Colors.grey[900],
            title: new Text("My Workouts")),
        body: Container(
            child: FutureBuilder(
                future: fetchPost(widget.userUid),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: Center(
                      child: Text("Loading..."),
                    ));
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          workoutNumber += index;
                          return ListTile(
                              title: Text(snapshot.data[index].workoutname,
                                  style: TextStyle(
                                      fontFamily: "Prompt",
                                      fontSize: screenWidth * 0.055,
                                      fontWeight: FontWeight.w700)),
                              leading:
                                  CircleAvatar(child: Text("$workoutNumber")),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PageThree(
                                            value: workouts,
                                            title: snapshot
                                                .data[index].workoutname,
                                            muscleGroup: snapshot
                                                .data[index].musclegroup,
                                            description: snapshot
                                                .data[index].description)));
                              });
                        });
                  }
                })));
  }
}
