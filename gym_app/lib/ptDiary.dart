import 'package:flutter/material.dart';
import 'upcomingClientSessions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:table_calendar/table_calendar.dart';

class PTDiary extends StatefulWidget {
  final String ptID;

  PTDiary({this.ptID});

  @override
  _PTDiaryState createState() => new _PTDiaryState();
}

class _PTDiaryState extends State<PTDiary> {

  List<Session> items = List();
  DatabaseReference itemRef;
  DatabaseReference comingUpRef;
  Session item;
  String updatedPath;
  bool boolVar = false;
  var _key;

  List<Session> newListOf = List();

  AnimationController _animationController;
  CalendarController _calendarController;

  DateTime dd;
  DateTime startDate = DateTime.now().subtract(Duration(days: 10));
  DateTime endDate = DateTime.now().add(Duration(days: 10));
  DateTime selectedDate = DateTime.now();
  
  void initState() {
    super.initState();


    
    

    _calendarController = CalendarController();

    initialDate();

    item = Session("", "", "", "", "", 0, "");


    
  }

  _onEntryAdded(Event event) {
    //newListOf.clear();
    newListOf.add(Session.fromSnapshot(event.snapshot));
  }

var actualDayOfWeek1;

  void _onDaySelected(DateTime day, List events) {
    setState(() {

      var daynew = day.toString().substring(8,10);
      var monthnew = day.toString().substring(5,7);
      var yearnew = day.toString().substring(2,4);
      updatedPath = "$daynew" + "-" + "$monthnew" + "-" + "$yearnew";

      //var actualDayOfWeek1;
      DateTime dd = day;
      //print(dd.weekday);


    switch (dd.weekday) {
        case 1:
          actualDayOfWeek1 = "Monday";
          break;
        case 2:
          actualDayOfWeek1 = "Tuesday";
          break;
        case 3:
          actualDayOfWeek1 = "Wednesday";
          break;
        case 4:
          actualDayOfWeek1 = "Thursday";
          break;
        case 5:
          actualDayOfWeek1 = "Friday";
          break;
        case 6:
          actualDayOfWeek1 = "Saturday";
          break;
        case 7:
          actualDayOfWeek1 = "Sunday";
          break;
      }
      print(updatedPath + " " + actualDayOfWeek1);
    });

    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClientSessions(
                                ptID: widget.ptID,
                                day: actualDayOfWeek1,
                                date: updatedPath,
                                clientList: clientList,
                              )));

  }


  initialDate(){
    
    var daynew = selectedDate.toString().substring(8,10);
    var monthnew = selectedDate.toString().substring(5,7);
    var yearnew = selectedDate.toString().substring(2,4);

    updatedPath = "$daynew" + "-" + "$monthnew" + "-" + "$yearnew";
    //print("xxx1" + updatedPath);

    comingUpRef = database
        .reference()
        .child('Workouts')
        .child(widget.ptID)
        .child("ComingUp")
        .child("$updatedPath");
         _key = Key("$updatedPath");
        
    comingUpRef.onChildAdded.listen(_onEntryAdded);

  }

  onSelect(data) {
    var daynew = data.toString().substring(8,10);
    var monthnew = data.toString().substring(5,7);
    var yearnew = data.toString().substring(2,4);
    //var dayOfWeek1;
    var actualDayOfWeek1;

    DateTime dd = data;
    //print(dd.weekday);


    switch (dd.weekday) {
        case 1:
          actualDayOfWeek1 = "Monday";
          break;
        case 2:
          actualDayOfWeek1 = "Tuesday";
          break;
        case 3:
          actualDayOfWeek1 = "Wednesday";
          break;
        case 4:
          actualDayOfWeek1 = "Thursday";
          break;
        case 5:
          actualDayOfWeek1 = "Friday";
          break;
        case 6:
          actualDayOfWeek1 = "Saturday";
          break;
        case 7:
          actualDayOfWeek1 = "Sunday";
          break;
      }

    updatedPath = "$daynew" + "-" + "$monthnew" + "-" + "$yearnew";
    comingUpRef = database
        .reference()
        .child('Workouts')
        .child(widget.ptID)
        .child("ComingUp")
        .child("$updatedPath");
    
    _key = Key("$updatedPath");

  }


  //DatabaseReference itemRef;
  DatabaseReference clearOld;
  
  final FirebaseDatabase database = FirebaseDatabase.instance;

  List<String> clientList = [''];
  List<String> calendar28Day = [];
  List<String> calendar28Date = [];

  getNext28Days() {
    var now = new DateTime.now();

    for (int i = 0; i < 28; i++) {
      var daysFromNow = now.add(new Duration(days: i));
      var day = daysFromNow.day;
      var month = daysFromNow.month;
      var year = daysFromNow.year;
      var dayOfWeek = daysFromNow.weekday;
      var actualDayOfWeek;
      var modifiedDay;
      var modifiedMonth;

      if(day < 10){
        modifiedDay = "0" + day.toString();
      }
      else{
        modifiedDay = day;
      }

      if(month < 10){
        modifiedMonth= "0" + month.toString();
      }
      else{
        modifiedMonth = month;
      }

      switch (dayOfWeek) {
        case 1:
          actualDayOfWeek = "Monday";
          break;
        case 2:
          actualDayOfWeek = "Tuesday";
          break;
        case 3:
          actualDayOfWeek = "Wednesday";
          break;
        case 4:
          actualDayOfWeek = "Thursday";
          break;
        case 5:
          actualDayOfWeek = "Friday";
          break;
        case 6:
          actualDayOfWeek = "Saturday";
          break;
        case 7:
          actualDayOfWeek = "Sunday";
          break;
      }

      String calendarDay = (actualDayOfWeek);

      String calendarDate = (modifiedDay.toString() +
          "-" +
          modifiedMonth.toString() +
          "-" +
          year.toString().substring(year.toString().length - 2));

      calendar28Day.add(calendarDay);
      calendar28Date.add(calendarDate);
    }
  }

  updateClients() {
    clientList.clear();

    itemRef = database.reference().child('Workouts').child(widget.ptID);

   itemRef.once().then((DataSnapshot snapshot) {
      
  Map<dynamic, dynamic> values = snapshot.value;
     values.forEach((key,values) {
      clientList.add(key.toString());
      if (clientList.contains("ComingUp")) {
          clientList.remove("ComingUp");
        }
      });});


    /*itemRef.onValue.listen((Event event) {
      var value = event.snapshot.value;
      var uids = value.keys;
      for (var clientIDs in uids) {
        clientList.add(clientIDs.toString());
        print("CC : " + uids.toString());
        if (clientList.contains("ComingUp")) {
          clientList.remove("ComingUp");
        }
      }
    });*/
  }

  Future cleanUpOldSessions() async {

    clearOld = database.reference().child('Workouts').child(widget.ptID).child('ComingUp');

    var nowDay = DateTime.now().day;
    var nowMonth = DateTime.now().month;
    var nowYear = int.parse(DateTime.now().year.toString().substring(2,4));

    List uuiiCode;

    final response =
        await http.get('https://gymapp-e8453.firebaseio.com/Workouts/' +
            widget.ptID +
            '/ComingUp'
            '.json');

    var jsonResponse = json.decode(response.body);
    if (jsonResponse != "") {
      ComingUp post = new ComingUp.fromJson(jsonResponse);
      uuiiCode = post.uiCode;
    }

    for (int i = 0; i < uuiiCode.length; i++){

      int dbDay = int.parse(uuiiCode[i].toString().substring(0,2));
      int dbMonth = int.parse(uuiiCode[i].toString().substring(3,5));
      int dbYear = int.parse(uuiiCode[i].toString().substring(6,8));

      if(nowDay > dbDay && nowMonth > dbMonth && nowYear > dbYear){ 

        clearOld.child(uuiiCode[i]).remove();

      }
    }

  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      //onVisibleDaysChanged: _onVisibleDaysChanged,
      //onCalendarCreated: _onCalendarCreated,
    );
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    calendar28Day.clear();
    calendar28Date.clear();

    updateClients();
    initialDate();

    getNext28Days();

    return Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFF14171A),
            title: new Text("My Diary",
                style: TextStyle(fontFamily: "Montserrat"))),
        backgroundColor: Colors.grey[100],
        body: 
      Column(children: [
      _buildTableCalendar(),
      /*Flexible(
            child: FirebaseAnimatedList(
              key: _key,
              query: comingUpRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                items.sort((a, b) => a.startTime.compareTo(b.startTime));

                return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(width: 0.3, color: Color(0xFF767B91)),
                      ),
                      color: Colors.white,
                    ),
                    child: new ListTile(
                      contentPadding: EdgeInsets.only(left: 10.0),
                      title: Text(items[index].clientName,
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenWidth * 0.05,
                              color: Color(0xFF22333B),
                              fontWeight: FontWeight.w500)),
                      subtitle: Text(items[index].startTime.substring(10, 16) +
                          " -" +
                          items[index].endTime.substring(10, 16)),
                    ));
              },
            ),
          ),*/
          
      
      ],)
        
        /*Container( color: Color(0xFF788aa3), child: new GridView.count(
          childAspectRatio: 1.1,
          crossAxisCount: 4,
          children: new List<Widget>.generate(28, (index) {
            double screenWidth = MediaQuery.of(context).size.width;
            return new GridTile( 
              child: new Container(
                  child: new FlatButton(
                    color: Colors.white,
                shape: new RoundedRectangleBorder(
                  side: BorderSide(color: Color(0xFF767B91), width: 0.3),
                    borderRadius: new BorderRadius.circular(0.0)),
                child: new Center( 
                  child: new Text(
                      calendar28Day[index].substring(0, 3) +
                          "\n" +
                          calendar28Date[index]
                              .substring(0, calendar28Date[index].length - 3),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w500)),
                ),
                onPressed: () {
                  print(calendar28Day[index] + calendar28Date[index]);
                  /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClientSessions(
                                ptID: widget.ptID,
                                day: calendar28Day[index],
                                date: calendar28Date[index],
                                clientList: clientList,
                              )));*/
                },
              )),
            );
          }),
        ))*/);
  }
}

class ComingUp{
  List uiCode;
  ComingUp({this.uiCode});

  factory ComingUp.fromJson(Map<String, dynamic> parsedJson) {
    
    List<String> passMe = parsedJson.keys.toList();
    return ComingUp(uiCode: passMe);
  }
}