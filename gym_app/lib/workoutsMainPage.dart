import 'package:flutter/material.dart';
import 'workouts.dart';
//import 'package:http/http.dart' as http;
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
    'Shoulders',
    'Arms',
    'Back',
    'Legs',
    'Core'
  ];

  final List<String> lowerBodyCategories = [
    'Quads',
    'Hamstrings',
    'Calves',
    'Glutes',
    'Abductors',
    'Aductors'
  ];

  final List<String> cardioCategories = [
    'Bike',
    'Row',
    'Swim',
    'Hill Climb',
    'Treadmill',
  ];

  final List<String> picIndexes = ['1', '2', '3', '4', '5', '6', '7'];

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
        body: 
                  new Stack(children: <Widget>[
                    new Column(children: <Widget>[
                      sliderTitles(
                          "Muscle Building", screenHeight * 0.045, screenWidth),
                      horizontalSlider(screenHeight, this.upperBodyCategories,
                          this.picIndexes),
                      sliderTitles(
                          "Weight Loss", screenHeight * 0.045, screenWidth),
                      horizontalSlider(screenHeight, this.lowerBodyCategories,
                          this.picIndexes),
                      sliderTitles("Cardio", screenHeight * 0.045, screenWidth),
                      horizontalSlider(screenHeight, this.cardioCategories,
                          this.picIndexes)
                    ])
                  ])
              
        );
  }
}

//-----------------------------------------------------------------------------------//

Widget sliderTitles(String title, double height, double width) {
  return Card(
      elevation: 0.0,
      child: Container(
        color: Colors.grey[100],
        alignment: Alignment(0.0, 0.0),
        height: height,
        width: width,
        child: new Text(title,
            style: TextStyle(
                fontFamily: "Prompt",
                fontSize: 19.0,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800])),
      ));
}

//-----------------------------------------------------------------------------------//

Widget horizontalSlider(double screenHeight, List<String> titles,
    List<String> picIndex) {
  return Container(
    height: screenHeight * 0.195,
    child: new ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (BuildContext content, int index) =>
          CreateTile(titles[index], picIndex[index]),
      itemCount: titles.length,
    ),
  );
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
        shape: Border.all(
            color: Colors.grey[900], width: 0.1, style: BorderStyle.solid),
        child: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/$picName.jpg"),
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.9), BlendMode.dstATop),
            ),
          ),
          width: screenWidth * 0.40,
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
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              )),
        ));
  }
}
