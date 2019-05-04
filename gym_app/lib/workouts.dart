import 'package:flutter/material.dart';
import 'workoutDetails.dart';
import 'jsonLogic.dart';
import 'dart:async';
import 'dart:convert';

class WorkoutsList extends StatefulWidget {
  final String value;

  WorkoutsList({Key key, this.value}) : super(key: key);

  @override
  _WorkoutsListState createState() => new _WorkoutsListState();
}

//-----------------------------------------------------------------------------------//

class _WorkoutsListState extends State<WorkoutsList> {

  final List<Workouts> workouts = [];

  Future fetchPost(String hitMe) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/JSON/testingLocal.json");
    var jsonResponse = json.decode(data);
    WorkoutCategory post = new WorkoutCategory.fromJson(jsonResponse, hitMe);

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
      backgroundColor: Color(0xFFEFF1F3),
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFF232528),
            title: new Text(widget.value, style: TextStyle(fontFamily: "Ubuntu"))),
        body: Container(
            child: FutureBuilder(
                future: fetchPost(widget.value),
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
                          //workoutNumber += index;
                          return Card(
                            color: Colors.grey[100],
                      margin: EdgeInsets.all(1.0),
                            shape: new RoundedRectangleBorder(
                    //borderRadius: BorderRadius.all( Radius.circular(25.0))),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                    elevation: 0.6,
                          child: new ListTile(
                              title: Text(snapshot.data[index].workoutname,
                                  style: TextStyle(
                                      fontFamily: "Ubuntu",
                                      fontSize: screenWidth * 0.055,
                                      color: Color(0xFF22333B),
                                      fontWeight: FontWeight.w600)),
                              contentPadding: EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 15.0),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WorkoutDetails(
                                            value: workouts,
                                            title: snapshot
                                                .data[index].workoutname,
                                            muscleGroup: snapshot
                                                .data[index].musclegroup,
                                            description: snapshot
                                                .data[index].description)));
                              }));
                        });
                  }
                })));
  }
}
