import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'personalisedWorkoutDetails.dart';
import 'uploadClientWorkouts.dart';
import 'color_loader_3.dart';
import 'dart:async';
//-----------------------------------------------------------------------------------//

class PersonalisedWorkouts extends StatefulWidget {
  final String clientID;
  final String ptID;

  PersonalisedWorkouts({Key key, this.ptID, this.clientID}) : super(key: key);

  @override
  PersonalisedWorkoutsState createState() => new PersonalisedWorkoutsState();
}

//-----------------------------------------------------------------------------------//

class PersonalisedWorkoutsState extends State<PersonalisedWorkouts> {
  List<Item> items = List();
  //Item item;
  DatabaseReference clientWorkoutsRef;
  DatabaseReference clientNamesRef;

  bool informUser;

  Timer timer;
  String msg = "Loading";

  String jointID;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    timer = new Timer(const Duration(seconds: 5), () {
      setState(() {
        msg = "No workouts assigned to you";
      });
    });

    //item = Item("", "", "");
    final FirebaseDatabase database = FirebaseDatabase.instance;

    clientNamesRef = database
        .reference()
        .child('Workouts')
        .child('ClientNames')
        .child(widget.clientID);
    clientNamesRef.once().then((DataSnapshot snapshot) {
      jointID = snapshot.value + " - " + widget.clientID;

      clientWorkoutsRef = database
          .reference()
          .child('Workouts')
          .child(widget.ptID)
          .child(jointID)
          .child("clientWorkouts");
      clientWorkoutsRef.onChildAdded.listen(_onEntryAdded);
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
        backgroundColor: Color(0xFFEFF1F3),
        appBar: AppBar(
          backgroundColor: Color(0xFF4A657A),
          title: Text('My Personalised Workouts',
              style: TextStyle(fontFamily: "Ubuntu")),
        ),
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
                      elevation: 3.0,
                      child: new ListTile(
                        contentPadding: EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 15.0),
                        leading: CircleAvatar(
                            child: Text(
                              "$workoutNumber",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Color(0xFF4A657A)),
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
                                  builder: (context) =>
                                      PersonalisedWorkoutDetails(
                                        title: items[index].workoutname,
                                        muscleGroup: items[index].musclegroup,
                                        description: items[index].description,
                                        clientID: jointID,
                                        ptID: widget.ptID,
                                        firebaseGeneratedKey: items[index].key,
                                      )));
                        },
                      ));
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
          body: loadingScreen());
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  Widget loadingScreen() {
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
              style: new TextStyle(fontSize: 20.0, fontFamily: "Montserrat"))),
    ]));
  }
}
