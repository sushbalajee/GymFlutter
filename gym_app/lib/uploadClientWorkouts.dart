import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'uploadClientWorkoutDetails.dart';
import 'dart:async';
import 'clientPayements.dart';

//-----------------------------------------------------------------------------------//

class ClientWorkouts extends StatefulWidget {
  final String userUid;
  final String value;

  ClientWorkouts({Key key, this.value, this.userUid}) : super(key: key);

  @override
  _NextPageStateClient createState() => new _NextPageStateClient();
}

//-----------------------------------------------------------------------------------//

class _NextPageStateClient extends State<ClientWorkouts> {
  List<Item> items = List();
  Item item;
  DatabaseReference itemRef;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Item("", "", "");
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRef = database
        .reference()
        .child('Workouts')
        .child(widget.value)
        .child(widget.userUid)
        .child("clientWorkouts");
    itemRef.onChildAdded.listen(_onEntryAdded);
  }

  _onEntryAdded(Event event) {
    //setState(() {
    items.add(Item.fromSnapshot(event.snapshot));
    //});
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      print(item.workoutname);
      itemRef.push().set(item.toJson());
    }
  }

  void handleDelete(int ii) {
    itemRef.child(items[ii].key).remove();
    Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ClientWorkouts(
                                        userUid: widget.userUid,
                                        value: widget.value,
                                      )));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold( backgroundColor: Color(0xFFEFF1F3),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A657A),
        title: Text('Workouts', style: TextStyle(fontFamily: "Montserrat")),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Container(
              width: screenWidth,
              child: new FlatButton(
                  child: new Text("Payments",
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  color: Color(0xFF272727),
                  onPressed: () {
                    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClientPayments(
                  userUid: widget.userUid,
                  value: widget.value,
                )));
                  })),
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
                        if (items.length == 1) {
                          confirmError(
                              context,
                              "Please add a new workout before deleting this one",
                              "");
                        } else {
                          confirmDelete(context, "Are you sure you want to delete this Workout?", index);
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
                            builder: (context) => PageFour(
                                  title: items[index].workoutname,
                                  muscleGroup: items[index].musclegroup,
                                  description: items[index].description,
                                  uid: widget.userUid,
                                  trainerID: widget.value,
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

  Future<Null> confirmDelete(
      BuildContext context, String why, int ind) {

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
                        setState(() => _NextPageStateClient());
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
