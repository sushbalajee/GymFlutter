import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'personalisedWorkoutDetails.dart';
import 'uploadClientWorkouts.dart';
import 'color_loader_3.dart';
import 'dart:async';
import 'upcomingClientSessions.dart';
//-----------------------------------------------------------------------------------//

class ClientSessionsClientSide extends StatefulWidget {
  final String userUid;
  final String value;

  ClientSessionsClientSide({Key key, this.value, this.userUid}) : super(key: key);

 @override
  _ClientSessionsStateClient createState() => new _ClientSessionsStateClient();
}

//-----------------------------------------------------------------------------------//

class _ClientSessionsStateClient extends State<ClientSessionsClientSide> {

  List<Session> items = List();
  Session item;
  
  DatabaseReference itemRef;
  DatabaseReference cref;

  bool informUser;

  Timer timer;
  String msg = "Loading";

  String jointID;

  @override
  void initState() {
    super.initState();

  timer = new Timer(const Duration(seconds: 5), () {
      setState(() {
        msg = "No workouts assigned to you";
      });
    });

    item = Session("", "", "", "", "","");

    final FirebaseDatabase database = FirebaseDatabase.instance;

    cref = database
        .reference()
        .child('Workouts')
        .child('ClientNames')
        .child(widget.userUid);
    cref.once().then((DataSnapshot snapshot) {
      jointID = snapshot.value + " - " + widget.userUid;

      itemRef = database
          .reference()
          .child('Workouts')
          .child(widget.value)
          .child(jointID)
          .child("clientSessions");
      itemRef.onChildAdded.listen(_onEntryAdded);
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Session.fromSnapshot(event.snapshot));
      informUser = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    if (informUser == false) {
      return Scaffold(
        backgroundColor: Color(0xFFEFF1F3),
        appBar: AppBar(
          backgroundColor: Color(0xFF4A657A),
          title: Text('My Personalised Workouts',style: TextStyle(fontFamily: "Montserrat")),
          
        ),
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            Flexible(
              child: FirebaseAnimatedList(
                query: itemRef,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                      items.sort((a, b) => a.date.substring(a.date.length - 8, a.date.length).compareTo(b.date.substring(b.date.length - 8, b.date.length)));

                  return Card(
                      elevation: 3.0,
                       child: 
                  new ListTile(
                    title: Text(items[index].date,
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenWidth * 0.055,
                          color: Color(0xFF22333B),
                          fontWeight: FontWeight.w600)),
                    subtitle: Text(items[index].startTime.substring(10, 15) + " - " + items[index].endTime.substring(10, 15)),
                  ));
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text('My Personalised Workouts'),
            backgroundColor: Colors.grey[900],
          ),
          resizeToAvoidBottomPadding: false,
          body: tryMe());
    }
  }

  Widget tryMe(){
    return Container(
                        child: new Stack(children: <Widget>[
                      Container(
                          alignment: Alignment.center,
                          child: ColorLoader3(
                            dotRadius: 5.0,
                            radius: 20.0,
                          )),
                      Container(
                          padding: EdgeInsets.only(top: 100.0),
                          alignment: Alignment.center,
                          child: new Text(msg,
                              style: new TextStyle(
                                  fontSize: 20.0, fontFamily: "Montserrat"))),
                    ]));
  }
}


