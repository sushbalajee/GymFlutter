import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'dart:async';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  List<String> suggestions = [
    "Barbell Squat",
    "Bench Press",
    "Lunges - Dumbbells",
    "Sidepose",
    "Sumo Deadlifts",
    "Tricep Dips",
  ];

  List<String> added = [];
  List<Item> items = List();

  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  Item item;

  DatabaseReference exercisesRef;

  String imageUrlStorage = "";
  String currentText = "";

  final myController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();


    item = Item("", "", "", "", "", "", "");
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

  someMethod(String target) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('Target Muscles')
        .child('$target.jpg');
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
    int exerciseNumber = 0;

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      //backgroundColor: Color(0xFF550000),
      appBar: AppBar(
        backgroundColor: Color(0xFF232528),
        title: Text(widget.title, style: TextStyle(fontFamily: "Ubuntu")),
      ),
      resizeToAvoidBottomPadding: false,
      body: 
      Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text("Muscle Group - " + widget.muscleGroup,
                style: TextStyle(
                    fontFamily: "Ubuntu",
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600)),
          ),
          Container( 
            decoration: new BoxDecoration(
    border: Border(
      bottom: BorderSide( //                   <--- left side
        color: Colors.grey[300],
        width: 1.0,
      )),
  ),
            //color: Color(0xFF550000),
            padding: EdgeInsets.only(
                top: 5.0, left: 15.0, right: 15.0, bottom: 15.0),
            alignment: Alignment(-1.0, 0.0),
            child: Text(widget.description,
                style: TextStyle(
                    fontFamily: "Ubuntu",
                    fontSize: screenWidth * 0.035)),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              query: exercisesRef,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                exerciseNumber += 1;
                return Card(
                  
                    color: Colors.grey[100],
                  margin: EdgeInsets.all(0.0),
                            shape: new RoundedRectangleBorder( 
                    borderRadius: BorderRadius.all( Radius.circular(0.0))),
                    //borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                    elevation: 2.0,
                    child: 
                    new Container( 
                      decoration: new BoxDecoration(
      color: Colors.grey,
      gradient: new LinearGradient(
        colors: [Colors.grey[100], Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
      ),
    ),
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
                                    backgroundColor: Color(0xFF405062)),
                                trailing: new IconButton(
                                    iconSize: 35.0,
                                    icon: Icon(Icons.delete_forever),
                                    color: Color(0xFF405062),
                                    onPressed: () {
                                      exercisesRef
                                          .child(items[index].key)
                                          .remove();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => UploadClientWorkoutDetails(
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
                                                    fontFamily: "Ubuntu",
                                                    color: Color(0xFF405062),
                                                    fontSize:
                                                        screenWidth * 0.05,
                                                    fontWeight:
                                                        FontWeight.w700)))),
                                    Container(
                                        child: new IconButton(
                                            icon: new Icon(Icons.edit),
                                            color: Color(0xFF405062),
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
                                      child: Image.network(items[index].target),
                                    ),
                                  ])
                            ]))
                          ])
                        ]))));
              },
            ),
          ),
          Container(
              width: screenWidth,
              child: new FlatButton(
                  child: new Text("Add Exercise",
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
          return new Scaffold(
            appBar: new AppBar(

              leading: new IconButton(
  icon: new Icon(Icons.close),
  onPressed: () => Navigator.of(context).pop(),
), 
                
                centerTitle: true,
                backgroundColor: Color(0xFF232528),
                title: new Text("Add a new exercise", style: TextStyle(fontSize: 20.0, fontFamily: "Ubuntu", fontWeight: FontWeight.w500),)),
          
            body: SingleChildScrollView(
              padding: EdgeInsets.all(15.0),
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
                      validator: (val) =>
                          val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Sets"),
                      initialValue: "",
                      onSaved: (val) => item.sets = val,
                      validator: (val) =>
                          val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Execution"),
                      initialValue: "",
                      onSaved: (val) => item.execution = val,
                      validator: (val) =>
                          val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Rest"),
                      initialValue: "",
                      onSaved: (val) => item.rest = val,
                      validator: (val) =>
                          val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Weight"),
                      initialValue: "",
                      onSaved: (val) => item.weight = val,
                      validator: (val) =>
                          val == "" ? "This field cannot be empty" : null,
                    ),
                    Container(
                      width: screenWidth - 30,
                    padding: EdgeInsets.only(top: 30.0),
                      child: new FlatButton(
                color: Colors.grey[900],
                child: new Text("Submit",
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                onPressed: () {
                  //final FormState form = formKey.currentState;
                  if(formKey.currentState.validate()){
                  Navigator.of(context).pop();}
                  handleSubmit();
                  
                },
              ),
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
                title: new Text("Edit this exercise", style: TextStyle(fontSize: 20.0, fontFamily: "Ubuntu", fontWeight: FontWeight.w500),)),
          
            body: SingleChildScrollView(
              padding: EdgeInsets.all(15.0),
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: "Reps"),
                      initialValue: items[ind].reps,
                      onSaved: (val) => item.reps = val,
                      validator: (val) =>
                          val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Sets"),
                      initialValue: items[ind].sets,
                      onSaved: (val) => item.sets = val,
                      validator: (val) =>
                          val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Execution"),
                      initialValue: items[ind].execution,
                      onSaved: (val) => item.execution = val,
                      validator: (val) =>
                          val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Rest"),
                      initialValue: items[ind].rest,
                      onSaved: (val) => item.rest = val,
                      validator: (val) =>
                          val == "" ? "This field cannot be empty" : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Weight"),
                      initialValue: items[ind].weight,
                      onSaved: (val) => item.weight = val,
                      validator: (val) =>
                          val == "" ? "This field cannot be empty" : null,
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20.0),
                      width: screenWidth - 30,
                      child: new FlatButton(
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
              ),),
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
                    print(currentText);
                  })),
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
      validator: (val) =>
                          val == "" ? "This field cannot be empty" : null,
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
