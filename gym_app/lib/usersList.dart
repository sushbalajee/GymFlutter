import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'uploadClientWorkouts.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

//-----------------------------------------------------------------------------------//

class UIDList extends StatefulWidget {
  @override
  final String trainerID;

  UIDList({Key key, this.trainerID}) : super(key: key);

  UIDListPage createState() => new UIDListPage();
}

class GetUserId {

  List <String> uiCode;
  
  GetUserId({this.uiCode});

  factory GetUserId.fromJson10(Map<String, dynamic> parsedJson) {

    List<String> ui = parsedJson.keys.toList();
    return GetUserId(uiCode: ui);
  }

  factory GetUserId.fromJson20(Map<String, dynamic> parsedJson) {

    List passMe = parsedJson.values.toList();
    return GetUserId(uiCode: passMe);
  }
}

class GetClientIDs {

  List uiCode;
  
  GetClientIDs({this.uiCode});

  factory GetClientIDs.fromJson20(Map<String, dynamic> parsedJson) {

    List <String >passMe = parsedJson.keys.toList();
    print(passMe);
    return GetClientIDs(uiCode: passMe);
  }
}

//-----------------------------------------------------------------------------------//

class UIDListPage extends State<UIDList> {
  String uid;
  List uuiiCode;
  DatabaseReference clientRef;

  List<String> items;
  Item item;
  DatabaseReference itemRef;

  Future fetchPost() async {
    final response =
        await http.get('https://gymapp-e8453.firebaseio.com/Workouts/'+ widget.trainerID +'.json');
    var jsonResponse = json.decode(response.body);

    GetClientIDs post = new GetClientIDs.fromJson20(jsonResponse);
    uuiiCode = post.uiCode;
    return uuiiCode;
  }

//-----------------------------------------------------------------------------------//

@override
  Widget build(BuildContext context) {
    fetchPost();
    return new Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Colors.grey[900],
            title: new Text("My Clients")),
        body: Container(
          child: FutureBuilder(
                future: fetchPost(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: Center(
                      child: Text("Loading..."),
                    ));
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              title: Text(snapshot.data[index],
                                  style: TextStyle(
                                      fontFamily: "Prompt",
                                      //fontSize: screenWidth  * 0.055,
                                      fontWeight: FontWeight.w700))
                                      ,  onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ClientWorkouts(
                                              userUid: snapshot.data[index],
                                              value: widget.trainerID,
                                            )));
                             }
                        
                            );
                        });
                  }
                })
        ));
  }



/*
  @override
  Widget build(BuildContext context) {
    potential();
    int workoutNumber = 0;
    return new Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Colors.grey[900],
            title: new Text("My Clients")),
        body: Container(
            child: FutureBuilder(
                future: fetchPost(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: Center(
                      child: Text("Loading..."),
                    ));
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          workoutNumber++;
                          return ListTile(
                              title: Text(snapshot.data[index],
                                  style: TextStyle(
                                      fontFamily: "Prompt",
                                      //fontSize: screenWidth  * 0.055,
                                      fontWeight: FontWeight.w700)),
                              leading:
                                  CircleAvatar(child: Text("$workoutNumber")),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ClientWorkouts(
                                              userUid: snapshot.data[index],
                                            )));
                             });
                        });
                  }
                })));
  }*/

}
