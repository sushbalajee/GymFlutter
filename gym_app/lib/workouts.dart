import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'workoutDetails.dart';
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

  Future fetchPost() async {
    final response =
        await http.get('https://gymapp-e8453.firebaseio.com/Workouts.json');
        //await http.get('https://api.jsonbin.io/b/5bb16ced9353c37b743879df');
    var jsonResponse = json.decode(response.body);
    WorkoutCategory post = new WorkoutCategory.fromJson(jsonResponse);

    users.clear();
    for (var u in post.workouts) {
      Workouts www = Workouts(
          u.workoutname, u.musclegroup, u.listOfExercises, u.description);
      users.add(www);
    }

    return users;
  }

//-----------------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {

    int workoutNumber = 0;

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    //loadData(widget.value);
    return new Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Colors.grey[900],
            title: new Text(widget.value)),
        body: Container(
          child: FutureBuilder(
              future: fetchPost(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null){
                  return new Stack(children: <Widget>[
                  Center(child: ColorLoader2(
                      color1: Colors.red,
                      color2: Colors.green,
                      color3: Colors.yellow
                    )),
                    Container(
                      alignment: Alignment(0.0, 0.15),
                      child:new Text("Loading...", style: TextStyle(fontSize: 20.0))
                    )
                  ]);
                } else {
                  
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        workoutNumber += index;
                        return ListTile(
                            title: Text(snapshot.data[index].workoutname, style: TextStyle(
                                      fontFamily: "Prompt",
                                      fontSize: screenWidth * 0.055,
                                      fontWeight: FontWeight.w700)),
                                      leading: CircleAvatar(child: Text("$workoutNumber")),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageThree(
                                            value: users,
                                            title: snapshot.data[index].workoutname,
                                            muscleGroup: snapshot.data[index].musclegroup,
                                            description: snapshot.data[index].description
                                          )));
                            });
                      });
                }
              }),
        ));
  }
}