import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'dart:async';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:toggle_switch/toggle_switch.dart';

class UploadClientWorkoutDetails extends StatefulWidget {
  final String firebaseGeneratedKey;
  final String clientID;
  final String title;
  final String muscleGroup;
  final String description;
  final String ptID;

  UploadClientWorkoutDetails(
      {Key key,
      this.title,
      this.muscleGroup,
      this.description,
      this.clientID,
      this.ptID,
      this.firebaseGeneratedKey})
      : super(key: key);
  @override
  UploadedWorkoutInfo createState() => new UploadedWorkoutInfo();
}

class UploadedWorkoutInfo extends State<UploadClientWorkoutDetails> {
  List<String> added = [];
  List<Item> items = List();
  List<String> suggestionsForDropDown = [];

  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  Item item;

  DatabaseReference exercisesRef;

  int needToKnow = 0;

  String imageUrlStorage = "";
  String currentText = "";
  String textForEx;

  bool switchVal = false;

  final myController = TextEditingController();
  final myController2 = TextEditingController();
  final durationController = TextEditingController();
  final repController = TextEditingController();
  final setController = TextEditingController();
  final restController = TextEditingController();
  final weightController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    fetchPost();

    item = Item("", "", "", "", "", "", "", "");
    final FirebaseDatabase database = FirebaseDatabase.instance;

    exercisesRef = database
        .reference()
        .child('Workouts')
        .child(widget.ptID)
        .child(widget.clientID)
        .child("clientWorkouts")
        .child(widget.firebaseGeneratedKey)
        .child('exercises');

