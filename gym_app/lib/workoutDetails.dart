import 'package:flutter/material.dart';
import 'dart:async';
import 'jsonLogic.dart';
import 'main.dart';
import 'workoutsMainPage.dart';

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
      Workouts workout =
          Workouts(u.workoutname, u.musclegroup, u.exNames, u.description);
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

    print(screenWidth);

    int exerciseNumber = 0;
    updateData();

    return new Scaffold(
        appBar: AppBar(
          title: Container(
              width: screenWidth,
              child: Stack(children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    width: screenWidth * 0.65,
                    child: Text(widget.title,
                        style: TextStyle(fontFamily: "Montserrat"))),
                new Positioned(
                  right: 10,
                  child: new InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    GymApp(currentPage: PageTwo())),
                            result: (route) => false);
                      },
                      child: Container(child: Icon(Icons.pool))),
                )
              ])),
          backgroundColor: Color(0xFF14171A),
        ),
        resizeToAvoidBottomPadding: false,
        body: new Column(children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text("Muscle Group - " + widget.muscleGroup,
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600)),
          ),
          Container(
            decoration: new BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                color: Colors.grey[300],
                width: 1.0,
              )),
            ),
            padding: EdgeInsets.only(
                top: 5.0, left: 15.0, right: 15.0, bottom: 15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text(widget.description,
                style: TextStyle(
                    fontFamily: "Helvetica Neue", fontSize: screenWidth * 0.04)),
          ),
          Flexible(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: workoutExercisesJSON.length,
                  itemBuilder: (BuildContext context, int index) {
                    exerciseNumber += 1;
                    return Container(
                        color: Colors.white,
                        child: new Stack(children: <Widget>[
                          new Column(children: <Widget>[
                            Container(
                                color: Color(0xFF5E030C),
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(
                                      left: 0, top: 0, bottom: 0),
                                  leading: Container(
                                    alignment: Alignment.center,
                                    width: 50,
                                    color: Color(0xFF9C1C26),
                                    child: new Text(
                                      "$exerciseNumber",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: screenWidth * 0.050,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  title: Text(workoutExercisesJSON[index].name,
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.05,
                                          fontWeight: FontWeight.w600)),
                                )),
                            ListTile(
                                subtitle: new Stack(children: <Widget>[
                              new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: new Text(
                                            "Sets: " +
                                                workoutExercisesJSON[index]
                                                    .sets,
                                            style: TextStyle(
                                                fontFamily: "Helvetica Neue",
                                                color: Color(0xFF22333B),
                                                fontSize: screenWidth * 0.04),
                                            textAlign: TextAlign.left)),
                                    new Text(
                                        "Repetitions: " +
                                            workoutExercisesJSON[index].reps,
                                        style: TextStyle(
                                            fontFamily: "Helvetica Neue",
                                            color: Color(0xFF22333B),
                                            fontSize: screenWidth * 0.04)),
                                    new Text(
                                        "Rest times: " +
                                            workoutExercisesJSON[index].rest,
                                        style: TextStyle(
                                            fontFamily: "Helvetica Neue",
                                            color: Color(0xFF22333B),
                                            fontSize: screenWidth * 0.04)),
                                    Container(
                                    padding: EdgeInsets.only(top: 10),
                                    child: 
                                    new ExpansionTile(
                                      title: Align(
                                          alignment: Alignment(
                                              -1 - (60 / screenWidth), 0.0),
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                new Text("Execution",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                        fontFamily: "Helvetica Neue",
                                                        color:
                                                            Color(0xFF22333B),
                                                        fontSize:
                                                            screenWidth * 0.04))
                                              ])),
                                      children: <Widget>[
                                        new Padding(
                                            padding: EdgeInsets.only(top: 15.0),
                                            child: new Image.network(
                                                workoutExercisesJSON[index]
                                                    .target)),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                new Text(
                                                    workoutExercisesJSON[index]
                                                        .execution,
                                                    style: TextStyle(
                                                        fontFamily: "Helvetica Neue",
                                                        color:
                                                            Color(0xFF22333B),
                                                        fontSize:
                                                            screenWidth * 0.04))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                  ])
                            ]))
                          ])
                        ]));
                  }))
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
