import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'clientWorkoutDetails.dart';
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
    item = Item("", "","");
    final FirebaseDatabase database = FirebaseDatabase.instance; 
    itemRef = database.reference().child('Workouts').child(widget.userUid);
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
      print(item.workoutname);
      itemRef.push().set(item.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {

    int workoutNumber = 0;
    double screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('FB example'),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
        
          Flexible(
            child: FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                workoutNumber += 1;
                return new ListTile(
                  leading: CircleAvatar(child: Text("$workoutNumber")),
                  title: Text(items[index].workoutname,style: TextStyle(
                                      fontFamily: "Prompt",
                                      fontSize: screenWidth * 0.055,
                                      fontWeight: FontWeight.w700)),
                   onTap: (){
                      Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageFour(
                                            title: items[index].workoutname,
                                            muscleGroup: items[index].musclegroup,
                                            description: items[index].description,
                                            uid: widget.userUid,
                                            firebaseGeneratedKey: items[index].key,
                                          )));
                   },
                );
              },
            ),
          ),
          Container(
            width: screenWidth,
            child: new FlatButton(child: 
            new Text("+ Add Workout +", style: TextStyle(
                    fontFamily: "Prompt",
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            color: Colors.black,

          onPressed: (){ confirmDialog(context, "Add a new workout");})
          )
        ],
      ),
    );
  }

Future<Null> confirmDialog(BuildContext context, String execution) {
  return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) { 
        return new AlertDialog(
          title: new Text(execution),
           content: SingleChildScrollView(
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
                        handleSubmit();
                      },
                    ),
                  ],
                ),
              )
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


