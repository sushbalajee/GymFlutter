import 'package:flutter/material.dart';
import 'workouts.dart';

class PageThree extends StatefulWidget {
  final List<Workouts> value;
  final String title;
  final String muscleGroup;
  final String description;

  PageThree(
      {Key key, this.value, this.title, this.muscleGroup, this.description})
      : super(key: key);

  @override
  WorkoutInfo createState() => new WorkoutInfo();
}

class WorkoutInfo extends State<PageThree> {
  List<Workouts> workoutInfoJSON = [];
  List<WorkoutExercises> workoutExercisesJSON = [];

  void updateData() {
    workoutInfoJSON.clear();
    workoutExercisesJSON.clear();

    for (var u in widget.value) {
      Workouts workout =
          Workouts(u.workoutname, u.musclegroup, u.exNames, u.description);
      workoutInfoJSON.add(workout);

      if (u.workoutname == widget.title) {
        for (int i = 0; i < u.exNames.length; i++) {
          //print(u.exNames[i].name);
          WorkoutExercises exercise = WorkoutExercises(
              name: u.exNames[i].name,
              execution: u.exNames[i].execution,
              weight: u.exNames[i].weight,
              reps: u.exNames[i].reps,
              rest: u.exNames[i].rest,
              sets: u.exNames[i].sets);
          workoutExercisesJSON.add(exercise);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
              padding:
                  const EdgeInsetsDirectional.only(start: 15.0, bottom: 15.0),
              alignment: Alignment(-1.0, 0.0),
              child: Text(widget.description,
                  style: TextStyle(
                      fontFamily: "Prompt",
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
            ),
            Container(
                //color: Colors.grey[200],
                //padding: const EdgeInsets.only(top: 15.0),
                child: ListView.builder(
                    //addRepaintBoundaries: false,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: workoutExercisesJSON.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                          elevation: 0.1,
                          child: new Stack(children: <Widget>[
                          new Column( children: <Widget>[
                          ListTile(
                             leading: CircleAvatar(child: new Text("$index"), backgroundColor: Colors.blue),
                              title: Text(workoutExercisesJSON[index].name, 
                                  style: TextStyle(
                                      fontFamily: "Prompt",
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.w700
                                      ))),
                                       ListTile(
                              subtitle: new Stack(children: <Widget>[
                                new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Text(
                                          "Weight: " +
                                              workoutExercisesJSON[index].weight,
                                          style: TextStyle(fontFamily: "Prompt",fontSize: screenWidth * 0.04)),
                                      new Text("Execution: " + workoutExercisesJSON[index].execution, style: TextStyle(fontFamily: "Prompt",fontSize: screenWidth * 0.04)),
                                      new Text("Sets: " +workoutExercisesJSON[index].sets, style: TextStyle(fontFamily: "Prompt",fontSize: screenWidth * 0.04)),
                                      new Text("Repetitions: " +workoutExercisesJSON[index].reps, style: TextStyle(fontFamily: "Prompt",fontSize: screenWidth * 0.04)),
                                      new Text("Rest times: " +workoutExercisesJSON[index].rest + " seconds between sets", style: TextStyle(fontFamily: "Prompt",fontSize: screenWidth * 0.04)),
                                    ])
                              ]))])]));
                    }))
          ])
        ]));
  }
}
