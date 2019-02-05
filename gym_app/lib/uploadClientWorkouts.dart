import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'uploadClientWorkoutDetails.dart';
import 'dart:async';
import 'clientPayements.dart';

//-----------------------------------------------------------------------------------//

class UploadClientWorkouts extends StatefulWidget {
  final String clientID;
  final String ptID;

  UploadClientWorkouts({Key key, this.ptID, this.clientID}) : super(key: key);

  @override
  _UploadClientWorkoutsState createState() => new _UploadClientWorkoutsState();
}

//-----------------------------------------------------------------------------------//

class _UploadClientWorkoutsState extends State<UploadClientWorkouts> {
  List<Item> items = List();
  Item item;
  DatabaseReference clientWorkoutsRef;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    item = Item("", "", "");

    final FirebaseDatabase database = FirebaseDatabase.instance;

    clientWorkoutsRef = database
        .reference()
        .child('Workouts')
        .child(widget.ptID)
        .child(widget.clientID)
        .child("clientWorkouts");
    clientWorkoutsRef.onChildAdded.listen(_onEntryAdded);
  }

  _onEntryAdded(Event event) {
    items.add(Item.fromSnapshot(event.snapshot));
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      clientWorkoutsRef.push().set(item.toJson());
    }
  }

  void handleDelete(int ii) {
    clientWorkoutsRef.child(items[ii].key).remove();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UploadClientWorkouts(
                  clientID: widget.clientID,
                  ptID: widget.ptID,
                )));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    var split = widget.clientID.split(" - ");
    var clientName = split[0];

    return Scaffold(
      backgroundColor: Color(0xFFEFF1F3),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A657A),
        title: Text(clientName, style: TextStyle(fontFamily: "Montserrat")),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Flexible(
            child: FirebaseAnimatedList(
              query: clientWorkoutsRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return Card(
                    elevation: 3.0,
                    child: new ListTile(
                      contentPadding:
                          EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0),
                      trailing: new IconButton(
                          iconSize: 35.0,
                          icon: Icon(Icons.delete_forever),
                          color: Color(0xFF4A657A),
                          onPressed: () {
                            if (items.length == 1) {
                              confirmError(
                                  context,
                                  "Please add a new workout before deleting this one",
                                  "");
                            } else {
                              confirmDelete(
                                  context,
                                  "Are you sure you want to delete this Workout?",
                                  index);
                            }
                          }),
                      title: Text(items[index].workoutname,
                          style: TextStyle(  
                              fontFamily: "Montserrat",
                              fontSize: screenWidth * 0.055,
                              color: Color(0xFF22333B),
                              fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.push(
                            context, 
                            MaterialPageRoute(
                                builder: (context) =>
                                    UploadClientWorkoutDetails(
                                      title: items[index].workoutname,
                                      muscleGroup: items[index].musclegroup,
                                      description: items[index].description,
                                      clientID: widget.clientID,
                                      ptID: widget.ptID,
                                      firebaseGeneratedKey: items[index].key,
                                    )));
                      },
                    ));
              },
            ),
          ),
          Container( 
              width: screenWidth,
              child: new FlatButton( 
                  child: new Text("Sessions",
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenWidth * 0.050,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  color: Color(0xFF272727),
                  onPressed: () {
                    Navigator.push( 
                        context, 
                        MaterialPageRoute(
                            builder: (context) => ClientPayments(
                                  clientID: widget.clientID,
                                  ptID: widget.ptID,
                                )));
                  })),
          Container( 
              width: screenWidth,
              child: new FlatButton( 
                  child: new Text("+ Add Workout +",
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  color: Color(0xFF272727),
                  onPressed: () {
                    confirmDialog(context, "Add a new workout");
                  }))
        ],
      ),
    );
  }

  Future<Null> confirmError(
      BuildContext context, String why, String execution) {
    return showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(why),
            content: new Text(execution),
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

  Future<Null> confirmDelete(BuildContext context, String why, int ind) {
    double screenWidth = MediaQuery.of(context).size.width;
    return showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(why),
            content: Container(
              width: screenWidth,
              padding: EdgeInsets.only(top: 30.0),
              child: new FlatButton(
                child: new Text("Delete",
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                color: Colors.black,
                onPressed: () {
                  handleDelete(ind);
                  Navigator.of(context).pop();
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

  Future<Null> confirmDialog(BuildContext context, String execution) {
    double screenWidth = MediaQuery.of(context).size.width;
    return showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title:
                new Text(execution, style: TextStyle(fontFamily: "Montserrat")),
            content: SingleChildScrollView(
                child: Form(
              key: formKey,
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: "New Workout Name"),
                    initialValue: "",
                    onSaved: (val) => item.workoutname = val,
                    validator: (val) => val == "" ? val : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Muscle Group"),
                    initialValue: '',
                    onSaved: (val) => item.musclegroup = val,
                    validator: (val) => val == "" ? val : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Description"),
                    initialValue: "",
                    onSaved: (val) => item.description = val,
                    validator: (val) => val == "" ? val : null,
                  ),
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
                        handleSubmit();
                        setState(() => _UploadClientWorkoutsState());
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            )),
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
}

class Item {
  String key;
  String workoutname;
  String musclegroup;
  String description;

  Item(this.workoutname, this.musclegroup, this.description);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        workoutname = snapshot.value["workoutname"],
        musclegroup = snapshot.value["musclegroup"],
        description = snapshot.value["description"];

  toJson() {
    return {
      "workoutname": workoutname,
      "musclegroup": musclegroup,
      "description": description,
    };
  }
}
