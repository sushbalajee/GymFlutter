import 'package:flutter/material.dart';
import 'workouts.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';

class PageTwo extends StatefulWidget {
  @override
  PageTwoState createState() {
    return new PageTwoState();
  }
}

class PageTwoState extends State<PageTwo> {
  var connectionStatus = 'Unknown';
  var connectivity;
  StreamSubscription<ConnectivityResult> subscription;

  final List<String> upperBodyCategories = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Abs'
  ];

  final List<String> lowerBodyCategories = [
    'Fat Loss',
    'Mass Gain',
    'Power Lifting',
    'HIIT',
    'Body Builder',
    'Athlete Body'
  ];

  final List<String> cardioCategories = [
    'One Day: Full-body ',
    'Two-day split: Upper body/Lower body',
    'Three-day split: Push/Pull/Legs',
    'Four-day split: Full body',
  ];

  final List<String> picIndexes = ['1', '2', '3', '4', '5', '6'];

  @override
  Widget build(BuildContext context) {
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      connectionStatus = result.toString();
    });

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return new Scaffold(
        backgroundColor: Colors.grey[100],
        body: new Stack(children: <Widget>[
          new Column(children: <Widget>[
            sliderTitles(
                "MUSCLE GROUP FOCUS", screenHeight * 0.045, screenWidth),
            horizontalSlider(
                screenHeight, this.upperBodyCategories, this.picIndexes),
            sliderTitles("GOAL FOCUS", screenHeight * 0.045, screenWidth),
            horizontalSlider(
                screenHeight, this.lowerBodyCategories, this.picIndexes),
            sliderTitles(
                "MUSCLE SPLITS", screenHeight * 0.045, screenWidth),
            horizontalSlider(
                screenHeight, this.cardioCategories, this.picIndexes)
          ])
        ]));
  }
}

//-----------------------------------------------------------------------------------//

Widget sliderTitles(String title, double height, double width) {
  return Container(
    
    alignment: Alignment(0.0, 0.0),
    height: height,
    width: width,
    child: new Text(title,
        style: TextStyle(
            fontFamily: "Prompt",
            fontSize: 19.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF232528))),
  );
}

//-----------------------------------------------------------------------------------//

Widget horizontalSlider(
    double screenHeight, List<String> titles, List<String> picIndex) {
  return Card(
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(0.0)),
      elevation: 15.0,
      margin: EdgeInsets.only(bottom: 0.0, left: 0.0, right: 0.0),
      child: Container(
        margin: EdgeInsets.all(5),
        height: screenHeight * 0.204,
        child: new ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (BuildContext content, int index) =>
              CreateTile(titles[index], picIndex[index]),
          itemCount: titles.length,
        ),
      ));
}

//-----------------------------------------------------------------------------------//

class CreateTile extends StatelessWidget {
  final String name;
  final String picName;

  CreateTile(this.name, this.picName);

  //@override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Card(
        child: new Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("assets/$picName.jpg"),
          fit: BoxFit.cover,
          colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.9), BlendMode.dstATop),
        ),
      ),
      width: screenWidth * 0.96,
      child: FlatButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WorkoutsList(
                          value: name,
                        )));
          },
          child: SizedBox(
            child: Container(
              alignment: AlignmentDirectional.center,
              child: Text(
                name,
                style: TextStyle(
                    fontFamily: "Prompt",
                    fontSize: 0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          )),
    ));
  }
}
