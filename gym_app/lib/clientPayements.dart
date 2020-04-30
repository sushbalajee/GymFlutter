import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'color_loader_3.dart';
import 'dart:async';
import 'upcomingClientSessions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rich_alert/rich_alert.dart';
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

  Future<Null> informPT(BuildContext context, int ind) {
    return showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
return new RichAlertDialog(
            alertSubtitle: new Text(""),
            alertType: RichAlertType.ERROR,
            alertTitle: new Text(
                "Your client has not confirmed payment for this session"),
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

  /*Future<Null> confirmPayment(BuildContext context, int ind, num changeTo) {
    double screenWidth = MediaQuery.of(context).size.width;
    return showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(
                "Your client has confirmed that they have paid for this session. Press confirm if you have received the payment.\n\nPlease Note: payment is not done within the app"),
            content: Container(
              width: screenWidth,
              padding: EdgeInsets.only(top: 30.0),
              child: new FlatButton(
                child: new Text("Confirm",
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                color: Colors.black,
                onPressed: () {
                  clientSessionsRef.child(items[ind].key).child('paid').set(changeTo);
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
  }*/

  Future<Null> confirmPayment(BuildContext context, int ind, num changeTo) {
    double screenWidth = MediaQuery.of(context).size.width;
    return showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new RichAlertDialog(
            alertTitle: new Text("Confirm Payment?",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
            alertSubtitle: new Text("Please confirm if you have received payment from your client for this session. Please note: payment is not done within the app",
                style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center),
            alertType: RichAlertType.WARNING,
            actions: <Widget>[
              new Padding(
                  padding: EdgeInsets.only(right: 25.0),
                  child: new FlatButton(
                    color: Colors.green,
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )),
              new FlatButton(
                  color: Colors.red,
                  child: const Text('CONFIRM'),
                  onPressed: () {
                    clientSessionsRef
                        .child(items[ind].key)
                        .child('paid')
                        .set(changeTo);
                    handlePayment();
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
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
