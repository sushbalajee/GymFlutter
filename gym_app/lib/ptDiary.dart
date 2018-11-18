import 'package:flutter/material.dart';
import 'upcomingClientSessions.dart';

class PTDiary extends StatefulWidget {
  @override
  _PTDiaryState createState() => new _PTDiaryState();
}

class _PTDiaryState extends State<PTDiary> {


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
          actualDayOfWeek = "Mon";
          break;
        case 2:
          actualDayOfWeek = "Tues";
          break;
        case 3:
          actualDayOfWeek = "Wed";
          break;
        case 4:
          actualDayOfWeek = "Thurs";
          break;
        case 5:
          actualDayOfWeek = "Fri";
          break;
        case 6:
          actualDayOfWeek = "Sat";
          break;
        case 7:
          actualDayOfWeek = "Sun";
          break;
      }

      String calendarDay =  (actualDayOfWeek);

      String calendarDate = (day.toString() +
          "/" +
          month.toString()
          );
      
      calendar28Day.add(calendarDay);
      calendar28Date.add(calendarDate);
    }
    
  }

  @override
  Widget build(BuildContext context) {

    calendar28Day.clear();
    calendar28Date.clear();

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
          childAspectRatio: 1.0,
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
                    child: new Text(calendar28Day[index] + "\n" + calendar28Date[index], textAlign: TextAlign.center, style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w500)),
                  ), onPressed: (){ 
                   Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClientSessions(
                             day: calendar28Day[index],
                             date: calendar28Date[index],
                          )));
                    },
                  )),
            );
          }),
        ));
  }
}
