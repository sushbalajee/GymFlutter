import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'dart:async';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PageFour extends StatefulWidget {
  final String firebaseGeneratedKey;
  final String uid;
  final String title;
  final String muscleGroup;
  final String description;
  final String trainerID;

  PageFour(
      {Key key,
      this.title,
      this.muscleGroup,
      this.description,
      this.uid,
      this.trainerID,
      this.firebaseGeneratedKey})
      : super(key: key);

  @override
  UploadedWorkoutInfo createState() => new UploadedWorkoutInfo();
}

class UploadedWorkoutInfo extends State<PageFour> {

  List<String> suggestions = [
    "Barbell Squat",
    "Bench Press",
    "Lunges - Dumbbells",
    "Sidepose",
    "Sumo Deadlifts",
    "Tricep Dips",
  ];

  List<String> added = [];
  String currentText = "";
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  List<Item> items = List();
  Item item;
  DatabaseReference itemRef;
  DatabaseReference snek;
  String imageUrlStorage = "";

  final myController = TextEditingController();
 
  String passMeOn;
  var focusNode = new FocusNode();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

  // listen to focus changes
    focusNode.addListener(() => print('focusNode updated: hasFocus: ${focusNode.hasFocus}')); 

    item = Item("", "", "", "", "", "", "");
    final FirebaseDatabase database = FirebaseDatabase.instance;

    /*snek = database
        .reference()
        .child('Workouts')
        .child(widget.trainerID)
        .child(widget.uid);*/

    itemRef = database
        .reference()
        .child('Workouts')
        .child(widget.trainerID)
        .child(widget.uid)
        .child(widget.firebaseGeneratedKey)
        .child('exercises');

