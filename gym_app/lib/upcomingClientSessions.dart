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
  String _selectedText = "Select a Client";
  String duration = "";

  String firstHalf;
  String secondHalf;

  List<Session> items = List();
  List<Session> anotheritem = List();
  Session item;

  String clientID;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  final timeFormat = DateFormat.jm();

  void initState() {
    super.initState();

    item = Session("", "", "", "");
    
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
            title: new Text(widget.day + " - " + widget.date,
                style: TextStyle(fontFamily: "Montserrat"))),
        backgroundColor: Colors.grey[100],
        body:  Column(
        children: <Widget>[
        
              Form(
              key: formKey,
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                    width: screenWidth,
                    child: DropdownButton(
                      hint: Text(_selectedText),
                      value: null,
                      onChanged: (String val) {
                        setState(() {
                          _selectedText = val;
                          item.clientName = _selectedText;
                          clientID = firstHalf + "-" + secondHalf;
                          print(clientID);
                        });
                      },
                      items: widget.clientList.map((String value) {
                        var splitID = value.toString().split("-");
                        firstHalf = splitID[0];
                        secondHalf = splitID[1];
                        return new DropdownMenuItem<String>(
                          value: firstHalf,
                          child: new Text(firstHalf),
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    width: screenWidth,
                    child: TimePickerFormField(
                      format: timeFormat,
                      decoration: InputDecoration(labelText: 'Time'),
                      onChanged: (t) {
                          setState(() {
                            item.time = t.toString();
                          });
                          },
                    ),
                  ),
                  Container(
                      padding:
                          EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                      width: screenWidth,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: "Duration"),
                        initialValue: "",
                        onSaved: (val) => item.duration = val,
                        validator: (val) => val == "" ? val : null,
                      )),
                  Container(
                    width: screenWidth,
                    padding: EdgeInsets.only(top: 30.0),
                    child: new FlatButton(
                      child: new Text("Submit",
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      color: Colors.black,
                      onPressed: () {
                        print(_selectedText);
                        item.date = widget.date + " - " + widget.day;
                        handleSubmit();
                      },
                    ),
                  )
                ],
              ),
            ),

            Flexible( 
            child: FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                    return Card( 
                      elevation: 3.0,
                       child:
                new ListTile(  
                  contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0),
                  trailing: new IconButton(
                      iconSize: 35.0,
                      icon: Icon(Icons.delete_forever),
                      color: Color(0xFF4A657A),
                      onPressed: () {
                        print("todo delete");
                      }),
                  title: 
                  Text(items[index].clientName,
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenWidth * 0.055,
                          color: Color(0xFF22333B),
                          fontWeight: FontWeight.w600)), 
                  subtitle: Text(items[index].time.substring(10,15)),
                  onTap: () {
                    print("todo ?");
                  },
                ));
              },
            ),
          ),
        ]));
  }

  void handleSubmit() {

    final FormState form = formKey.currentState;
    //final FirebaseDatabase database = FirebaseDatabase.instance;

    sessionsRef = database
        .reference()
        .child('Workouts')
        .child(widget.id)
        .child(clientID)
        .child("clientSessions");

    if (form.validate()) {
      form.save();
      form.reset();
      //print(item.workoutname);
      sessionsRef.push().set(item.toJson());
      itemRef.push().set(item.toJson());
    }
  }
}

class Session {
  String key;
  String clientName;
  String time;
  String duration;
  String date;

  Session(this.clientName, this.time, this.duration, this.date);

  Session.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        clientName = snapshot.value["clientName"],
        time = snapshot.value["time"],
        duration = snapshot.value["duration"],
        date = snapshot.value["date"];

  toJson() {
    return {
      "clientName": clientName,
      "time": time,
      "duration": duration,
      "date": date
    };
  }
}