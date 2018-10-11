import 'package:flutter/material.dart';

class PageFour extends StatefulWidget {
  @override
  PersonalWorkouts createState() => new PersonalWorkouts();
}

class PersonalWorkouts extends State<PageFour> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
       appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Colors.grey[900],
            title: new Text("Workouts for Me")),
        body: new Container(
      color: Colors.grey[900],
    ));
  }
}
