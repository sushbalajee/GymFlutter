import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'color_loader_3.dart';
import 'dart:async';
import 'upcomingClientSessions.dart';

//-----------------------------------------------------------------------------------//

class ClientPayments extends StatefulWidget {
  final String userUid;
  final String value;

  ClientPayments({Key key, this.value, this.userUid})
      : super(key: key);

  @override
  _ClientPaymentsState createState() => new _ClientPaymentsState();
}

//-----------------------------------------------------------------------------------//

class _ClientPaymentsState extends State<ClientPayments> {
  List<Session> items = List();
  Session item;

  DatabaseReference itemRef;
  DatabaseReference cref;
  DatabaseReference comingUpRef;

  bool informUser;

  Timer timer;
  String msg = "Loading";
  List uuiiCode;

  String jointID;

  @override
  void initState(){
    super.initState();

    print(widget.userUid);

    timer = new Timer(const Duration(seconds: 5), () {
      //setState(() {
      msg = "No workouts assigned to you";
      //});
    });

    item = Session("", "", "", "", "", 0, "");

    final FirebaseDatabase database = FirebaseDatabase.instance;

      //jointID = snapshot.value + " - " + widget.userUid;

      itemRef = database
          .reference()
          .child('Workouts')
          .child(widget.value)
          .child(widget.userUid)
          .child('clientSessions');

      itemRef.onChildAdded.listen(_onEntryAdded);

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
                query: itemRef,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  items.sort((a, b) => a.date
                      .substring(a.date.length - 8, a.date.length)
                      .compareTo(
                          b.date.substring(b.date.length - 8, b.date.length)));

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
                                informPT(context, index, "Your client has not confirmed payment for this session");
                              }
                              else if (items[index].paid == 0xFFFFE66D){
                                confirmPayment(context, index, "Confirm", "Your client has confirmed that they have paid for this session. Press confirm if you have received the payment.\n\nPlease Note: payment is not done within the app", 0xFF4ECDC4);
                              }
                            }),
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

 Future<Null> informPT(BuildContext context, int ind, String msg) {
    double screenWidth = MediaQuery.of(context).size.width;
    return showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(msg
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
                  itemRef.child(items[ind].key).child('paid').set(changeTo);
                  //print(comingUpRef.child('16-1-19').child().key);
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
            builder: (context) => ClientPayments(
                  userUid: widget.userUid,
                  value: widget.value,
                )));
  }

  Widget tryMe() {
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
