import 'package:flutter/material.dart';
import 'workouts.dart';

class PageThree extends StatefulWidget {
  
  final List<Workouts> value;
  final String title;

  PageThree({Key key, this.value, this.title}) : super(key: key);

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
      Workouts workout = Workouts(u.workoutname, u.musclegroup, u.exNames);
      workoutInfoJSON.add(workout);
      for (int i = 0; i < u.exNames.length; i++) {
        //print(u.exNames[i].name);
        WorkoutExercises exercise = WorkoutExercises(name: u.exNames[i].name);
        workoutExercisesJSON.add(exercise);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

  updateData();

    return new Scaffold(
        appBar: new AppBar(
            backgroundColor: Colors.grey[900], title: new Text(widget.title)),
        body: Container(
          //child: Text(workoutExercisesJSON[0].name),
          child: ListView.builder(
                      itemCount: workoutExercisesJSON.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                            title: Text(workoutExercisesJSON[index].name),
                            );
        })
        )); 
}}