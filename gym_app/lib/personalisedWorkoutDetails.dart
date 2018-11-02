import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'uploadClientWorkoutDetails.dart';

class PageFive extends StatefulWidget {
  final String firebaseGeneratedKey;
  final String uid;
  final String title;
  final String muscleGroup;
  final String description;
  final String trainerID;

  PageFive(
      {Key key,
      this.title,
      this.muscleGroup,
      this.description,
      this.uid,
      this.trainerID,
      this.firebaseGeneratedKey})
      : super(key: key);

  @override
  PersonalisedWorkoutInfo createState() => new PersonalisedWorkoutInfo();
}

class PersonalisedWorkoutInfo extends State<PageFive> {
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

    snek = database.reference().child('Workouts').child(widget.uid);
    itemRef = database.reference().child('Workouts').child(widget.trainerID).child(widget.uid).child(widget.firebaseGeneratedKey).child('exercises');
    itemRef.onChildAdded.listen(_onEntryAdded);
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {
    int exerciseNumber = 0;

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.grey[900],
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
            padding: const EdgeInsetsDirectional.only(
                start: 15.0, bottom: 15.0, top: 15.0),
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
                                  ])
                            ]))
                          ])
                        ])));
              },
            ),
          ),
        ],
      ),
    );
  }
}
