import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:gym_app/exerciseList.dart';
import 'color_loader_2.dart';

//-----------------------------------------------------------------------------------//

class ExerciseList extends StatefulWidget {
  final String value;

  ExerciseList({Key key, this.value}) : super(key: key);

  @override
  _NextPageState createState() => new _NextPageState();
}

//-----------------------------------------------------------------------------------//

class _NextPageState extends State<ExerciseList> {
  Future<List<Exercises>> loadData(String val) async {
    var data = await http.get("https://gymapp-e8453.firebaseio.com/$val.json");
    var jsonData = json.decode(data.body);

    List<Exercises> exercise = [];

    for (var i in jsonData) {
      Exercises exerciseFromFireBase = Exercises(i["name"], i["description"]);
      //print(ex.name + " " + ex.descrip);
      exercise.add(exerciseFromFireBase);
    }
    return exercise;
  }

//-----------------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    loadData(widget.value);
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.grey[900],
              title: new Text(widget.value)
            ),
        body: Container(
          child: FutureBuilder(
              future: loadData(widget.value),
              builder: (BuildContext context, AsyncSnapshot snapshot) {

                if (snapshot.data == null) {
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
                } 
                else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        subtitle: Text("Testing subtitle"),
                          leading: CircleAvatar(backgroundColor: Colors.blue[900]),
                          title: Text(snapshot.data[index].name));
                    },
                  );
                }
              }),
        ));
  }
}
