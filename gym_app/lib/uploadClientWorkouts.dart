import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'uploadClientWorkoutDetails.dart';
import 'dart:async';

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
        .child(widget.userUid);
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text('Workouts', style: TextStyle(fontFamily: "Montserrat")),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Flexible(
            child: FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return new ListTile(
                  trailing: new IconButton(
                     iconSize: 45.0,
                       icon: Icon(Icons.delete_forever),
                       color: Colors.grey[900],
                      onPressed: () {
                        if(items.length == 1){
                          print("Please add a new workout before deleting this one");
                        }
                        else{
                          itemRef.child(items[index].key).remove();  
                          Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ClientWorkouts(
                                              userUid: widget.userUid,
                                              value: widget.value,
                                            )));
                      }}),

                  title: Text(items[index].workoutname,
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.w700)),
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
                );
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
                  color: Colors.black,
                  onPressed: () {
                    confirmDialog(context, "Add a new workout");
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
            title: new Text(execution, style: TextStyle(fontFamily: "Montserrat")),
            content: SingleChildScrollView(
                child: Form(
              key: formKey,
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[

                  TextFormField(
                      decoration: InputDecoration( labelText: "New Workout Name"),
                      initialValue: "",
                      onSaved: (val) => item.workoutname = val,
                      validator: (val) => val == "" ? val : null,
                    ),

                   TextFormField(
                      decoration: InputDecoration( labelText: "Muscle Group"),
                      initialValue: '',
                      onSaved: (val) => item.musclegroup = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                  
                    TextFormField(
                      decoration: InputDecoration( labelText: "Description"),
                      initialValue: "",
                      onSaved: (val) => item.description = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                  Container(
                width: screenWidth,
                padding: EdgeInsets.only(top: 30.0),
                child: new FlatButton(child: 
                new Text("Submit", style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenWidth *0.045,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                color: Colors.black,
                    onPressed: () {
                        handleSubmit();
                        setState(() => _NextPageStateClient());
                    },
                  ),
                  )],
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
