import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'dart:async';

class PageFour extends StatefulWidget {
  final String firebaseGeneratedKey;
  final String uid;
  final String title;
  final String muscleGroup;
  final String description;
  final String trainerID;

  PageFour(
      {Key key,
      this.title,
      this.muscleGroup,
      this.description,
      this.uid,
      this.trainerID,
      this.firebaseGeneratedKey})
      : super(key: key);

  @override
  UploadedWorkoutInfo createState() => new UploadedWorkoutInfo();
}

class UploadedWorkoutInfo extends State<PageFour> {
  List<Item> items = List();
  Item item;
  DatabaseReference itemRef;
  DatabaseReference snek;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Item("", "", "", "", "", "", "");
    final FirebaseDatabase database = FirebaseDatabase
        .instance; //Rather then just writing FirebaseDatabase(), get the instance.

    snek = database
        .reference()
        .child('Workouts')
        .child(widget.trainerID)
        .child(widget.uid);

    itemRef = database
        .reference()
        .child('Workouts')
        .child(widget.trainerID)
        .child(widget.uid)
        .child(widget.firebaseGeneratedKey)
        .child('exercises');

    itemRef.onChildAdded.listen(_onEntryAdded);
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      itemRef.push().set(item.toJson());
    }
  }

  void handleEdit(String fbKey) {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      itemRef.child(fbKey).update(item.toJson());
    }

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => PageFour(
                  description: widget.description,
                  firebaseGeneratedKey: widget.firebaseGeneratedKey,
                  key: widget.key,
                  muscleGroup: widget.muscleGroup,
                  title: widget.title,
                  trainerID: widget.trainerID,
                  uid: widget.uid,
                )));
  }

  @override
  Widget build(BuildContext context) {
    int exerciseNumber = 0;

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text("Muscle Group - " + widget.muscleGroup,
                style: TextStyle(
                    fontFamily: "Prompt",
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.w700,
                    color: Colors.black)),
          ),
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text(widget.description,
                style: TextStyle(
                    fontFamily: "Prompt",
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              query: itemRef,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                exerciseNumber += 1;
                return Card(
                    elevation: 0.1,
                    child: new Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: new Stack(children: <Widget>[
                          new Column(children: <Widget>[
                            ListTile(
                              leading: CircleAvatar(
                                  child: new Text(
                                    "$exerciseNumber",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.blue[900]),
                              trailing: new IconButton(
                                  iconSize: 45.0,
                                  icon: Icon(Icons.delete_forever),
                                  color: Colors.grey[900],
                                  onPressed: () {
                                    /*if (items.length == 1) {
                          //confirmError(context, "Please add a new workout before deleting this one", "");
                        } else {*/
                                    itemRef.child(items[index].key).remove();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PageFour(
                                                  description:
                                                      widget.description,
                                                  firebaseGeneratedKey: widget
                                                      .firebaseGeneratedKey,
                                                  key: widget.key,
                                                  muscleGroup:
                                                      widget.muscleGroup,
                                                  title: widget.title,
                                                  trainerID: widget.trainerID,
                                                  uid: widget.uid,
                                                )));
                                    //}
                                  }),
                              title: Text(items[index].name,
                                  style: TextStyle(
                                      fontFamily: "Prompt",
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.w700)),
                            ),
                            ListTile(
                                subtitle: new Stack(children: <Widget>[
                              new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Text("Weight: " + items[index].weight,
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            fontSize: screenWidth * 0.04)),
                                    new Text(
                                        "Execution: " + items[index].execution,
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            fontSize: screenWidth * 0.04)),
                                    new Text("Sets: " + items[index].sets,
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            fontSize: screenWidth * 0.04)),
                                    new Text(
                                        "Repetitions: " + items[index].reps,
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            fontSize: screenWidth * 0.04)),
                                    new Text(
                                        "Rest times: " +
                                            items[index].rest +
                                            " seconds between sets",
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            fontSize: screenWidth * 0.04)),
                                    new Padding(
                                      padding: EdgeInsets.only(top: 15.0),
                                      child: new Image(
                                          fit: BoxFit.cover,
                                          image: AssetImage("assets/targets/" +
                                              items[index].target +
                                              ".png")),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(left: 00.0),
                                        child: new IconButton(
                                            icon: new Icon(Icons.edit),
                                            onPressed: () {
                                              confirmEdit(context,
                                                  "Edit Exercise", index);
                                            }))
                                  ])
                            ]))
                          ])
                        ])));
              },
            ),
          ),
          Container(
              width: screenWidth,
              child: new FlatButton(
                  child: new Text("+ Add Exercise + ",
                      style: TextStyle(
                          fontFamily: "Prompt",
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  color: Colors.black,
                  onPressed: () {
                    confirmDialog(context, "Add Exercise");
                  }))
        ],
      ),
    );
  }

  Future<Null> confirmDialog(BuildContext context, String execution) {
    double screenWidth = MediaQuery.of(context).size.width;

    return showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(execution,
                style: TextStyle(
                    fontFamily: "Montserrat", fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: "Name"),
                      initialValue: "",
                      onSaved: (val) => item.name = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Reps"),
                      initialValue: '',
                      onSaved: (val) => item.reps = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Sets"),
                      initialValue: "",
                      onSaved: (val) => item.sets = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Execution"),
                      initialValue: "",
                      onSaved: (val) => item.execution = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: "Target Muscle(s)"),
                      initialValue: "",
                      onSaved: (val) => item.target = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Rest"),
                      initialValue: "",
                      onSaved: (val) => item.rest = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Weight"),
                      initialValue: "",
                      onSaved: (val) => item.weight = val,
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
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                padding: EdgeInsets.all(20.0),
                child: const Text('CLOSE',
                    style: TextStyle(fontFamily: "Montserrat")),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<Null> confirmEdit(BuildContext context, String execution, int ind) {
    double screenWidth = MediaQuery.of(context).size.width;

    return showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(execution,
                style: TextStyle(
                    fontFamily: "Montserrat", fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: "Name"),
                      initialValue: items[ind].name,
                      onSaved: (val) => item.name = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Reps"),
                      initialValue: items[ind].reps,
                      onSaved: (val) => item.reps = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Sets"),
                      initialValue: items[ind].sets,
                      onSaved: (val) => item.sets = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Execution"),
                      initialValue: items[ind].execution,
                      onSaved: (val) => item.execution = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: "Target Muscle(s)"),
                      initialValue: items[ind].target,
                      onSaved: (val) => item.target = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Rest"),
                      initialValue: items[ind].rest,
                      onSaved: (val) => item.rest = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Weight"),
                      initialValue: items[ind].weight,
                      onSaved: (val) => item.weight = val,
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
                          handleEdit(items[ind].key);
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                padding: EdgeInsets.all(20.0),
                child: const Text('CLOSE',
                    style: TextStyle(fontFamily: "Montserrat")),
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
  String name;
  String reps;
  String sets;
  String rest;
  String execution;
  String target;
  String weight;

  Item(this.name, this.reps, this.sets, this.rest, this.execution, this.target,
      this.weight);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value["name"],
        reps = snapshot.value["reps"],
        sets = snapshot.value["sets"],
        rest = snapshot.value["rest"],
        execution = snapshot.value["execution"],
        target = snapshot.value["target"],
        weight = snapshot.value["weight"];

  toJson() {
    return {
      "name": name,
      "reps": reps,
      "sets": sets,
      "rest": rest,
      "execution": execution,
      "target": target,
      "weight": weight
    };
  }
}
