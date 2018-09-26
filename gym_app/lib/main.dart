import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'exercises.dart';

void main() {
  runApp(new MaterialApp(
    home: new GymApp(),
  ));
}

class GymApp extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<GymApp> {

  List<String> names = [
    'Chest',
    'Shoulders',
    'Triceps',
    'Biceps',
    'Back',
    'Core',
    'Forearms'
  ];

  List<String> picNames1 = ['1', '2', '3', '4', '5', '6','7'];

  List<String> names2 = [
    'Bike',
    'Row',
    'Swim',
    'Hill Climb',
    'Treadmill',
  ];

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return new MaterialApp(
        title: "Getting started with Firebase",
        home: new Scaffold(
          //backgroundColor: Colors.grey[200],
          appBar: new AppBar(
            backgroundColor: Colors.red[700],
            title: new Text("GymApp V1.0"),
          ),
          body: new Stack(children: <Widget>[
            //Start of horizontal sliders
            new Column(children: <Widget>[
              sliderTitles("Upper Body", screenHeight * 0.05, screenWidth),
              horizontalSlider(screenHeight, this.names, this.picNames1),
              sliderTitles("Lower Body", screenHeight * 0.05, screenWidth),
              horizontalSlider(screenHeight, this.names2, this.picNames1),
              sliderTitles("Cardio", screenHeight * 0.05, screenWidth),
              horizontalSlider(screenHeight, this.names2, this.picNames1)
            ])
          ]),
          bottomNavigationBar: 
          new Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme
            .of(context)
            .textTheme
            .copyWith(caption: new TextStyle(color: Colors.white)),
        // sets the background color of the `BottomNavigationBar`
        canvasColor: Colors.red[700]),
            child: new BottomNavigationBar(
            items:[
             new BottomNavigationBarItem(
              icon: new Text("1"),
              title: new Text("Home")
             ),
             new BottomNavigationBarItem(
              icon: new Text("2"),
              title: new Text("Workouts")
             )
            ]
          ),
        )));
  }
}

Widget horizontalSlider(double sh, List<String> xxx, List<String> yyy){

return Container(
                height: sh * 0.20,
                child: new ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (BuildContext content, int index) =>
                      CreateTile(
                          xxx[index], yyy[index]),
                  itemCount: xxx.length,
                ),
              );

}

loadData() async {
  var url = "https://gymapp-e8453.firebaseio.com/Description.json";
  var httpClient = new Client();
  var response = await httpClient.get(url);
  print('Response' + response.body);
}

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
            onPressed: (){Navigator.push(context, MaterialPageRoute(builder:(context) => ExerciseList(value: name,)));
            },
          //padding: const EdgeInsets.all(30.0),
          child: SizedBox(
            child: Container(
              alignment: AlignmentDirectional.center,
              child: Text(
                name,
                style: TextStyle(
                  fontFamily: "Prompt",
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          )),
    ));
  }
}

Widget sliderTitles(String title, double hh, double ww) {

  return Card(
    elevation: 1.0,
    //color: Colors.grey[200],
      child: Container(
    alignment: Alignment(0.0, 0.0),
    height: hh,
    width: ww,
    child: new Text(title,
        style: TextStyle(
          fontFamily: "Prompt",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800])),
  ));
}