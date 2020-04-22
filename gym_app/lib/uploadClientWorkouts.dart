import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'uploadClientWorkoutDetails.dart';
import 'dart:async';
import 'clientPayements.dart';
import 'package:rich_alert/rich_alert.dart';

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
                              style: TextStyle(
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
                                confirmError(context, "Error",
                                    "Please add a new workout before deleting this one");
                              } else {
                                confirmDelete(
                                    context, "Delete Workout?", index);
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
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () {
                    confirmDialog(context, "Add a new workout");
                  },
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0)),
                  icon: Icon(Icons.add),
                  label: new Text("Add Workout",
                      style: TextStyle(
                        fontFamily: "Ubuntu",
                        fontSize: screenWidth * 0.050,
                        fontWeight: FontWeight.w600,
                      )),
                  backgroundColor: Color(0xFF22333B),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(left: 10, bottom: 20.0, top: 10),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: FloatingActionButton.extended(
                    heroTag: null,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClientPayments(
                                    clientID: widget.clientID,
                                    ptID: widget.ptID,
                                  )));
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0)),
                    icon: Icon(Icons.calendar_today),
                    label: new Text("Sessions",
                        style: TextStyle(
                          fontFamily: "Ubuntu",
                          fontSize: screenWidth * 0.050,
                          fontWeight: FontWeight.w600,
                        )),
                    backgroundColor: Color(0xFF22333B),
                  ),
                )),
          ],
        ));
  }

  Future<Null> confirmError(BuildContext context, String why, String subtitle) {
    return showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new RichAlertDialog(
            alertTitle: new Text(why,
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
            alertSubtitle: new Text(subtitle,
                style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center),
            alertType: RichAlertType.WARNING,
            actions: <Widget>[
              new FlatButton(
                color: Color(0xFF232528),
                child:
                    const Text('CLOSE', style: TextStyle(color: Colors.white)),
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
          return new RichAlertDialog(
            alertTitle: new Text(why,
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
            alertSubtitle: new Text(
                "Are you sure you want to delete this workout\nand all of its exercises?",
                style: TextStyle(fontSize: 15.0),
                textAlign: TextAlign.center),
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
                  child: const Text('DELETE'),
                  onPressed: () {
                    handleDelete(ind);
                    Navigator.of(context).pop();
                  }),
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
                        validator: (value) => value.isEmpty ? 'Workout name can\'t be empty' : null,
                        onSaved: (val) => item.workoutname = val,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Muscle Group"),
                        initialValue: "",
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
