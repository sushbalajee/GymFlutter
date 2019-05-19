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
        //backgroundColor: Color(0xFFEFF1F3),
        appBar: AppBar(
          title: Text(widget.title, style: TextStyle(fontFamily: "Ubuntu")),
          backgroundColor: Color(0xFF232528),
        ),
        resizeToAvoidBottomPadding: false,
        body: new Column(children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text("Muscle Group - " + widget.muscleGroup,
                style: TextStyle(
                  fontFamily: "Ubuntu",
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600)),
          ),
          Container(
            //color: Color(0xFF272727),
            decoration: new BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                //                   <--- left side
                color: Colors.grey[300],
                width: 1.0,
              )),
            ),
            padding: EdgeInsets.only(
                top: 5.0, left: 15.0, right: 15.0, bottom: 15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text(widget.description,
                style: TextStyle(
                  fontFamily: "Ubuntu",
                  fontSize: screenWidth * 0.035)),
          ),
          Flexible(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: workoutExercisesJSON.length,
                  itemBuilder: (BuildContext context, int index) {
                    exerciseNumber += 1;
                    return Card(
                        margin: EdgeInsets.all(10.0),
                        shape: new RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(0.0))),
                        elevation: 2.0,
                        child: new Stack(children: <Widget>[
                          new Column(children: <Widget>[
                            Container(
                                color: Color(0xFF232528),
                                child: ListTile(
                                  leading: CircleAvatar(
                                      child: new Text(
                                        "$exerciseNumber",
                                        style: TextStyle(
                                            fontFamily: "Ubuntu",
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF232528)),
                                      ),
                                      backgroundColor: Color(0xFFEFCA08)),
                                  title: Text(workoutExercisesJSON[index].name,
                                      style: TextStyle(
                                          fontFamily: "Ubuntu",
                                          color: Color(0xFFEFCA08),
                                          fontSize: screenWidth * 0.06,
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
                                                fontFamily: "Prompt",
                                                color: Color(0xFF22333B),
                                                fontSize: screenWidth * 0.04),
                                            textAlign: TextAlign.left)),
                                    new Text(
                                        "Repetitions: " +
                                            workoutExercisesJSON[index].reps,
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            color: Color(0xFF22333B),
                                            fontSize: screenWidth * 0.04)),
                                    new Text(
                                        "Rest times: " +
                                            workoutExercisesJSON[index].rest,
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            color: Color(0xFF22333B),
                                            fontSize: screenWidth * 0.04)),
                                    new ExpansionTile(
                                      title: Align(
                                          alignment: Alignment(
                                              -1 - (60 / screenWidth), 0.0),
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                new Text("Execution",
                                                    style: TextStyle(
                                                        fontFamily: "Prompt",
                                                        color:
                                                            Color(0xFF22333B),
                                                        fontSize:
                                                            screenWidth * 0.04))
                                              ])),
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0.0),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                new Text(
                                                    workoutExercisesJSON[index]
                                                        .execution,
                                                    style: TextStyle(
                                                        fontFamily: "Prompt",
                                                        color:
                                                            Color(0xFF22333B),
                                                        fontSize:
                                                            screenWidth * 0.04))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Image.network(
                                        workoutExercisesJSON[index].target),
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
