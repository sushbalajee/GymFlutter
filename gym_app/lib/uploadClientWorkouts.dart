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
    int workoutNumber = 0;
    double screenWidth = MediaQuery.of(context).size.width;

    var split = widget.clientID.split(" - ");
    var clientName = split[0];

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xFF232528),
            title: Text(clientName, style: TextStyle(fontFamily: "Ubuntu"))),
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            Flexible(
              child: FirebaseAnimatedList(
                query: clientWorkoutsRef,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                      workoutNumber += 1;
                  return Card(
                      color: Colors.grey[100],
                      margin: EdgeInsets.all(1.0),
                      shape: new RoundedRectangleBorder(
                          //borderRadius: BorderRadius.all( Radius.circular(25.0))),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25.0),
                              topRight: Radius.circular(25.0))),
                      elevation: 0.6,
                      child: new ListTile(
                        contentPadding: EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 15.0),
                            leading: CircleAvatar(
                                          child: new Text(
                                            "$workoutNumber",
                                            style:
                                                TextStyle(
                                      fontFamily: "Ubuntu",
                                      fontSize: screenWidth * 0.055,
                                      color: Color(0xFFEFCA08),
                                      fontWeight: FontWeight.w600),
                                          ),
                                          backgroundColor: Color(0xFF232528)),
                        trailing: new IconButton(
                            iconSize: 35.0,
                            icon: Icon(Icons.delete_forever),
                            color: Color(0xFF232528),
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
                                fontFamily: "Ubuntu",
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
                width: screenWidth - 20,
                child: new OutlineButton(
                    borderSide: BorderSide(
                      color: Color(0xFF232528), //Color of the border
                      style: BorderStyle
                          .solid, //Style of the border //width of the border
                    ),
                    child: new Text("Sessions",
                        style: TextStyle(
                          fontFamily: "Ubuntu",
                          fontSize: screenWidth * 0.050,
                          fontWeight: FontWeight.w600,
                        )),
                    color: Color(0xFF232528),
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
                padding: EdgeInsets.only(bottom: 10.0),
                width: screenWidth - 20,
                child: new FlatButton(
                    child: new Text("Add Workout",
                        style: TextStyle(
                            fontFamily: "Ubuntu",
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    color: Color(0xFF272727),
                    onPressed: () {
                      confirmDialog(context, "Add a new workout");
                    }))
          ],
        ));
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
          return new Scaffold(
            appBar: new AppBar(
                leading: new IconButton(
                  icon: new Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                centerTitle: true,
                backgroundColor: Color(0xFF232528),
                title: new Text(
                  "Create a new workout",
                  style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: "Ubuntu",
                      fontWeight: FontWeight.w500),
                )),
            body: SingleChildScrollView(
                padding: EdgeInsets.all(15.0),
                child: Form(
                  key: formKey,
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: "New Workout Name"),
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
                        width: screenWidth - 30,
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
                            if (formKey.currentState.validate()) {
                              Navigator.of(context).pop();
                            }
                            handleSubmit();
                            setState(() => _UploadClientWorkoutsState());
                            //Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                )),
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
