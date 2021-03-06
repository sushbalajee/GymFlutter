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

  String ordering = "Oldest";
  IconData arrowDirection = Icons.arrow_downward;
  String isPast;
  Color isPastCol;

  DatabaseReference clientSessionsRef;

  bool informUser;

  Timer timer;
  String msg = "Loading. . .";

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
          backgroundColor: Color(0xFF14171A),
          title:
              Text('Client Payments', style: TextStyle(fontFamily: "Montserrat", fontSize: screenWidth *0.05)),
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
                    filterDates();
                    checkPast(index);
                                        
                    
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
                                                      fontWeight: FontWeight.w500)),
                                              subtitle: Text(
                                                  items[index].startTime.substring(10, 16) +
                                                      " - " +
                                                      items[index].endTime.substring(10, 16) + isPast, style: TextStyle(color: isPastCol,fontFamily: "Montserrat")),
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
                                    Container(
                                        color: Color(0xFF005792),
                                        padding: EdgeInsets.only(bottom: 10),
                                        width: screenWidth,
                                        child: FlatButton(
                                          child: 
                                          Row( 
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                                          Text("Showing $ordering Sessions First",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Montserrat",
                                                fontSize: screenWidth * 0.050,
                                                fontWeight: FontWeight.w500,
                                              )),
                                              Container( 
                            padding: EdgeInsets.only(left:5)
                            ,child:
                          Icon(arrowDirection, color: Colors.white,))
                                              ]),
                                          onPressed: () {
                                            setState(() {
                                              if (ordering == "Oldest") {
                                                arrowDirection = Icons.arrow_upward;
                                                ordering = "Newest";
                                              } else if (ordering == "Newest") {
                                                ordering = "Oldest";
                                                arrowDirection = Icons.arrow_downward;
                                              }
                                            });
                                          },
                                        ))
                              ],
                            ),
                          );
                        } else {
                          return Scaffold(
                              appBar: AppBar(
                                title: Text('Client Payments', style: TextStyle(fontFamily: "Montserrat", fontSize: screenWidth *0.05)),
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
                              color: Color(0xFF005792),
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
                              color: Color(0xFF005792),
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
                        double screenWidth = MediaQuery.of(context).size.width;
                        return Container(
                            child: new Stack(children: <Widget>[
                          Container(
                            color: Color(0xFF788aa3),
                              alignment: Alignment.center,
                              child: ColorLoader3(
                                dotRadius: 5.0,
                                radius: 20.0,
                              )),
                          Container(
                              padding: EdgeInsets.only(top: 150.0),
                              alignment: Alignment.center,
                              child: new Text(msg,
                                  style: new TextStyle(fontSize: screenWidth * 0.05,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w500,
                  color: Colors.white))),
                        ]));
                      }
                    
                       void filterDates() {
                        if (ordering == "Oldest") {
                    
                    
                          items.sort((a, b) => a.startTime.compareTo(b.startTime));
                          items.sort((a, b) => a.date
                              .substring(a.date.length - 8, a.date.length)
                              .compareTo(b.date.substring(b.date.length - 8, b.date.length)));
                          items.sort((a, b) => a.date
                              .substring(a.date.length - 6, a.date.length)
                              .compareTo(b.date.substring(b.date.length - 6, b.date.length)));
                          items.sort((a, b) => a.date
                              .substring(a.date.length - 2, a.date.length)
                              .compareTo(b.date.substring(b.date.length - 2, b.date.length)));
                        } else if (ordering == "Newest") {
                    
                    
                          items.sort((a, b) => b.startTime.compareTo(a.startTime));
                          items.sort((a, b) => b.date
                              .substring(b.date.length - 8, b.date.length)
                              .compareTo(a.date.substring(a.date.length - 8, a.date.length)));
                          items.sort((a, b) => b.date
                              .substring(b.date.length - 6, b.date.length)
                              .compareTo(a.date.substring(a.date.length - 6, a.date.length)));
                          items.sort((a, b) => b.date
                              .substring(b.date.length - 2, b.date.length)
                              .compareTo(a.date.substring(a.date.length - 2, a.date.length)));
                        }
                      }
                    
                      void checkPast(int index) {

                        var splitColon = items[index].date.split(" : ");
                  var afterColon = splitColon[1];

                  int dbDay = int.parse(afterColon.toString().substring(0, 2));
                  int dbMonth =
                      int.parse(afterColon.toString().substring(3, 5));
                  int dbYear =
                      int.parse("20" + afterColon.toString().substring(6, 8));

                  var testUTC = DateTime.utc(dbYear, dbMonth, dbDay);
                  if (testUTC.isAfter(DateTime.now().toUtc())) {
                    isPast = "";
                    isPastCol = Colors.black;
                  }
                  else{
                     isPast = " - Past Session";
                      isPastCol = Colors.red;
                  }
                      }
}
