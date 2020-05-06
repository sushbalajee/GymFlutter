import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'color_loader_3.dart';
import 'dart:async';
import 'upcomingClientSessions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

//-----------------------------------------------------------------------------------//

class ClientPayments extends StatefulWidget {
  final String clientID;
  final String ptID;

  ClientPayments({Key key, this.ptID, this.clientID}) : super(key: key);

  @override
  _ClientPaymentsState createState() => new _ClientPaymentsState();
}

//-----------------------------------------------------------------------------------//

class _ClientPaymentsState extends State<ClientPayments> {
  List<Session> items = List();
  //Session item;

  DatabaseReference clientSessionsRef;

  bool informUser;

  Timer timer;
  String msg = "Loading";

  String jointID;

  @override
  void initState() {
    super.initState();

    timer = new Timer(const Duration(seconds: 5), () {
      setState(() {
        msg = "No session history available";
      });
    });

    final FirebaseDatabase database = FirebaseDatabase.instance;

    clientSessionsRef = database
        .reference()
        .child('Workouts')
        .child(widget.ptID)
        .child(widget.clientID)
        .child('clientSessions');

    clientSessionsRef.onChildAdded.listen(_onEntryAdded);
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFF232528),
          title:
              Text('Client Payments', style: TextStyle(fontFamily: "Montserrat")),
        ),
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            Flexible(
              child: FirebaseAnimatedList(
                query: clientSessionsRef,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  if (snapshot.value != null) {
                    items.sort((a, b) => a.date
                        .substring(a.date.length - 8, a.date.length)
                        .compareTo(b.date
                            .substring(b.date.length - 8, b.date.length)));

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
                                  items[index].endTime.substring(10, 15)),
                          trailing: new IconButton(
                              iconSize: 40.0,
                              icon: SvgPicture.asset(
                              "assets/finance.svg",
                              color: Color(items[index].paid)),
                              onPressed: () {
                                if (items[index].paid == 0xFFFF6B6B) {
                                  informPT(context, index);
                                } else if (items[index].paid == 0xFFFFE66D) {
                                  confirmPayment(context, index, 0xFF4ECDC4);
                                }
                              }),
                        ));
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text('Client Payments'),
            backgroundColor: Colors.grey[900],
          ),
          resizeToAvoidBottomPadding: false,
          body: loadingScreen());
    }
  }

  Future<bool> informPT(BuildContext context, int ind) {

     return new Alert(
      context: context,
      //style: alertStyle,
      closeFunction: () => null,
      type: AlertType.warning,
      title: "Unpaid",
      desc: "Your client has not confirmed payment for this session",
      buttons: [
        DialogButton(
          child: Text(
            "Close",
            style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: "Montserrat"),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          color: Color(0xFF4f5d75),
          radius: BorderRadius.circular(5.0),
        ),
      ],
    ).show();
      
  }

  Future<bool> confirmPayment(BuildContext context, int ind, num changeTo) {

    return new Alert(
      context: context,
      //style: alertStyle,
      closeFunction: () => null,
      type: AlertType.warning,
      title: "Confirm Payment",
      desc: "Please confirm if you have received payment from your client for this session.\n\nPlease note: payment is not done within the app",
      buttons: [
        DialogButton(
          child: Text(
            "Confirm",
            style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: "Montserrat"),
          ),
          onPressed: () {

                    clientSessionsRef
                        .child(items[ind].key)
                        .child('paid')
                        .set(changeTo);
                    handlePayment();
            Navigator.of(context, rootNavigator: true).pop();
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
            builder: (context) => ClientPayments(
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
