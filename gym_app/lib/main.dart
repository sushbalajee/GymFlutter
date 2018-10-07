import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'workoutsMainPage.dart';
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

  int currentTab = 0;

  PageOne one;
  PageTwo two;
  List<Widget> pages;
  Widget currentPage;

  @override
  void initState(){
    one = PageOne();
    two = PageTwo();

    pages = [one, two];

    currentPage = one;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return new MaterialApp(

        title: "Gym Application V1.0",

        home: new Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: new AppBar(
              centerTitle: true,
              backgroundColor: Colors.grey[900],
              title: new Text("GymApp V1.0"),
            ),

            body: currentPage, 

            //Bottom navigation bar
            bottomNavigationBar: new Theme(
              data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.copyWith(
                    caption: new TextStyle(color: Colors.white)),
                  canvasColor: Colors.grey[900]),
              child: new BottomNavigationBar(
                currentIndex: currentTab, 
                onTap: (int index){
                  setState((){
                    currentTab = index;
                    currentPage = pages[index];
                    });
                },
                 items: [
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

class PageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.0,
      color: Colors.purple,
    );
  }
}



