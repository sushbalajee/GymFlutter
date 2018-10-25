import 'package:flutter/material.dart';
import 'dart:async';
import 'jsonLogic.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'jsonLogic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'clientWorkoutDetails.dart';

class PageFour extends StatefulWidget {
  //final List<Workouts> value;
  final String keekee;
  final String uid;
  final String title;
  final String muscleGroup;
  final String description;

  PageFour(
      {Key key, this.title, this.muscleGroup, this.description, this.uid, this.keekee})
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
    item = Item("", "","");
    final FirebaseDatabase database = FirebaseDatabase.instance; //Rather then just writing FirebaseDatabase(), get the instance.  
    
    snek = database.reference().child('Workouts').child(widget.uid);
    itemRef = database.reference().child('Workouts').child(widget.uid).child(widget.keekee).child('exercises');
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


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FB example'),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 0,
            child: Center(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    ListTile(
                      leading: Text("name"),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => item.name = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      leading: Text("reps"),
                      title: TextFormField(
                        initialValue: '',
                        onSaved: (val) => item.reps = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      leading: Text("sets"),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => item.sets = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        handleSubmit();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          /*Flexible(
            child: FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return new ListTile(
                  leading: Icon(Icons.message),
                  title: Text(items[index].name),
                  subtitle: Text(items[index].reps),
                );
              },
            ),
          )*/
        ],
      ),
    );
  }
}


class Item {
  String key;
  String name;
  String reps;
  String sets;

  Item(this.name, this.reps, this.sets);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value["name"],
        reps = snapshot.value["reps"],
        sets = snapshot.value["sets"];

  toJson() {

    return {
      "name": name,
      "reps": reps,
      "sets": sets,
    };
  }
  
}



