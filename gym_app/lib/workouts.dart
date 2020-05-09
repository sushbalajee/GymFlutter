import 'package:flutter/material.dart';
import 'workoutDetails.dart';
import 'jsonLogic.dart';
import 'dart:async';
import 'dart:convert';
import 'BuiltinExercises.dart';
import 'color_loader_3.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    double screenWidth = MediaQuery.of(context).size.width;

    String exerciseListName = widget.value;

    return new Scaffold(
        backgroundColor: Color(0xFFEFF1F3),
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFF232528),
            title: new Text(widget.value,
                style: TextStyle(fontFamily: "Montserrat"))),
        body: SafeArea(child: new LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
              child: FutureBuilder(
                  future: fetchPost(widget.value),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    int workoutNumber = 0;
                    if (snapshot.data == null) {
                      return Container(
                        child: new Stack(children: <Widget>[
                      Container(
                          color: Color(0xFFa6808c),
                          alignment: Alignment.center,
                          child: ColorLoader3(
                            dotRadius: 5.0,
                            radius: 20.0,
                          )),
                      Container(
                          padding: EdgeInsets.only(top: 150.0),
                          alignment: Alignment.center,
                          child: new Text("Loading. . .",
                              style: new TextStyle(
                                  fontSize: screenWidth * 0.05, fontFamily: "Montserrat", color: Colors.white, fontWeight: FontWeight.w500)))
                    ]));
                    } else {
                      return Column(children: <Widget>[
                        Container(
                            height: 280,
                            child: ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  workoutNumber += 1;
                                  return Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              width: 0.3,
                                              color: Color(0xFFc9ada7)),
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: new ListTile(
                                          contentPadding: EdgeInsets.only(
                                              top: 0.0, bottom: 0.0, left: 0.0),
                                          leading: Container(
                                            alignment: Alignment.center,
                                            height: 75,
                                            width: 50,
                                            color: Color(0xFFc9ada7),
                                            child: new Text(
                                              "$workoutNumber",
                                              style: TextStyle(
                                                  fontFamily: "Montserrat",
                                                  fontSize: screenWidth * 0.050,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          title: Container(
                                              child: Text(
                                                  snapshot
                                                      .data[index].workoutname,
                                                  style: TextStyle(
                                                      fontFamily: "Montserrat",
                                                      fontSize:
                                                          screenWidth * 0.05,
                                                      color: Color(0xFF22333B),
                                                      fontWeight:
                                                          FontWeight.w600))),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        WorkoutDetails(
                                                            value: workouts,
                                                            title: snapshot
                                                                .data[index]
                                                                .workoutname,
                                                            muscleGroup: snapshot
                                                                .data[index]
                                                                .musclegroup,
                                                            description: snapshot
                                                                .data[index]
                                                                .description)));
                                          }));
                                })),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: screenWidth / 8),
                          color: Color(0xFFa6808c),
                          height: constraints.maxHeight - 280,
                          width: screenWidth,
                          child: FlatButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BuiltinExercises(
                                              value: widget.value,
                                            )));
                              },
                              icon: SvgPicture.asset(
                                "assets/weightlifter.svg",
                                color: Colors.white,
                                height: constraints.maxWidth / 5,
                              ),
                              label: Text(
                                "  $exerciseListName:\n  Exercise List",
                                style: TextStyle(
                                  fontSize: screenWidth / 15,
                                  fontFamily: "Montserrat",
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                        ),
                      ]);
                    }
                  }));
        })));
  }
}
