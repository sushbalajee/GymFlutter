import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'color_loader_3.dart';
import 'dart:async';
import 'upcomingClientSessions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


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
          backgroundColor: Color(0xFF232528),
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
                  return Container(
                    decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(width: 0.3, color: Color(0xFF767B91)),
                        ),
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.all(1.0),
                      child: new ListTile(
                        title: Text(items[index].date,
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenWidth * 0.05,
                                color: Color(0xFF22333B),
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            items[index].startTime.substring(10, 15) +
                                " - " +
                                items[index].endTime.substring(10, 15)),
                        trailing: new IconButton(
                            iconSize: 40.0,
                           icon: SvgPicture.asset(
                              "assets/finance.svg",
                              color: Color(items[index].paid)),
                            color: Color(items[index].paid),
                            onPressed: () {
                              if (items[index].paid == 0xFFFF6B6B) {
                                confirmPayment(context, index, "I have paid", "Please confirm if you have paid your Personal Trainer for this session", 0xFFFFE66D, "Unpaid", AlertType.error);
                              }
                              else if (items[index].paid == 0xFFFFE66D){
                                confirmPayment(context, index, "Undo", "You have confirmed payment for this session. It is pending acceptance from your trainer. Press Undo if you have not paid for this session", 0xFFFF6B6B, "Payment Confirmed", AlertType.warning);
                              }
                            }),
                      ));
                }
                else{
                  return Container(
                    decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(width: 0.3, color: Color(0xFF767B91)),
                        ),
                        color: Colors.white,
                      ),
                      child: new ListTile(
                        title: Text(items[index].date,
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenWidth * 0.05,
                                color: Color(0xFF22333B),
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            items[index].startTime.substring(10, 15) +
                                " - " +
                                items[index].endTime.substring(10, 15) + " - Past Session", style: TextStyle(color: Colors.red),),
                        trailing:
                        new IconButton(
                            iconSize: 50.0,
                            icon: SvgPicture.asset(
                              "assets/finance.svg",
                              color: Color(items[index].paid)),
                            onPressed: () {
                              if (items[index].paid == 0xFFFF6B6B) {
                                confirmPayment(context, index, "I have paid", "Please confirm if you have paid your Personal Trainer for this session", 0xFFFFE66D, "Unpaid", AlertType.error);
                              }
                              else if (items[index].paid == 0xFFFFE66D){
                                confirmPayment(context, index, "Undo", "You have confirmed payment for this session. It is pending acceptance from your trainer. Press Undo if you have not paid for this session", 0xFFFF6B6B, "Payment Confirmed", AlertType.warning);
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
            title: Text('Upcoming Sessions', style: TextStyle(fontFamily: "Ubuntu")),
            backgroundColor: Color(0xFF232528),
          ),
          resizeToAvoidBottomPadding: false,
          body: loadingScreen());
    }
  }

  Future<bool> confirmPayment(BuildContext context, int ind,String button, String msg, num changeTo, String title, AlertType alert) {
    return new Alert(
      context: context,
      closeFunction: () => null,
      type: alert,
      title: title,
      desc: msg,
      buttons: [
        DialogButton(
          child: Text(
            button,
            style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: "Montserrat"),
          ),
          onPressed: () {Navigator.of(context, rootNavigator: true).pop();
                  clientSessionRef.child(items[ind].key).child('paid').set(changeTo);
                  //setState(() => ClientSessionsClientSide());
                  handlePayment();
          },
          color: Color(0xFF4f5d75),
          radius: BorderRadius.circular(5.0),
        ),
      ],
    ).show();
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
