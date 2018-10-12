import 'package:flutter/material.dart';
import 'workoutDetails.dart';
import 'jsonLogic.dart';
import 'dart:async';
import 'dart:convert';



//-----------------------------------------------------------------------------------//

class WorkoutsList extends StatefulWidget {

  final String value;

  WorkoutsList({Key key, this.value}) : super(key: key);

  @override
  _NextPageState createState() => new _NextPageState();
}

//-----------------------------------------------------------------------------------//

class _NextPageState extends State<WorkoutsList> {
  List<Workouts> users = [];

    final List<Workouts> workouts = [];

  Future fetchPost(String hitMe) async {

      //final response = await http.get('https://gymapp-e8453.firebaseio.com/Workouts.json');
      //var jsonResponse = json.decode(response.body);
      String data = await DefaultAssetBundle.of(context).loadString("assets/JSON/testingLocal.json");
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
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Colors.grey[900],
            title: new Text(widget.value)),
        body: Container( child:
        FutureBuilder( 
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
                                            value: workouts,
                                            title: snapshot.data[index].workoutname,
                                            muscleGroup: snapshot.data[index].musclegroup,
                                            description: snapshot.data[index].description
                                          )));
                            });
                  });}})));
    }
}
