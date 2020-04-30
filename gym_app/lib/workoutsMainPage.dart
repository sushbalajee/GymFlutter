import 'package:flutter/material.dart';
import 'workouts.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        body: SafeArea(child: new LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return new Stack(children: <Widget>[
            new Column(children: <Widget>[
              horizontalSlider(screenHeight, this.upperBodyCategories,
                  this.picIndexes, screenWidth, constraints),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: screenWidth / 8),
                  width: screenWidth,
                  height: constraints.maxHeight / 3,
                  color: Color(0xFF45537C),
                  child: FlatButton.icon(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        "assets/weightlifter.svg",
                        color: Colors.white,
                        height: screenWidth / 5,
                      ),
                      label: Text(
                        "    Exercise List",
                        style: TextStyle(
                          fontSize: screenWidth / 15,
                          fontFamily: "Montserrat",
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ))),
              Stack(children: <Widget>[
                Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: screenWidth / 8),
                    width: screenWidth,
                    height: constraints.maxHeight / 3,
                    color: Color(0xFF767B91),
                    child: FlatButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: screenWidth / 5,
                        ),
                        label: Text(
                          "    Muscle Splits",
                          style: TextStyle(
                            fontSize: screenWidth / 15,
                            fontFamily: "Montserrat",
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ))),
              ]),
            ])
          ]);
        })));
  }
}

//-----------------------------------------------------------------------------------//

Widget sliderTitles(String title, double height, double width, Color col) {
  return Container(
      color: col,
      alignment: Alignment(0.0, 0.0),
      height: height,
      width: width,
      child: new Text(title,
          style: TextStyle(
              fontFamily: "Prompt",
              fontSize: 19.0,
              fontWeight: FontWeight.w300,
              color: Colors.white)));
}

//-----------------------------------------------------------------------------------//

Widget horizontalSlider(double screenHeight, List<String> titles,
    List<String> picIndex, double screenWidth, BoxConstraints constraints) {
  return Stack(children: <Widget>[
    Container(
        child: (
          Row(children:[
      Container(
        height: constraints.maxHeight / 3,
        width: screenWidth-screenWidth/10,
        child: new ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (BuildContext content, int index) =>
              CreateTile(titles[index], picIndex[index]),
          itemCount: titles.length,
        ),
      ),
      Container(color: Color(0xFF2A324B),
      width: screenWidth/10,
      height: constraints.maxHeight/3,
      child: Icon(Icons.keyboard_arrow_right, size: 50, color: Colors.white,))
    ]))),
  ]);
}

//-----------------------------------------------------------------------------------//

class CreateTile extends StatelessWidget {
  final String name;
  final String picName;

  CreateTile(this.name, this.picName);

  //@override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: screenWidth / 8),
      color: Color(0xFF2A324B),
      width: screenWidth,
      child: FlatButton.icon(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WorkoutsList(
                          value: name,
                        )));
          },
          icon: SvgPicture.asset(
            "assets/$picName.svg",
            color: Colors.white,
            height: screenWidth / 5,
          ),
          label: Text(
            "    $name",
            style: TextStyle(
              fontSize: screenWidth / 15,
              fontFamily: "Montserrat",
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          )),
    );

/*    return Card(
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
                    fontSize: 110,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          )),
    ));*/
  }
}
