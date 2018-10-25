import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'jsonLogic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'clientWorkoutDetails.dart';

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
  String keekee;
  var xoxox;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Item("", "","");
    final FirebaseDatabase database = FirebaseDatabase.instance; //Rather then just writing FirebaseDatabase(), get the instance.  
    itemRef = database.reference().child('Workouts').child(widget.userUid);
    itemRef.onChildAdded.listen(_onEntryAdded);
    //itemRef.onChildChanged.listen(_onEntryChanged);
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  /*_onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      items[items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  }*/

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
                      leading: Text("New workout name"),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => item.workoutname = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      leading: Text("Muscle Group"),
                      title: TextFormField(
                        initialValue: '',
                        onSaved: (val) => item.musclegroup = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      leading: Text("Description"),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => item.description = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        //item.autoKey = xoxox;
                        handleSubmit();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return new ListTile(
                  leading: Icon(Icons.message),
                  title: Text(items[index].workoutname),
                  subtitle: Text(items[index].musclegroup),
                   onTap: (){
                     print("KEEKEE: " + items[index].key);
                      Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageFour(
                                            title: items[index].workoutname,
                                            muscleGroup: items[index].musclegroup,
                                            description: items[index].description,
                                            uid: widget.userUid,
                                            keekee: items[index].key,
                                          )));
                   },
                );
              },
            ),
          ),
        ],
      ),
    );
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

    var po = <String, dynamic>{
      'name' : '',
      'reps' : '',
      'sets' : '',
    };

    return {
      "workoutname": workoutname,
      "musclegroup": musclegroup,
      "description": description,
      "exercises": po
    };
  }
  
}


