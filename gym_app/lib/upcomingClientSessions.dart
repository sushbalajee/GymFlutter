import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class ClientSessions extends StatefulWidget {

  final String date;
  final String day;
  final String ptID;
  final List<String> clientList;

  ClientSessions({this.date, this.day, this.ptID, this.clientList});

  @override
  _ClientSessionsState createState() => new _ClientSessionsState();
}

class _ClientSessionsState extends State<ClientSessions> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<String> clist;

  DatabaseReference comingUpRef;
  DatabaseReference clientSessionsRef;
  DatabaseReference sessionsRef1;

  String selectedText;
  String localStart;
  String clientID;
  String firstHalf;
  String thisText = "Please select a client";

  List<Session> items = List();
  Session item;

    List<String> clientList1 = [''];
    DatabaseReference itemRef;

  final FirebaseDatabase database = FirebaseDatabase.instance;

  final timeFormat = DateFormat.jm();

  void initState() {
    super.initState();

    item = Session("", "", "", "", "", 0, "");

    comingUpRef = database
        .reference()
        .child('Workouts')
        .child(widget.ptID)
        .child("ComingUp")
        .child(widget.date);
    comingUpRef.onChildAdded.listen(_onEntryAdded);
  }

  _onEntryAdded(Event event) {
    items.add(Session.fromSnapshot(event.snapshot));
  }

  @override
  Widget build(BuildContext context) {


    double screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFF232528),
            title: new Text(widget.day + " : " + widget.date,
                style: TextStyle(fontFamily: "Montserrat"))),
        backgroundColor: Colors.white,
        body: Column(children: <Widget>[
          Form(
            key: formKey,
            child: Container(
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                    width: screenWidth,
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                      hint: Text(thisText),
                      value: null,
                      items: widget.clientList.map((String value) {
                        
                        var splitID = value.toString().split(" - ");
                        firstHalf = splitID[0];
                        return new DropdownMenuItem<String>(
                            value: value.toString(),
                            child: new Text(firstHalf));
                      }).toSet().toList(),
                      onChanged: (String val) {
                        if(this.mounted){
                        setState(() {
                          selectedText = val;
                          var splitID1 = val.toString().split(" - ");
                          var firstHalf1 = splitID1[0];
                          item.clientName = firstHalf1;
                          item.fullClientID = selectedText;
                          clientID = selectedText;
                          selectedText = firstHalf1;
                          thisText = selectedText;
                        });
                                            }},
                    )
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    width: screenWidth,
                    child: DateTimeField(
                      format: timeFormat,
                      decoration: InputDecoration(hintText: 'Start Time',hintStyle: TextStyle(fontFamily: "Montserrat")),
                      autovalidate: true,
                      validator: (DateTime value) {
                        if (value == null) {
                          return 'Please select a start time';
                        }
                        return null;
                      },
                      onSaved: (t) {
                        if(this.mounted){
                        setState(() {
                          item.startTime = t.toString();
                          localStart = t.toString();
                        });
                      }},
                      onShowPicker: (context, currentValue) async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()),
                          builder: (BuildContext context, Widget child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: const Color(0xFF23395b),
                                accentColor: const Color(0xFF23395b),
                                colorScheme: ColorScheme.light(
                                    primary: const Color(0xFF23395b)),
                                buttonTheme: ButtonThemeData(
                                    textTheme: ButtonTextTheme.primary),
                              ),
                              child: child,
                            );
                          },
                        );
                        return DateTimeField.convert(time);
                      },
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                    width: screenWidth,
                    child: DateTimeField(
                      format: timeFormat,
                      decoration: InputDecoration(hintText: 'End Time', hintStyle: TextStyle(fontFamily: "Montserrat")),
                      autovalidate: true,
                      validator: (DateTime value) {
                        if (value == null) {
                          return 'Please select an end time';
                        }
                        return null;
                      },
                      onSaved: (t) {
                        if(this.mounted){
                        setState(() {
                          item.endTime = t.toString();
                          print(t.toString());
                        });
                      }},
                      onShowPicker: (context, currentValue) async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()),
                          builder: (BuildContext context, Widget child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: const Color(0xFF23395b),
                                accentColor: const Color(0xFF23395b),
                                colorScheme: ColorScheme.light(
                                    primary: const Color(0xFF23395b)),
                                buttonTheme: ButtonThemeData(
                                    textTheme: ButtonTextTheme.primary),
                              ),
                              child: child,
                            );
                          },
                        );
                        return DateTimeField.convert(time);
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10.0),
                    width: screenWidth - 20,
                    child: new FlatButton(
                        padding: EdgeInsets.all(10.0),
                        child: new Text("Submit",
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                        color: Color(0xFF005792),
                        onPressed: () {
                          item.date = widget.day + " : " + widget.date;
                          item.paid = 0xFFFF6B6B;
                          if (selectedText != null) {
                            handleSubmit();
                          }
                        },
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(5.0))),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              query: comingUpRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                items.sort((a, b) => a.startTime.compareTo(b.startTime));

                return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(width: 0.3, color: Color(0xFF767B91)),
                      ),
                      color: Colors.white,
                    ),
                    child: new ListTile(
                      contentPadding: EdgeInsets.only(left: 10.0),
                      trailing: new IconButton(
                          iconSize: 25.0,
                          icon: Icon(Icons.delete_forever),
                          color: Color(0xFFC7CCDB),
                          onPressed: () {
                            var clientSessionFBKey =
                                items[index].clientSessionID;
                            handleDelete(index, clientSessionFBKey);
                          }),
                      title: Text(items[index].clientName,
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenWidth * 0.05,
                              color: Color(0xFF22333B),
                              fontWeight: FontWeight.w500)),
                      subtitle: Text(items[index].startTime.substring(10, 16) +
                          " -" +
                          items[index].endTime.substring(10, 16)),
                    ));
              },
            ),
          ),
        ]));
  }

  void handleDelete(int ii, String clientSessionKey) {
    sessionsRef1 = database
        .reference()
        .child('Workouts')
        .child(widget.ptID)
        .child(comingUpRef.child(items[ii].fullClientID).key)
        .child("clientSessions")
        .child(clientSessionKey);

    comingUpRef.child(items[ii].key).remove();
    sessionsRef1.remove();

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ClientSessions(
                  ptID: widget.ptID,
                  day: widget.day,
                  date: widget.date,
                  clientList: widget.clientList,
                )));
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;

    clientSessionsRef = database
        .reference()
        .child('Workouts')
        .child(widget.ptID)
        .child(clientID)
        .child("clientSessions");

    if (form.validate()) {
      form.save();
      form.reset();
      var setSessionKey = clientSessionsRef.push();
      item.clientSessionID = setSessionKey.key;
      setSessionKey.set(item.toJson());
      comingUpRef.push().set(item.toJson());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ClientSessions(
                  ptID: widget.ptID,
                  day: widget.day,
                  date: widget.date,
                  clientList: widget.clientList,
                )));
    }
  }
}

class Session {
  String key;
  String clientName;
  String startTime;
  String endTime;
  String date;
  String fullClientID;
  String clientSessionID;
  num paid;

  Session(this.clientName, this.startTime, this.endTime, this.date,
      this.fullClientID, this.paid, this.clientSessionID);

  Session.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        clientName = snapshot.value["clientName"],
        fullClientID = snapshot.value["fullClientID"],
        startTime = snapshot.value["startTime"],
        endTime = snapshot.value["endTime"],
        date = snapshot.value["date"],
        paid = snapshot.value["paid"],
        clientSessionID = snapshot.value["clientSessionID"];

  toJson() {
    return {
      "clientName": clientName,
      "fullClientID": fullClientID,
      "startTime": startTime,
      "endTime": endTime,
      "date": date,
      "paid": paid,
      "key": key,
      "clientSessionID": clientSessionID
    };
  }
}
