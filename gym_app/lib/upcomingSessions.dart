import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'color_loader_3.dart';
import 'dart:async';
import 'upcomingClientSessions.dart';

//-----------------------------------------------------------------------------------//

class ClientSessionsClientSide extends StatefulWidget {
  final String clientID;
  final String ptID;

  ClientSessionsClientSide({Key key, this.ptID, this.clientID})
      : super(key: key);

  @override
  _ClientSessionsStateClient createState() => new _ClientSessionsStateClient();
}

//-----------------------------------------------------------------------------------//

class _ClientSessionsStateClient extends State<ClientSessionsClientSide> {

      var nowDay = DateTime.now().day;
      var nowMonth = DateTime.now().month;
      var nowYear = int.parse(DateTime.now().year.toString().substring(2,4));

  List<Session> items = List();
  //Session item;

  DatabaseReference clientSessionRef;
  DatabaseReference clientNamesRef;

  bool informUser;

  Timer timer;
  String msg = "Loading";

  String jointID;

  @override
  void initState(){
    super.initState();

    timer = new Timer(const Duration(seconds: 5), () {
      msg = "No workouts assigned to you";
    });

    //item = Session("", "", "", "", "", 0, "");

    final FirebaseDatabase database = FirebaseDatabase.instance;

    clientNamesRef = database
        .reference()
        .child('Workouts')
        .child('ClientNames')
        .child(widget.clientID);

    clientNamesRef.once().then((DataSnapshot snapshot){
      jointID = snapshot.value + " - " + widget.clientID;

      clientSessionRef = database
          .reference()
          .child('Workouts')
          .child(widget.ptID)
          .child(jointID)
          .child('clientSessions');

      clientSessionRef.onChildAdded.listen(_onEntryAdded);
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
          title: Text('Upcoming Sessions',
              style: TextStyle(fontFamily: "Montserrat")),
        ),
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            Flexible(
              child: FirebaseAnimatedList(
                query: clientSessionRef,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  items.sort((a, b) => a.date
                      .substring(a.date.length - 8, a.date.length)
                      .compareTo(
                          b.date.substring(b.date.length - 8, b.date.length)));

      var splitColon = items[index].date.split(" : ");
      var afterColon = splitColon[1];

      int dbDay = int.parse(afterColon.toString().substring(0,2));
      int dbMonth = int.parse(afterColon.toString().substring(3,5));
      int dbYear = int.parse("20" + afterColon.toString().substring(6,8));

      var testUTC = DateTime.utc(dbYear, dbMonth, dbDay);
    
      if(testUTC.isAfter(DateTime.now().toUtc())){
                  return Card(
                      color: Color(items[index].paid),
                      elevation: 3.0,
                      child: new ListTile(
                        title: Text(items[index].date,
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenWidth * 0.055,
                                color: Color(0xFF22333B),
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            items[index].startTime.substring(10, 15) +
                                " - " +
                                items[index].endTime.substring(10, 15)),
                        trailing: new IconButton(
                            iconSize: 40.0,
                            icon: Icon(Icons.monetization_on),
                            color: Colors.white,
                            onPressed: () {
                              if (items[index].paid == 0xFFFF6B6B) {
                                confirmPayment(context, index, "I have paid", "Please confirm if you have paid your Personal Trainer for this session", 0xFFFFE66D);
                              }
                              else if (items[index].paid == 0xFFFFE66D){
                                confirmPayment(context, index, "Undo", "You have confirmed payment for this session. It is pending acceptance from your trainer. Press Undo if you have not paid for this session", 0xFFFF6B6B);
                              }
                            }),
                      ));
                }
                else{
                  return Card(
                      color: Color(items[index].paid),
                      elevation: 3.0,
                      child: new ListTile(
                        title: Text(items[index].date,
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenWidth * 0.055,
                                color: Color(0xFF22333B),
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            items[index].startTime.substring(10, 15) +
                                " - " +
                                items[index].endTime.substring(10, 15) + " - Past Session"),
                        trailing: new IconButton(
                            iconSize: 40.0,
                            icon: Icon(Icons.monetization_on),
                            color: Colors.white,
                            onPressed: () {
                              if (items[index].paid == 0xFFFF6B6B) {
                                confirmPayment(context, index, "I have paid", "Please confirm if you have paid your Personal Trainer for this session", 0xFFFFE66D);
                              }
                              else if (items[index].paid == 0xFFFFE66D){
                                confirmPayment(context, index, "Undo", "You have confirmed payment for this session. It is pending acceptance from your trainer. Press Undo if you have not paid for this session", 0xFFFF6B6B);
                              }
                            }),
                      ));
                }},
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
          body: loadingScreen());
    }
  }

  Future<Null> confirmPayment(BuildContext context, int ind,String button, String msg, num changeTo) {
    double screenWidth = MediaQuery.of(context).size.width;
    return showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(msg
                ),
            content: Container(
              width: screenWidth,
              padding: EdgeInsets.only(top: 30.0),
              child: new FlatButton(
                child: new Text(button,
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                color: Colors.black,
                onPressed: () {
                  clientSessionRef.child(items[ind].key).child('paid').set(changeTo);
                  //setState(() => ClientSessionsClientSide());
                  handlePayment();
                  Navigator.pop(context);
                },
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text('CLOSE'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void handlePayment() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ClientSessionsClientSide(
                  clientID: widget.clientID,
                  ptID: widget.ptID,
                )));
  }

  Widget loadingScreen() {
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
              style: new TextStyle(fontSize: 20.0, fontFamily: "Montserrat"))),
    ]));
  }
}
