import 'package:flutter/material.dart';
import 'upcomingClientSessions.dart';
import 'package:firebase_database/firebase_database.dart';

class PTDiary extends StatefulWidget {
  final String ptid;

  PTDiary({this.ptid});

  @override
  _PTDiaryState createState() => new _PTDiaryState();
}

class _PTDiaryState extends State<PTDiary> {

  DatabaseReference itemRef;
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

      String calendarDate = (day.toString() + "-" + month.toString() + "-" + year.toString().substring(year.toString().length - 2));

      calendar28Day.add(calendarDay);
      calendar28Date.add(calendarDate);
    }
  }

  updateClients() {
    clientList.clear();

    final FirebaseDatabase database = FirebaseDatabase.instance;
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
                      calendar28Day[index].substring(0,3) + "\n" + calendar28Date[index].substring(0,calendar28Date[index].length-3),
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
