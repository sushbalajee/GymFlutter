import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class ClientSessions extends StatefulWidget {
  final String date;
  final String day;
  final String id;
  final List<String> clientList;

  ClientSessions({this.date, this.day, this.id, this.clientList});

  @override
  _ClientSessionsState createState() => new _ClientSessionsState();
}

class _ClientSessionsState extends State<ClientSessions> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DatabaseReference itemRef;
  DatabaseReference sessionsRef;
  DatabaseReference sessionsRef1;
  String _selectedText = "Select a Client";
  String duration = "";

  String localStart;

  String firstHalf;

  List<Session> items = List();
  List<Session> anotheritem = List();
  Session item;

  String clientID;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  final timeFormat = DateFormat.jm();

  void initState() {
    super.initState();

    item = Session("", "", "", "", "", 0, "");

    itemRef = database
        .reference()
        .child('Workouts')
        .child(widget.id)
        .child("ComingUp")
        .child(widget.date);
    itemRef.onChildAdded.listen(_onEntryAdded);
  }

  _onEntryAdded(Event event) {
    //setState(() {
    items.add(Session.fromSnapshot(event.snapshot));
    //});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFF4A657A),
            title: new Text(widget.day + " : " + widget.date,
                style: TextStyle(fontFamily: "Montserrat"))),
        backgroundColor: Colors.grey[100],
        body: Column(children: <Widget>[
          Form(
            key: formKey,
            child: Card(
              elevation: 5.0,
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  Container(
                    //alignment: Alignment.center,
                    padding:
                        EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                    width: screenWidth,
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                      hint: Text(_selectedText),
                      value: null,
                      items: widget.clientList.map((String value) {
                        var splitID = value.toString().split(" - ");
                        firstHalf = splitID[0];
                        return new DropdownMenuItem<String>(
                            value: value.toString(), //firstHalf,
                            child: new Text(firstHalf));
                      }).toList(),
                      onChanged: (String val) {
                        setState(() {
                          _selectedText = val;
                          var splitID1 = val.toString().split(" - ");
                          var firstHalf1 = splitID1[0];
                          item.clientName = firstHalf1;
                          item.fullClientID = _selectedText;
                          clientID = _selectedText;
                          print(firstHalf1);
                        });
                      },
                    )),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    width: screenWidth,
                    child: TimePickerFormField(
                      format: timeFormat,
                      decoration: InputDecoration(hintText: 'Start Time'),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a start time';
                        }
                      },
                      onChanged: (t) {
                        setState(() {
                          item.startTime = t.toString();
                          localStart = t.toString();
                        });
                      },
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                    width: screenWidth,
                    child: TimePickerFormField(
                      format: timeFormat,
                      decoration: InputDecoration(hintText: 'End Time'),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an end time';
                        }
                      },
                      onChanged: (t) {
                        setState(() {
                          item.endTime = t.toString();
                        });
                      },
                    ),
                  ),
                  Container(
                    width: screenWidth - 10.0,
                    //padding: EdgeInsets.only(top: 10.0),
                    child: new FlatButton(
                      child: new Text("Submit",
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      color: Color(0xFF4A657A),
                      onPressed: () {
                        item.date = widget.day + " : " + widget.date;
                        item.paid = 0xFFFF6B6B;
                        handleSubmit();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                items.sort((a, b) => a.startTime.compareTo(b.startTime));

                return Card( 
                  //color: Color(items[index].paid),
                    elevation: 3.0,
                    child: new ListTile(
                      contentPadding: EdgeInsets.only(left: 15.0),
                      trailing: new IconButton(
                          iconSize: 35.0,
                          icon: Icon(Icons.delete_forever),
                          color: Color(0xFF4A657A),
                          onPressed: () {
                            var shitNames = items[index].clientSessionID;
                            handleDelete(index, shitNames);
                          }),
                      title: Text(items[index].clientName,
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenWidth * 0.055,
                              color: Color(0xFF22333B),
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(items[index].startTime.substring(10, 15)),
                      onTap: () {
                        print("todo ?");
                      },
                    ));
              },
            ),
          ),
        ]));
  }

  void handleDelete(int ii, String sucks) {

    sessionsRef1 = database
        .reference()
        .child('Workouts')
        .child(widget.id)
        .child(itemRef.child(items[ii].fullClientID).key)
        .child("clientSessions")
        .child(sucks);

        print(sucks);

    itemRef.child(items[ii].key).remove();
    sessionsRef1.remove();
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;

    sessionsRef = database
        .reference()
        .child('Workouts')
        .child(widget.id)
        .child(clientID)
        .child("clientSessions");
        //.child(widget.day + " : " + widget.date + " - " + localStart);

    if (form.validate()) {
      form.save();
      form.reset();
      var xx = sessionsRef.push();
      item.clientSessionID = xx.key;
      xx.set(item.toJson());
      itemRef.push().set(item.toJson());
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
