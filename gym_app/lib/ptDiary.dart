import 'package:flutter/material.dart';
import 'upcomingClientSessions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class PTDiary extends StatefulWidget {
  final String ptid;

  PTDiary({this.ptid});

  @override
  _PTDiaryState createState() => new _PTDiaryState();
}

class _PTDiaryState extends State<PTDiary> {

  DatabaseReference itemRef;
  DatabaseReference clearOld;

  final FirebaseDatabase database = FirebaseDatabase.instance;

  List<String> clientList = [''];
  List<String> calendar28Day = [];
  List<String> calendar28Date = [];
/*
  @override
  void initState() {
    super.initState();

    clearOld = database.reference().child('Workouts').child(widget.ptid).child('ComingUp');
    clearOld.once().then((DataSnapshot snapshot){
        var checker = snapshot.value;
        if(checker == null){
          print("No sessions");
        }
        else{
          cleanUpOldSessions();
        }
    });
  }*/

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

    itemRef = database.reference().child('Workouts').child(widget.ptid);

    itemRef.onValue.listen((Event event) {
      var value = event.snapshot.value;
      var uids = value.keys;
      for (var clientIDs in uids) {
        //print('client ID: $clientIDs');
        //clientIDs.toString().split("-");
        //var test = clientIDs.toString().split("-");
        clientList.add(clientIDs.toString());
        if (clientList.contains("ComingUp")) {
          clientList.remove("ComingUp");
        }
      }
    });
  }

  Future cleanUpOldSessions() async {

    clearOld = database.reference().child('Workouts').child(widget.ptid).child('ComingUp');

    var nowDay = DateTime.now().day;
    var nowMonth = DateTime.now().month;
    var nowYear = int.parse(DateTime.now().year.toString().substring(2,4));

    List uuiiCode;

    final response =
        await http.get('https://gymapp-e8453.firebaseio.com/Workouts/' +
            widget.ptid +
            '/ComingUp'
            '.json');

    var jsonResponse = json.decode(response.body);
    if (jsonResponse != "") {
      ComingUp post = new ComingUp.fromJson20(jsonResponse);
      uuiiCode = post.uiCode;
    }

    for (int i = 0; i < uuiiCode.length; i++){
      //print("From the DB: " + uuiiCode[i]);
      int dbDay = int.parse(uuiiCode[i].toString().substring(0,2));
      int dbMonth = int.parse(uuiiCode[i].toString().substring(3,5));
      int dbYear = int.parse(uuiiCode[i].toString().substring(6,8));

      if(nowDay > dbDay && nowMonth > dbMonth && nowYear > dbYear){ 

        clearOld.child(uuiiCode[i]).remove();
        print("Test");
      }
    }

  }

  @override
  Widget build(BuildContext context) {

    calendar28Day.clear();
    calendar28Date.clear();

    updateClients();

    getNext28Days();

    GridTile gridtile;

    return Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFF4A657A),
            title: new Text("My Diary",
                style: TextStyle(fontFamily: "Montserrat"))),
        backgroundColor: Colors.grey[100],
        body: new GridView.count(
          gridtile,
          childAspectRatio: 1.1,
          crossAxisCount: 4,
          children: new List<Widget>.generate(28, (index) {
            return new GridTile(
              child: new Card(
                  //color: Colors.blue.shade200,
                  child: new OutlineButton(
                borderSide: BorderSide(color: Color(0xFF4A657A)),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0)),
                child: new Center(
                  child: new Text(
                      calendar28Day[index].substring(0, 3) +
                          "\n" +
                          calendar28Date[index]
                              .substring(0, calendar28Date[index].length - 3),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w500)),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClientSessions(
                                id: widget.ptid,
                                day: calendar28Day[index],
                                date: calendar28Date[index],
                                clientList: clientList,
                              )));
                },
              )),
            );
          }),
        ));
  }
}

class ComingUp{
  List uiCode;
  ComingUp({this.uiCode});

  factory ComingUp.fromJson20(Map<String, dynamic> parsedJson) {
    
    List<String> passMe = parsedJson.keys.toList();
    return ComingUp(uiCode: passMe);
  }
}