    exercisesRef.onChildAdded.listen(_onEntryAdded);
  }

  Future fetchPost() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/JSON/ExerciseDB.json");
    var jsonResponse = json.decode(data);

    for (var x in jsonResponse) {
      suggestionsForDropDown.add(x['name']);

      if (x['name'] == "Test1") {
        print(x['execution']);
      }
    }
  }

  onSwitchedValue(bool newSwitchVal) {
    setState(() {
      switchVal = newSwitchVal;
    });
  }

  Future fetchPostForExecution(String currText) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/JSON/ExerciseDB.json");
    var jsonResponse = json.decode(data);

    for (var x in jsonResponse) {
      if (x['name'] == currText) {
        textForEx = x['execution'];
      }
    }
    myController2.text = textForEx;
  }

  someMethod(String target) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('Target Muscles')
        .child('$target.gif');
    try {
      imageUrlStorage = await ref.getDownloadURL();
    } catch (e) {
      imageUrlStorage =
          "https://firebasestorage.googleapis.com/v0/b/gymapp-e8453.appspot.com/o/Target%20Muscles%2FNoImage.jpg?alt=media&token=1999bc13-9014-44cd-99d4-7bc6b4dbd717";
    }
  }

  _onEntryAdded(Event event) {
    items.add(Item.fromSnapshot(event.snapshot));
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      exercisesRef.push().set(item.toJson());
    }
  }

  void handleEdit(String fbKey) {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      exercisesRef.child(fbKey).update(item.toJson());
    }

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UploadClientWorkoutDetails(
                  description: widget.description,
                  firebaseGeneratedKey: widget.firebaseGeneratedKey,
                  key: widget.key,
                  muscleGroup: widget.muscleGroup,
                  title: widget.title,
                  ptID: widget.ptID,
                  clientID: widget.clientID,
                )));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF14171A),
        title: Text(widget.title, style: TextStyle(fontFamily: "Montserrat")),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text("Muscle Group - " + widget.muscleGroup,
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenWidth * 0.050,
                    fontWeight: FontWeight.w600)),
          ),
          Container(
            decoration: new BoxDecoration(
              border: Border(
                  bottom: BorderSide(
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
            child: Container(
              height: screenHeight,
              child: FirebaseAnimatedList(
                query: exercisesRef,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  int exerciseNumber = index + 1;
                  return Container(
                      color: Colors.white,
                      child: new Stack(children: <Widget>[
                        new Column(children: <Widget>[
                          Container(
                              color: Color(0xFF003459),
                              child: ListTile(
                                  contentPadding: EdgeInsets.only(
                                      left: 0, top: 0, bottom: 0),
                                  leading: Container(
                                    alignment: Alignment.center,
                                    width: 50,
                                    color: Color(0xFF005792),
                                    child: new Text(
                                      "$exerciseNumber",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: screenWidth * 0.050,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  trailing: new IconButton(
                                      iconSize: 25.0,
                                      icon: Icon(Icons.delete_forever),
                                      color: Color(0xFFC7CCDB),
                                      onPressed: () {
                                        exercisesRef
                                            .child(items[index].key)
                                            .remove();
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UploadClientWorkoutDetails(
                                                      description:
                                                          widget.description,
                                                      firebaseGeneratedKey: widget
                                                          .firebaseGeneratedKey,
                                                      key: widget.key,
                                                      muscleGroup:
                                                          widget.muscleGroup,
                                                      title: widget.title,
                                                      ptID: widget.ptID,
                                                      clientID: widget.clientID,
                                                    )));
                                      }),
                                  title: new Stack(children: <Widget>[
                                    new Row(children: <Widget>[
                                      Flexible(
                                          child: Container(
                                              child: Text(items[index].name,
                                                  style: TextStyle(
                                                      fontFamily: "Montserrat",
                                                      color: Colors.white,
                                                      fontSize:
                                                          screenWidth * 0.050,
                                                      fontWeight:
                                                          FontWeight.w600)))),
                                      Container(
                                          child: new IconButton(
                                              iconSize: 25.0,
                                              icon: new Icon(Icons.edit),
                                              color: Color(0xFFC7CCDB),
                                              onPressed: () {
                                                confirmEdit(context,
                                                    "Edit Exercise", index);
                                              }))
                                    ])
                                  ]))),
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
                                              fontSize: screenWidth * 0.04))),
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
                                          " seconds",
                                      style: TextStyle(
                                          color: Color(0xFF22333B),
                                          fontFamily: "Prompt",
                                          fontSize: screenWidth * 0.04)),
                                  new Text(
                                      "Duration: " +
                                          items[index].duration +
                                          " seconds",
                                      style: TextStyle(
                                          color: Color(0xFF22333B),
                                          fontFamily: "Prompt",
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0),
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
          ),
          Container(
              height: 75,
              width: screenWidth,
              child: new FlatButton.icon(
                  icon: Icon(Icons.add, color: Colors.white),
                  label: new Text("Add Exercise",
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  color: Color(0xFF005792),
                  onPressed: () {
                    confirmDialog(context, "Add Exercise");
                  }))
        ],
      ),
    );
  }

  Future<Null> confirmDialog(BuildContext context, String execution) {
    double screenWidth = MediaQuery.of(context).size.width;

    durationController.text = "N/A";
    repController.text = "";
    setController.text = "";
    restController.text = "";
    weightController.text = "";


    return showDialog<Null>(
        context: context,
        barrierDismissible: false,
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
                  "Add a new exercise",
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
                    searchField(),
                    Row(children: [
                      SizedBox(
                          width: screenWidth / 2 - 25,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: "Reps"),
                            controller: repController,
                            onSaved: (val) => item.reps = val,
                            validator: (val) =>
                                val == "" ? "This field cannot be empty" : null,
                          )),
                      SizedBox(
                          width: screenWidth / 2 - 7.5,
                          child: Container(
                              padding: EdgeInsets.only(left: 20),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: "Sets"),
                                controller: setController,
                                onSaved: (val) => item.sets = val,
                                validator: (val) => val == ""
                                    ? "This field cannot be empty"
                                    : null,
                              )))
                    ]),
                    Row(children: [
                      SizedBox(
                          width: screenWidth / 2 - 25,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration:
                                InputDecoration(labelText: "Rest (seconds)"),
                            controller: restController,
                            onSaved: (val) => item.rest = val,
                            validator: (val) =>
                                val == "" ? "This field cannot be empty" : null,
                          )),
                      SizedBox(
                          width: screenWidth / 2 - 7.5,
                          child: Container(
                              padding: EdgeInsets.only(left: 20),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration:
                                    InputDecoration(labelText: "Weight"),
                                controller: weightController,
                                onSaved: (val) => item.weight = val,
                                validator: (val) => val == ""
                                    ? "This field cannot be empty"
                                    : null,
                              )))
                    ]),
                    Row(children: [
                      SizedBox( width: screenWidth / 2 - 25,child:
                    Container(
                        child: TextFormField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: "Duration (seconds)"),
                      //initialValue: "",
                      onSaved: (val) => item.duration = val,
                      validator: (val) =>
                          val == "" ? "This field cannot be empty" : null,
                    ))),
                    new SizedBox(
                    width: screenWidth / 2 - 5, child:
                    Container(
                      padding: EdgeInsets.only(left: 20, top:20),
                      child: ToggleSwitch(
                        minWidth: screenWidth / 4 - 13,
                        cornerRadius: 5,
                        initialLabelIndex: 0,
                        activeBgColor: Color(0xFF005792),
                        activeTextColor: Colors.white,
                        inactiveBgColor: Color(0xFF14171A),
                        inactiveTextColor: Colors.grey[500],
                        labels: ['Weights', 'Cardio'],
                        onToggle: (index) {
                          if (index == 0) {
                            durationController.text = "N/A";
                            repController.text = "";
                            setController.text = "";
                            restController.text = "";
                            weightController.text = "";
                          } else if (index == 1) {
                            durationController.text = "";
                            repController.text = "N/A";
                            setController.text = "N/A";
                            restController.text = "N/A";
                            weightController.text = "N/A";
                          }
                        },
                      ),
                    ))]),
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
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0))),
                    ),
                    Opacity(
                        opacity: 0.0,
                        child: Container(
                            child: TextFormField(
                          enabled: false,
                          initialValue: "",
                          onSaved: (val) => item.target = imageUrlStorage,
                          //validator: (val) => val == "" ? val : null,
                        ))),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<Null> confirmEdit(BuildContext context, String execution, int ind) {
    double screenWidth = MediaQuery.of(context).size.width;

    return showDialog<Null>(
        context: context,
        barrierDismissible: false,
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
                  "Edit this exercise",
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
                    Container(
                        height: 270,
                        child: TextFormField(
                          maxLines: 12,
                          enabled: true,
                          decoration: InputDecoration(
                              labelText: "Execution", alignLabelWithHint: true),
                          initialValue: items[ind].execution,
                          onSaved: (val) => item.execution = val,
                          validator: (val) =>
                              val == "" ? "This field cannot be empty" : null,
                        )),
                    Row(children: [
                      SizedBox(
                          width: screenWidth / 2 - 25,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: "Reps"),
                            initialValue: items[ind].reps,
                            onSaved: (val) => item.reps = val,
                            validator: (val) =>
                                val == "" ? "This field cannot be empty" : null,
                          )),
                      SizedBox(
                          width: screenWidth / 2 - 7.5,
                          child: Container(
                              padding: EdgeInsets.only(left: 20),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: "Sets"),
                                initialValue: items[ind].sets,
                                onSaved: (val) => item.sets = val,
                                validator: (val) => val == ""
                                    ? "This field cannot be empty"
                                    : null,
                              )))
                    ]),
                    Row(children: [
                      SizedBox(
                          width: screenWidth / 2 - 25,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration:
                                InputDecoration(labelText: "Rest (seconds)"),
                            initialValue: items[ind].rest,
                            onSaved: (val) => item.rest = val,
                            validator: (val) =>
                                val == "" ? "This field cannot be empty" : null,
                          )),
                      SizedBox(
                          width: screenWidth / 2 - 7.5,
                          child: Container(
                              padding: EdgeInsets.only(left: 20),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration:
                                    InputDecoration(labelText: "Weight"),
                                initialValue: items[ind].weight,
                                onSaved: (val) => item.weight = val,
                                validator: (val) => val == ""
                                    ? "This field cannot be empty"
                                    : null,
                              )))
                    ]),
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
                        color: Color(0xFF788aa3),
                        onPressed: () {
                          handleEdit(items[ind].key);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Opacity(
                        opacity: 0.0,
                        child: Container(
                            child: TextFormField(
                          decoration: InputDecoration(labelText: "Name"),
                          initialValue: items[ind].name,
                          enabled: false,
                          onSaved: (val) => item.name = val,
                          validator: (val) => val == "" ? val : null,
                        ))),
                    Opacity(
                        opacity: 0.0,
                        child: Container(
                          child: TextFormField(
                            initialValue: items[ind].target,
                            enabled: false,
                            onSaved: (val) => item.target = val,
                            validator: (val) => val == "" ? val : null,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget searchField() {
    return Flex(direction: Axis.vertical, children: <Widget>[
      AutoCompleteTextField<String>(
          decoration: new InputDecoration(
              labelText: "Add an Exercise",
              hintText: "Start typing",
              suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    myController.text = currentText;
                    someMethod(currentText);
                    //print("1:" + currentText);
                  })),
          key: key,
          submitOnSuggestionTap: true,
          clearOnSubmit: true,
          suggestions: suggestionsForDropDown,
          textInputAction: TextInputAction.go,
          textChanged: (item) {
            currentText = item;
          },
          itemSubmitted: (item) {
            setState(() {
              added.clear();
              currentText = item;
              added.add(currentText);
              someMethod(currentText);
              myController.text = currentText;
              print("1:" + currentText);
              fetchPostForExecution(currentText);
            });
          },
          textSubmitted: (item) {
            setState(() {
              added.clear();
              currentText = item;
              added.add(currentText);
              someMethod(currentText);
              myController.text = currentText;
              print("2:" + currentText);
              fetchPostForExecution(currentText);
            });
          },
          itemBuilder: (context, item) {
            return new Padding(
                padding: EdgeInsets.all(8.0), child: new Text(item));
          },
          itemSorter: (a, b) {
            return a.compareTo(b);
          },
          itemFilter: (item, query) {
            return item.toLowerCase().contains(query.toLowerCase());
          }),
      nameWidget(),
      executionWidget()
    ]);
  }

  Widget nameWidget() {
    return TextFormField(
      enabled: false,
      decoration: InputDecoration(labelText: "Name"),
      controller: myController,
      onSaved: (val) {
        someMethod(val);
        item.name = val;
      },
      validator: (val) => val == "" ? "This field cannot be empty" : null,
    );
  }

  Widget executionWidget() {
    return Container(
        height: 270,
        child: TextFormField(
          maxLines: 12,
          enabled: true,
          decoration:
              InputDecoration(labelText: "Execution", alignLabelWithHint: true),
          controller: myController2,
          onSaved: (val) {
            item.execution = val;
          },
          validator: (val) => val == "" ? "This field cannot be empty" : null,
        ));
  }
}

class Item {
  String key;
  String name;
  String reps;
  String sets;
  String rest;
  String execution;
  String target;
  String weight;
  String duration;

  Item(this.name, this.reps, this.sets, this.rest, this.execution, this.target,
      this.weight, this.duration);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value["name"],
        reps = snapshot.value["reps"],
        sets = snapshot.value["sets"],
        rest = snapshot.value["rest"],
        execution = snapshot.value["execution"],
        target = snapshot.value["target"],
        weight = snapshot.value["weight"],
        duration = snapshot.value["duration"];

  toJson() {
    return {
      "name": name,
      "reps": reps,
      "sets": sets,
      "rest": rest,
      "execution": execution,
      "target": target,
      "weight": weight,
      "duration": duration
    };
  }
}
