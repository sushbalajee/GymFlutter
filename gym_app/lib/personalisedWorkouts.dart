import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'personalisedWorkoutDetails.dart';
import 'uploadClientWorkouts.dart';
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

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Item("", "","");
    final FirebaseDatabase database = FirebaseDatabase.instance; 
    print(widget.value);
    itemRef = database.reference().child('Workouts').child(widget.value).child(widget.userUid);
    itemRef.onChildAdded.listen(_onEntryAdded);
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {

    int workoutNumber = 0;
    double screenWidth = MediaQuery.of(context).size.width;
    
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
                                      builder: (context) => PageFive(
                                            title: items[index].workoutname,
                                            muscleGroup: items[index].musclegroup,
                                            description: items[index].description,
                                            uid: widget.userUid,
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
  }
}

