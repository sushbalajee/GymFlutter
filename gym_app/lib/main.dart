import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'workoutsMainPage.dart';
import 'auth.dart';
import 'home.dart';
import 'root.dart';

//-----------------------------------------------------------------------------------//

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
      .copyWith(systemNavigationBarColor: Color(0xFF232528),
      statusBarColor: Color(0xFF232528)));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
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
  int currentTab = 1;

  PageOne one;
  PageTwo two;
  RootPage login;

  List<Widget> pages;
  Widget currentPage;

  @override
  void initState() {
    one = PageOne();
    two = PageTwo();
    login = RootPage(auth: new Auth());

    pages = [one, two, login];

    currentPage = two;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: new AppBar(
                centerTitle: true,
                backgroundColor: Color(0xFF232528),
                title: new Text(
                  "Gym App v0.1",
                  style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: "Ubuntu",
                      fontWeight: FontWeight.w500),
                )),
            body: currentPage,
            bottomNavigationBar: new Theme(
              data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context)
                      .textTheme
                      .copyWith(caption: new TextStyle(color: Colors.white)),
                  canvasColor: Color(0xFF232528)),
              child: new BottomNavigationBar(
                  fixedColor: Color(0xFFEFCA08),
                  currentIndex: currentTab,
                  onTap: (int index) {
                    setState(() {
                      currentTab = index;
                      currentPage = pages[index];
                    });
                  },
                  items: [
                    new BottomNavigationBarItem(
                        icon: new Icon(Icons.home), title: new Text("Home")),
                    new BottomNavigationBarItem(
                        icon: new Icon(Icons.pool),
                        title: new Text("Workouts")),
                    new BottomNavigationBarItem(
                        icon: new Icon(Icons.people),
                        title: new Text("My Account"))
                  ]),
            )));
  }
}
