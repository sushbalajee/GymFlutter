import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'exercises.dart';

//-----------------------------------------------------------------------------------//

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(new MaterialApp(
      home: new GymApp(),
    ));
  });
}

//-----------------------------------------------------------------------------------//

class GymApp extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

//-----------------------------------------------------------------------------------//

class HomePageState extends State<GymApp> {

  List<String> upperBodyCategories = [
    'Chest',
    'Shoulders',
    'Triceps',
    'Biceps',
    'Back',
    'Core',
    'Forearms'
  ];
  List<String> lowerBodyCategories = [
    'Quads',
    'Hamstrings',
    'Calves',
    'Glutes',
    'Abductors',
    'Aductors'
  ];
  List<String> cardioCategories = [
    'Bike',
    'Row',
    'Swim',
    'Hill Climb',
    'Treadmill',
  ];

  List<String> picIndexes = ['1', '2', '3', '4', '5', '6', '7'];

  //-----------------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return new MaterialApp(

        title: "Gym Application V1.0",

        home: new Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: new AppBar(
              backgroundColor: Colors.grey[900],
              title: new Text("GymApp V1.0"),
            ),

            //Main section with titles and horizontal sliders
            body: new Stack(children: <Widget>[
              new Column(children: <Widget>[
                sliderTitles("Upper Body", screenHeight * 0.05, screenWidth),
                horizontalSlider(
                    screenHeight, this.upperBodyCategories, this.picIndexes),
                sliderTitles("Lower Body", screenHeight * 0.05, screenWidth),
                horizontalSlider(
                    screenHeight, this.lowerBodyCategories, this.picIndexes),
                sliderTitles("Cardio", screenHeight * 0.05, screenWidth),
                horizontalSlider(
                    screenHeight, this.cardioCategories, this.picIndexes)
              ])
            ]),

            //Bottom navigation bar
            bottomNavigationBar: new Theme(
              data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.copyWith(
                    caption: new TextStyle(color: Colors.white)),
                  canvasColor: Colors.grey[900]),
              child: new BottomNavigationBar(fixedColor: Colors.white, items: [
                new BottomNavigationBarItem(
                    icon: new Text("1"), 
                    title: new Text("Home")),
                new BottomNavigationBarItem(
                    icon: new Text("2"), 
                    title: new Text("Workouts"))
              ]),
            )));
  }
}

//-----------------------------------------------------------------------------------//

Widget horizontalSlider(double screenHeight, List<String> titles, List<String> picIndex) {

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
                        builder: (context) => ExerciseList(
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