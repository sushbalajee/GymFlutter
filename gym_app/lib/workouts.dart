import 'package:flutter/material.dart';
import 'dart:async';
import 'workoutDetails.dart';
import 'package:connectivity/connectivity.dart';

//-----------------------------------------------------------------------------------//

class WorkoutsList extends StatefulWidget {
  final String value;
  final List<Workouts> arrayLi;

  WorkoutsList({Key key, this.value, this.arrayLi}) : super(key: key);

  @override
  _NextPageState createState() => new _NextPageState();
}

//-----------------------------------------------------------------------------------//

class Workouts {
  String workoutname;
  String musclegroup;
  String description;
  List<WorkoutExercises> exNames;

  Workouts(this.workoutname, this.musclegroup, this.exNames, this.description);
}

class WorkoutCategory {
  final List<Wkouts> workouts;

  WorkoutCategory({this.workouts});

  factory WorkoutCategory.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['Legs'] as List;

    List<Wkouts> imagesList = list.map((i) => Wkouts.fromJson(i)).toList();

    return WorkoutCategory(workouts: imagesList);
  }
}

class Wkouts {
  final String musclegroup;
  final String workoutname;
  final String description;
  final List<WorkoutExercises> listOfExercises;

  Wkouts(
      {this.workoutname,
      this.musclegroup,
      this.listOfExercises,
      this.description});

  factory Wkouts.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['exercises'] as List;
    List<WorkoutExercises> finalLevel =
        list.map((i) => WorkoutExercises.fromJson(i)).toList();

    return Wkouts(
        musclegroup: parsedJson['musclegroup'],
        workoutname: parsedJson['workoutname'],
        description: parsedJson['description'],
        listOfExercises: finalLevel);
  }
}

class WorkoutExercises {
  final String name;
  final String reps;
  final String sets;
  final String execution;
  final String weight;
  final String rest;
  final String target;

  WorkoutExercises(
      {this.name,
      this.execution,
      this.reps,
      this.rest,
      this.sets,
      this.weight, 
      this.target});

  factory WorkoutExercises.fromJson(Map<String, dynamic> parsedJson) {
    return WorkoutExercises(
        name: parsedJson['name'],
        execution: parsedJson['execution'],
        reps: parsedJson['reps'],
        sets: parsedJson['sets'],
        weight: parsedJson['weight'],
        rest: parsedJson['rest'],
        target: parsedJson['target']);
  }
}

class _NextPageState extends State<WorkoutsList> {
  List<Workouts> users = [];

//-----------------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {

    int workoutNumber = 0;

    double screenWidth = MediaQuery.of(context).size.width;
    return new Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Colors.grey[900],
            title: new Text(widget.value)),
        body: new ListView.builder(
                      itemCount: widget.arrayLi.length,
                      itemBuilder: (BuildContext context, int index) {
                        workoutNumber += index;
                        return ListTile(
                            title: Text(widget.arrayLi[index].workoutname, style: TextStyle(
                                      fontFamily: "Prompt",
                                      fontSize: screenWidth * 0.055,
                                      fontWeight: FontWeight.w700)),
                                      leading: CircleAvatar(child: Text("$workoutNumber")),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageThree(
                                            value: widget.arrayLi,
                                            title: widget.arrayLi[index].workoutname,
                                            muscleGroup: widget.arrayLi[index].musclegroup,
                                            description: widget.arrayLi[index].description
                                          )));
                            });
                  }));
    }
}