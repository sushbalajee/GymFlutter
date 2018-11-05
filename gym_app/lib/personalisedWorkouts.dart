import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'personalisedWorkoutDetails.dart';
import 'uploadClientWorkouts.dart';
import 'color_loader_3.dart';
import 'dart:async';
//-----------------------------------------------------------------------------------//

class WorkoutsListPersonal extends StatefulWidget {
  final String userUid;
  final String value;

  WorkoutsListPersonal({Key key, this.value, this.userUid}) : super(key: key);

  @override
  _NextPageStatePersonal createState() => new _NextPageStatePersonal();
}

//-----------------------------------------------------------------------------------//

class _NextPageStatePersonal extends State<WorkoutsListPersonal> {
  List<Item> items = List();
  Item item;
  DatabaseReference itemRef;
  DatabaseReference cref;
  bool informUser;

  Timer timer;
  String msg = "Loading";

  String jointID;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

  print("YOSEPH: " + widget.userUid);
  print(widget.value);
  print("Key: $widget.key");
  timer = new Timer(const Duration(seconds: 5), () {
      setState(() {
        msg = "No workouts assigned to you";
      });
    });

    item = Item("", "", "");
    final FirebaseDatabase database = FirebaseDatabase.instance;

    cref = database
        .reference()
        .child('Workouts')
        .child('ClientNames')
        .child(widget.userUid);
    cref.once().then((DataSnapshot snapshot) {
      jointID = snapshot.value + " - " + widget.userUid;

      itemRef = database
          .reference()
          .child('Workouts')
          .child(widget.value)
          .child(jointID);
      itemRef.onChildAdded.listen(_onEntryAdded);
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
      informUser = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int workoutNumber = 0;
    double screenWidth = MediaQuery.of(context).size.width;

    if (informUser == false) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Personalised Workouts'),
          backgroundColor: Colors.grey[900],
        ),
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            Flexible(
              child: FirebaseAnimatedList(
                query: itemRef,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  //print(items);

                  workoutNumber += 1;
                  return new ListTile(
                    leading: CircleAvatar(child: Text("$workoutNumber")),
                    title: Text(items[index].workoutname,
                        style: TextStyle(
                            fontFamily: "Prompt",
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PageFive(
                                    title: items[index].workoutname,
                                    muscleGroup: items[index].musclegroup,
                                    description: items[index].description,
                                    uid: jointID,
                                    trainerID: widget.value,
                                    firebaseGeneratedKey: items[index].key,
                                  )));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text('My Personalised Workouts'),
            backgroundColor: Colors.grey[900],
          ),
          resizeToAvoidBottomPadding: false,
          body: tryMe());
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  Widget tryMe(){
    return Container(
                        child: new Stack(children: <Widget>[
                      Container(
                          alignment: Alignment.center,
                          child: ColorLoader3(
                            dotRadius: 5.0,
                            radius: 20.0,
                          )),
                      Container(
                          padding: EdgeInsets.only(top: 100.0),
                          alignment: Alignment.center,
                          child: new Text(msg,
                              style: new TextStyle(
                                  fontSize: 20.0, fontFamily: "Montserrat"))),
                    ]));
  }
}
