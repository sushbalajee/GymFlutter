import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:gym_app/workoutsList.dart';
import 'color_loader_2.dart';

//-----------------------------------------------------------------------------------//

class WorkoutsList extends StatefulWidget {
  final String value;

  WorkoutsList({Key key, this.value}) : super(key: key);

  @override
  _NextPageState createState() => new _NextPageState();
}

//-----------------------------------------------------------------------------------//

class Workouts {
  String workoutname;
  String musclegroup;
  List<WorkoutExercises> exNames;

  Workouts(this.workoutname, this.musclegroup, this.exNames);
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
  final List<WorkoutExercises> listOfExercises;

  Wkouts({this.workoutname, this.musclegroup, this.listOfExercises});

  factory Wkouts.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['exercises'] as List;
    List<WorkoutExercises> finalLevel =
        list.map((i) => WorkoutExercises.fromJson(i)).toList();

    return Wkouts(
        musclegroup: parsedJson['musclegroup'],
        workoutname: parsedJson['workoutname'],
        listOfExercises: finalLevel);
  }
}

class WorkoutExercises {
  final String name;

  WorkoutExercises({this.name});

  factory WorkoutExercises.fromJson(Map<String, dynamic> parsedJson) {
    return WorkoutExercises(name: parsedJson['name']);
  }
}

class _NextPageState extends State<WorkoutsList> {
  Future fetchPost() async {
    final response =
        await http.get('https://gymapp-e8453.firebaseio.com/Legs.json');
    var jsonResponse = json.decode(response.body);
    WorkoutCategory post = new WorkoutCategory.fromJson(jsonResponse);

    List<Workouts> users = [];

    for (var u in post.workouts) {
      Workouts www = Workouts(u.workoutname, u.musclegroup, u.listOfExercises);
      users.add(www);
      for (int i = 0; i < u.listOfExercises.length; i++) {
        print(u.listOfExercises[i].name);
      }
    }

    return users;
  }

//-----------------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    //loadData(widget.value);
    return new Scaffold(
        appBar: new AppBar(
            backgroundColor: Colors.grey[900], title: new Text(widget.value)),
        body: Container(
          child: FutureBuilder(
              future: fetchPost(),
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
                        return ListTile(
                            title: Text(snapshot.data[index].workoutname));
                      });
                }
              }),
        ));
  }
}
