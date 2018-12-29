import 'package:flutter/material.dart';
import 'dart:async';
import 'jsonLogic.dart';

class WorkoutDetails extends StatefulWidget {
  final List<Workouts> value;
  final String title;
  final String muscleGroup;
  final String description;

  WorkoutDetails(
      {Key key, this.value, this.title, this.muscleGroup, this.description})
      : super(key: key);

  @override
  WorkoutDetailsState createState() => new WorkoutDetailsState();
}

class WorkoutDetailsState extends State<WorkoutDetails> {

  List<WorkoutExercises> workoutExercisesJSON = [];
  List<Workouts> workoutInfoJSON = [];

  void updateData() {

    workoutInfoJSON.clear();
    workoutExercisesJSON.clear();

    for (var u in widget.value) {
      Workouts workout = Workouts(u.workoutname, u.musclegroup, u.exNames, u.description);
      workoutInfoJSON.add(workout);
      if (u.workoutname == widget.title) {
        for (int i = 0; i < u.exNames.length; i++) {
          WorkoutExercises exercise = WorkoutExercises(
              name: u.exNames[i].name,
              execution: u.exNames[i].execution,
              weight: u.exNames[i].weight,
              reps: u.exNames[i].reps,
              rest: u.exNames[i].rest,
              sets: u.exNames[i].sets,
              target: u.exNames[i].target);
          workoutExercisesJSON.add(exercise);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    int exerciseNumber = 0;
    updateData();

    return new Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Colors.grey[900],
            title: new Text(widget.title)),
        body: new Stack(children: <Widget>[
          new ListView(children: <Widget>[
            Container(
              padding: const EdgeInsets.all(15.0),
              alignment: Alignment(-1.0, 0.0),
              child: Text("Muscle Group - " + widget.muscleGroup,
                  style: TextStyle(
                      fontFamily: "Prompt",
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
            ),
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsetsDirectional.only(
                  start: 15.0, bottom: 15.0, top: 15.0),
              alignment: Alignment(-1.0, 0.0),
              child: Text(widget.description,
                  style: TextStyle(
                      fontFamily: "Prompt",
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            Container(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: workoutExercisesJSON.length,
                    itemBuilder: (BuildContext context, int index) {
                      exerciseNumber += 1;
                      return Card(
                          elevation: 0.1,
                          child: new Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: new Stack(children: <Widget>[
                                new Column(children: <Widget>[
                                  ListTile(
                                    leading: CircleAvatar(
                                        child: new Text(
                                          "$exerciseNumber",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.blue[900]),
                                    trailing: new CircleAvatar(
                                        backgroundColor: Colors.blue[100],
                                        radius: 20.0,
                                        child: IconButton(
                                            icon: new Text(
                                              "i",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            onPressed: () {
                                              confirmDialog(
                                                  context,
                                                  workoutExercisesJSON[index]
                                                      .name);
                                            })),
                                    title: Text(
                                        workoutExercisesJSON[index].name,
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            fontSize: screenWidth * 0.05,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  ListTile(
                                      subtitle: new Stack(children: <Widget>[
                                    new Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Text(
                                              "Weight: " +
                                                  workoutExercisesJSON[index]
                                                      .weight,
                                              style: TextStyle(
                                                  fontFamily: "Prompt",
                                                  fontSize:
                                                      screenWidth * 0.04)),
                                          new Text(
                                              "Execution: " +
                                                  workoutExercisesJSON[index]
                                                      .execution,
                                              style: TextStyle(
                                                  fontFamily: "Prompt",
                                                  fontSize:
                                                      screenWidth * 0.04)),
                                          new Text(
                                              "Sets: " +
                                                  workoutExercisesJSON[index]
                                                      .sets,
                                              style: TextStyle(
                                                  fontFamily: "Prompt",
                                                  fontSize:
                                                      screenWidth * 0.04)),
                                          new Text(
                                              "Repetitions: " +
                                                  workoutExercisesJSON[index]
                                                      .reps,
                                              style: TextStyle(
                                                  fontFamily: "Prompt",
                                                  fontSize:
                                                      screenWidth * 0.04)),
                                          new Text(
                                              "Rest times: " +
                                                  workoutExercisesJSON[index]
                                                      .rest +
                                                  " seconds between sets",
                                              style: TextStyle(
                                                  fontFamily: "Prompt",
                                                  fontSize:
                                                      screenWidth * 0.04)),
                                          new Padding(
                                            padding: EdgeInsets.only(top: 15.0),
                                            child: new Image(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                    "assets/targets/" +
                                                        workoutExercisesJSON[
                                                                index]
                                                            .target +
                                                        ".png")),
                                          ),
                                        ])
                                  ]))
                                ])
                              ])));
                    }))
          ])
        ]));
  }
}

Future<Null> confirmDialog(BuildContext context, String execution) {
  return showDialog<Null>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(execution),
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
