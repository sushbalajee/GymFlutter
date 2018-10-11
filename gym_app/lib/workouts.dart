import 'package:flutter/material.dart';
import 'workoutDetails.dart';
import 'jsonLogic.dart';


//-----------------------------------------------------------------------------------//

class WorkoutsList extends StatefulWidget {

  final String value;
  final List<Workouts> workoutsList;

  WorkoutsList({Key key, this.value, this.workoutsList}) : super(key: key);

  @override
  _NextPageState createState() => new _NextPageState();
}

//-----------------------------------------------------------------------------------//

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
                      itemCount: widget.workoutsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        workoutNumber += index;
                        return ListTile(
                            title: Text(widget.workoutsList[index].workoutname, style: TextStyle(
                                      fontFamily: "Prompt",
                                      fontSize: screenWidth * 0.055,
                                      fontWeight: FontWeight.w700)),
                                      leading: CircleAvatar(child: Text("$workoutNumber")),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageThree(
                                            value: widget.workoutsList,
                                            title: widget.workoutsList[index].workoutname,
                                            muscleGroup: widget.workoutsList[index].musclegroup,
                                            description: widget.workoutsList[index].description
                                          )));
                            });
                  }));
    }
}
