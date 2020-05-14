import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'workoutsMainPage.dart';
import 'auth.dart';
import 'home.dart';
import 'root.dart';

//-----------------------------------------------------------------------------------//

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Color(0xFF232528),
      statusBarColor: Color(0xFF232528)));
  //SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  // .then((_) {
  runApp(new MaterialApp(
    home: new GymApp(),
  ));
  //});
}

//-----------------------------------------------------------------------------------//

class GymApp extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
  Widget currentPage;

GymApp(
      {Key key, this.currentPage})
      : super(key: key);
}

//-----------------------------------------------------------------------------------//

class HomePageState extends State<GymApp> {
  int currentTab = 2;

  PageOne one;
  PageTwo two;
  RootPage login;

  List<Widget> pages;
  Widget currPage;

  @override
  void initState() {
    one = PageOne();
    two = PageTwo();
    login = RootPage(auth: new Auth());

    pages = [one, two, login];
    if(widget.currentPage == null){
      currPage = login;
    }else{
    currPage = widget.currentPage;}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
            appBar: new AppBar(
                centerTitle: true,
                backgroundColor: Color(0xFF14171A),
                title: new Text(
                  "Trainamate 2.0",
                  style: TextStyle(
                      fontSize: 25.0,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500),
                )),
            backgroundColor: Colors.grey[100],
            body: currPage,
            bottomNavigationBar: 
            new Theme(
              data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context)
                      .textTheme
                      .copyWith(caption: new TextStyle(color: Colors.white)),
                  canvasColor: Color(0xFF14171A)),
              child: new BottomNavigationBar(
                  fixedColor: Color(0xFFc9ada7),
                  currentIndex: currentTab,
                  onTap: (int index) {
                    setState(() {
                      currentTab = index;
                      currPage = pages[index];
                    });
                  },
                  items: [
                    new BottomNavigationBarItem(
                        icon: new Icon(Icons.home),
                        title: new Text("Home",
                            style: TextStyle(
                                fontFamily: "Montserrat", fontSize: 15))),
                    new BottomNavigationBarItem(
                        icon: new Icon(Icons.pool),
                        title: new Text("Workouts",
                            style: TextStyle(
                                fontFamily: "Montserrat", fontSize: 15))),
                    new BottomNavigationBarItem(
                        icon: new Icon(Icons.people),
                        title: new Text("My Account",
                            style: TextStyle(
                                fontFamily: "Montserrat", fontSize: 15)))
                  ]),
            )));
  }
}
