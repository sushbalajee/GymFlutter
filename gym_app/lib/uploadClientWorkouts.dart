import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'uploadClientWorkoutDetails.dart';
import 'dart:async';
import 'clientPayements.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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

    item = Item("", "");

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
        appBar: AppBar(
            backgroundColor: Color(0xFF14171A),
            title:
                Text(clientName, style: TextStyle(fontFamily: "Montserrat"))),
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            Flexible(
              child: FirebaseAnimatedList(
                query: clientWorkoutsRef,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  int workoutNumber = index + 1;
                  return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(width: 0.3, color: Color(0xFF005792)),
                        ),
                        color: Colors.white,
                      ),
                      child: new ListTile(
                        contentPadding:
                            EdgeInsets.only(top: 0.0, bottom: 0.0, left: 0),
                        leading: Container(
                          alignment: Alignment.center,
                          height: 75,
                          width: 50,
                          color: Color(0xFF005792),
                          child: new Text(
                            "$workoutNumber",
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenWidth * 0.050,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          //backgroundColor: Color(0xFF767B91)
                        ),
                        trailing: new IconButton(
                            iconSize: 25.0,
                            icon: Icon(Icons.delete_forever),
                            color: Color(0xFFC7CCDB),
                            onPressed: () {
                              confirmDelete(
                                    context, "Delete Workout?", index);
                            }),
                        title: Text(items[index].workoutname,
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenWidth * 0.050,
                                color: Color(0xFF2A324B),
                                fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      UploadClientWorkoutDetails(
                                        title: items[index].workoutname,
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
                color: Color(0xFF005792),
                height: 75,
                width: screenWidth,
                child: FlatButton.icon(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      confirmDialog(context, "Add a new workout");
                    },
                    label: new Text("Add Workout",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Montserrat",
                          fontSize: screenWidth * 0.050,
                          fontWeight: FontWeight.w600,
                        )))),
            Container(
              color: Color(0xFF003459),
              height: 75,
              width: screenWidth,
              child: FlatButton.icon(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClientPayments(
                                clientID: widget.clientID,
                                ptID: widget.ptID,
                              )));
                },
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                ),
                label: new Text("Sessions",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Montserrat",
                      fontSize: screenWidth * 0.050,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            )
          ],
        ));
  }

  Future<bool> confirmError(BuildContext context, String why, String subtitle) {
    return new Alert(
      context: context,
      //style: alertStyle,
      closeFunction: () => null,
      type: AlertType.warning,
      title: why,
      desc: subtitle,
      buttons: [
        DialogButton(
          child: Text(
            "Close",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontFamily: "Montserrat"),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: Color(0xFF005792),
          radius: BorderRadius.circular(5.0),
        ),
      ],
    ).show();
  }

  Future<bool> confirmDelete(BuildContext context, String why, int ind) {
    return new Alert(
      context: context,
      closeFunction: () => null,
      type: AlertType.error,
      title: why,
      desc:
          "Are you sure you want to delete this workout and all of its exercises?",
      buttons: [
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontFamily: "Montserrat"),
          ),
          onPressed: () {
            handleDelete(ind);
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: Color(0xFF005792),
          radius: BorderRadius.circular(5.0),
        ),
      ],
    ).show();
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
                backgroundColor: Color(0xFF14171A),
                title: new Text(
                  "Create a new workout",
                  style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: "Montserrat",
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
                        validator: (value) => value.isEmpty
                            ? 'Workout name can\'t be empty'
                            : null,
                        onSaved: (val) => item.workoutname = val,
                      ),
                      Container(
                        height: 200,
                        child:
                      TextFormField(
                        maxLines: 12,
                        decoration: InputDecoration(labelText: "Description", alignLabelWithHint: true),
                        initialValue: "",
                        onSaved: (val) => item.description = val,
                        validator: (val) => val == "" ? val : null,
                      )),
                      Container(
                        padding: EdgeInsets.only(top: 20.0),
                        width: screenWidth,
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
                              if (formKey.currentState.validate()) {
                                Navigator.of(context).pop();
                              }
                              handleSubmit();
                              setState(() => _UploadClientWorkoutsState());
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5.0))),
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
  String description;

  Item(this.workoutname, this.description);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        workoutname = snapshot.value["workoutname"],
        description = snapshot.value["description"];

  toJson() {
    return {
      "workoutname": workoutname,
      "description": description,
    };
  }
}
