import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'uploadClientWorkoutDetails.dart';

class PersonalisedWorkoutDetails extends StatefulWidget {
  final String firebaseGeneratedKey;
  final String clientID;
  final String title;
  final String muscleGroup;
  final String description;
  final String ptID;

  PersonalisedWorkoutDetails(
      {Key key,
      this.title,
      this.muscleGroup,
      this.description,
      this.clientID,
      this.ptID,
      this.firebaseGeneratedKey})
      : super(key: key);

  @override
  PersonalisedWorkoutInfo createState() => new PersonalisedWorkoutInfo();
}

class PersonalisedWorkoutInfo extends State<PersonalisedWorkoutDetails> {
  List<Item> items = List();
  //Item item;
  DatabaseReference clientExercisesRef;
  //DatabaseReference snek;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    //item = Item("", "", "", "", "", "", "");
    final FirebaseDatabase database = FirebaseDatabase.instance;

    //snek = database.reference().child('Workouts').child(widget.uid);

    clientExercisesRef = database
        .reference()
        .child('Workouts')
        .child(widget.ptID)
        .child(widget.clientID)
        .child("clientWorkouts")
        .child(widget.firebaseGeneratedKey)
        .child('exercises');

    clientExercisesRef.onChildAdded.listen(_onEntryAdded);
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
      //backgroundColor: Color(0xFFEFF1F3),
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontFamily: "Monterrat")),
        backgroundColor: Color(0xFF232528),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Container(
            //color: Color(0xFF272727),
            padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text("Muscle Group - " + widget.muscleGroup,
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600)),
          ),
          Container(
            //color: Color(0xFF272727),
            decoration: new BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                //                   <--- left side
                color: Colors.grey[300],
                width: 1.0,
              )),
            ),
            padding: EdgeInsets.only(
                top: 5.0, left: 15.0, right: 15.0, bottom: 15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text(widget.description,
                style: TextStyle(
                    fontFamily: "Montserrat", fontSize: screenWidth * 0.04)),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              query: clientExercisesRef,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                exerciseNumber += 1;
                return Container(
                    color: Colors.white,
                    child: new Stack(children: <Widget>[
                      new Column(children: <Widget>[
                        Container(
                            color: Color(0xFF23395b),
                            child: ListTile(
                              contentPadding:
                                  EdgeInsets.only(left: 0, top: 0, bottom: 0),
                              leading: Container(
                                alignment: Alignment.center,
                                width: 50,
                                color: Color(0xFF788aa3),
                                child: new Text(
                                  "$exerciseNumber",
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: screenWidth * 0.050,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                //backgroundColor: Color(0xFF767B91)
                              ),
                              title: Text(items[index].name,
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.w600)),
                            )),
                        ListTile(
                            subtitle: new Stack(children: <Widget>[
                          new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: new Text(
                                        "Weight: " + items[index].weight,
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            color: Color(0xFF22333B),
                                            fontSize: screenWidth * 0.04),
                                        textAlign: TextAlign.left)),
                                new Text("Sets: " + items[index].sets,
                                    style: TextStyle(
                                        fontFamily: "Prompt",
                                        color: Color(0xFF22333B),
                                        fontSize: screenWidth * 0.04)),
                                new Text("Repetitions: " + items[index].reps,
                                    style: TextStyle(
                                        fontFamily: "Prompt",
                                        color: Color(0xFF22333B),
                                        fontSize: screenWidth * 0.04)),
                                new Text(
                                    "Rest times: " +
                                        items[index].rest +
                                        " seconds between sets",
                                    style: TextStyle(
                                        fontFamily: "Prompt",
                                        color: Color(0xFF22333B),
                                        fontSize: screenWidth * 0.04)),
                                new Padding(
                                  padding: EdgeInsets.only(top: 15.0),
                                  child: Image.network(items[index].target),
                                ),
                                new ExpansionTile(
                                  title: Align(
                                      alignment: Alignment(
                                          -1 - (60 / screenWidth), 0.0),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text("Execution",
                                                style: TextStyle(
                                                    fontFamily: "Prompt",
                                                    color: Color(0xFF22333B),
                                                    fontSize:
                                                        screenWidth * 0.04))
                                          ])),
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(items[index].execution,
                                                style: TextStyle(
                                                    fontFamily: "Prompt",
                                                    color: Color(0xFF22333B),
                                                    fontSize:
                                                        screenWidth * 0.04))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ])
                        ]))
                      ])
                    ]));
              },
            ),
          ),
        ],
      ),
    );
  }
}