    itemRef.onChildAdded.listen(_onEntryAdded);
  }


  someMethod(String target) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('Target Muscles')
        .child('$target.jpg');

        try {
          imageUrlStorage = await ref.getDownloadURL();
        } catch (e) {
          imageUrlStorage = "https://firebasestorage.googleapis.com/v0/b/gymapp-e8453.appspot.com/o/Target%20Muscles%2FNoImage.jpg?alt=media&token=1999bc13-9014-44cd-99d4-7bc6b4dbd717";
        }
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
      itemRef.push().set(item.toJson());
    }
  }

  void handleEdit(String fbKey) {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      itemRef.child(fbKey).update(item.toJson());
    }

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => PageFour(
                  description: widget.description,
                  firebaseGeneratedKey: widget.firebaseGeneratedKey,
                  key: widget.key,
                  muscleGroup: widget.muscleGroup,
                  title: widget.title,
                  trainerID: widget.trainerID,
                  uid: widget.uid,
                )));
  }

  @override
  Widget build(BuildContext context) {
    int exerciseNumber = 0;

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFEFF1F3),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A657A),
        title: Text(widget.title, style: TextStyle(fontFamily: "Montserrat")),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Container(
            color: Color(0xFF272727),
            padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text("Muscle Group - " + widget.muscleGroup,
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          Container(
            color: Color(0xFF272727),
            padding: EdgeInsets.only(
                top: 5.0, left: 15.0, right: 15.0, bottom: 15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text(widget.description,
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: screenWidth * 0.035,
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
                  //someMethod(items[index].name);
                exerciseNumber += 1;
                return Card(
                    elevation: 3.0,
                    child: new Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: new Stack(children: <Widget>[
                          new Column(children: <Widget>[
                            ListTile(
                                leading: CircleAvatar(
                                    radius: 20.0,
                                    child: new Text(
                                      "$exerciseNumber",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Color(0xFF4A657A)),
                                trailing: new IconButton(
                                    iconSize: 35.0,
                                    icon: Icon(Icons.delete_forever),
                                    color: Color(0xFF4A657A),
                                    onPressed: () {
                                      /*if (items.length == 1) {
                          //confirmError(context, "Please add a new workout before deleting this one", "");
                        } else {*/
                                      itemRef.child(items[index].key).remove();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PageFour(
                                                    description:
                                                        widget.description,
                                                    firebaseGeneratedKey: widget
                                                        .firebaseGeneratedKey,
                                                    key: widget.key,
                                                    muscleGroup:
                                                        widget.muscleGroup,
                                                    title: widget.title,
                                                    trainerID: widget.trainerID,
                                                    uid: widget.uid,
                                                  )));
                                      //}
                                    }),
                                title: new Stack(children: <Widget>[
                                  new Row(children: <Widget>[
                                    Text(items[index].name,
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            color: Color(0xFF4A657A),
                                            fontSize: screenWidth * 0.05,
                                            fontWeight: FontWeight.w700)),
                                    Container(
                                        child: new IconButton(
                                            icon: new Icon(Icons.edit),
                                            color: Color(0xFF4A657A),
                                            onPressed: () {
                                              confirmEdit(context,
                                                  "Edit Exercise", index);
                                            }))
                                  ])
                                ])),
                            ListTile(
                                subtitle: new Stack(children: <Widget>[
                              new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Text("Weight: " + items[index].weight,
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            color: Color(0xFF22333B),
                                            fontSize: screenWidth * 0.04)),
                                    new Text(
                                        "Execution: " + items[index].execution,
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            color: Color(0xFF22333B),
                                            fontSize: screenWidth * 0.04)),
                                    new Text("Sets: " + items[index].sets,
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            color: Color(0xFF22333B),
                                            fontSize: screenWidth * 0.04)),
                                    new Text(
                                        "Repetitions: " + items[index].reps,
                                        style: TextStyle(
                                            fontFamily: "Prompt",
                                            color: Color(0xFF22333B),
                                            fontSize: screenWidth * 0.04)),
                                    new Text(
                                        "Rest times: " +
                                            items[index].rest +
                                            " seconds between sets",
                                        style: TextStyle(
                                            color: Color(0xFF22333B),
                                            fontFamily: "Prompt",
                                            fontSize: screenWidth * 0.04)),
                                    new Padding(
                                      padding: EdgeInsets.only(top: 15.0),
                                      child: Image.network( items[index].target
                                      ),
                                    ),
                                  ])
                            ]))
                          ])
                        ])));
              },
            ),
          ),
          Container(
              width: screenWidth,
              child: new FlatButton(
                  child: new Text("+ Add Exercise + ",
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  color: Color(0xFF272727),
                  onPressed: () {
                    confirmDialog(context, "Add Exercise");
                  }))
        ],
      ),
    );
  }

  Future<Null> confirmDialog(BuildContext context, String execution) {
    double screenWidth = MediaQuery.of(context).size.width;

    return showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(execution,
                style: TextStyle(
                    fontFamily: "Montserrat", fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    searchField(),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Reps"),
                      initialValue: '',
                      onSaved: (val) => item.reps = val,
                      validator: (val) => val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Sets"),
                      initialValue: "",
                      onSaved: (val) => item.sets = val,
                      validator: (val) => val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Execution"),
                      initialValue: "",
                      onSaved: (val) => item.execution = val,
                      validator: (val) => val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Rest"),
                      initialValue: "",
                      onSaved: (val) => item.rest = val,
                      validator: (val) => val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Weight"),
                      initialValue: "",
                      onSaved: (val) => item.weight = val,
                      validator: (val) => val == "" ? "This field cannot be empty" : null,
                    ),
                    Opacity(opacity: 0.0, child: Container( child: 
                    TextFormField(
                      enabled: false,
                      initialValue: "",
                      onSaved: (val) => item.target = imageUrlStorage,
                      //validator: (val) => val == "" ? val : null,
                    ))),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                color: Colors.grey[900],
                child: new Text("Submit",
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                onPressed: () {
                  handleSubmit();
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                padding: EdgeInsets.all(20.0),
                child: const Text('CLOSE',
                    style: TextStyle(fontFamily: "Montserrat")),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<Null> confirmEdit(BuildContext context, String execution, int ind) {
    double screenWidth = MediaQuery.of(context).size.width;

    return showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(execution,
                style: TextStyle(
                    fontFamily: "Montserrat", fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: "Reps"),
                      initialValue: items[ind].reps,
                      onSaved: (val) => item.reps = val,
                      validator: (val) => val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Sets"),
                      initialValue: items[ind].sets,
                      onSaved: (val) => item.sets = val,
                      validator: (val) => val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Execution"),
                      initialValue: items[ind].execution,
                      onSaved: (val) => item.execution = val,
                      validator: (val) => val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Rest"),
                      initialValue: items[ind].rest,
                      onSaved: (val) => item.rest = val,
                      validator: (val) => val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Weight"),
                      initialValue: items[ind].weight,
                      onSaved: (val) => item.weight = val,
                      validator: (val) => val == "" ? "This field cannot be empty" : null,
                    ),
                    Opacity( 
                      opacity: 0.0,
                      child: Container( child:
                    TextFormField(
                      decoration: InputDecoration(labelText: "Name"),
                      initialValue: items[ind].name,
                      enabled: false,
                      onSaved: (val) => item.name = val,
                      validator: (val) => val == "" ? val : null,
                    ))),
                    Opacity( 
                      opacity: 0.0,
                      child: Container( child:
                    TextFormField(
                      initialValue: items[ind].target,
                      enabled: false,
                      onSaved: (val) => item.target = val,
                      validator: (val) => val == "" ? val : null,
                    ),)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[

              new FlatButton(
                        child: new Text("Submit",
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        color: Colors.black,
                        onPressed: () {
                          handleEdit(items[ind].key);
                          Navigator.of(context).pop();
                        },
                      ),
              new FlatButton(
                padding: EdgeInsets.all(20.0),
                child: const Text('CLOSE',
                    style: TextStyle(fontFamily: "Montserrat")),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget searchField() {
    return Flex(direction: Axis.vertical, children: <Widget>[
      AutoCompleteTextField<String>(
          decoration: new InputDecoration(
              labelText: "Add an Exercise",
              hintText: "Start typing",
              suffixIcon: IconButton( icon: Icon(Icons.add), onPressed: (){
              myController.text = currentText;
              someMethod(currentText);
              print(currentText);
              }
              )),
          key: key,
          submitOnSuggestionTap: true,
          clearOnSubmit: true,
          suggestions: suggestions,
          textInputAction: TextInputAction.go,
          textChanged: (item) {
            currentText = item;
          },
          textSubmitted: (item) {
            setState(() {
              added.clear();
              currentText = item;
              added.add(currentText);
              someMethod(currentText);
              myController.text = currentText;
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
      validator: (val) => val == "" ? val : null,
    );
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

  Item(this.name, this.reps, this.sets, this.rest, this.execution, this.target,
      this.weight);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value["name"],
        reps = snapshot.value["reps"],
        sets = snapshot.value["sets"],
        rest = snapshot.value["rest"],
        execution = snapshot.value["execution"],
        target = snapshot.value["target"],
        weight = snapshot.value["weight"];

  toJson() {
    return {
      "name": name,
      "reps": reps,
      "sets": sets,
      "rest": rest,
      "execution": execution,
      "target": target,
      "weight": weight
    };
  }
}
