import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'uploadClientWorkouts.dart';
import 'color_loader_3.dart';
import 'package:firebase_auth/firebase_auth.dart';

//-----------------------------------------------------------------------------------//

class UIDList extends StatefulWidget {
  @override
  final String trainerID;

  UIDList({Key key, this.trainerID}) : super(key: key);

  UIDListPage createState() => new UIDListPage();
}

class GetUserId {
  List<String> uiCode;
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
    List<String> passMe = parsedJson.keys.toList();
    //print(passMe);
    return GetClientIDs(uiCode: passMe);
  }
}

//-----------------------------------------------------------------------------------//

class UIDListPage extends State<UIDList> {
  List uuiiCode;
  String informUser;
  List<String>clientNames = [""];

  Future fetchPost() async {
    final response = await http.get(
        'https://gymapp-e8453.firebaseio.com/Workouts/' +
            widget.trainerID +
            '.json');

    var jsonResponse = json.decode(response.body);
    if (jsonResponse != "") {
      GetClientIDs post = new GetClientIDs.fromJson20(jsonResponse);
      uuiiCode = post.uiCode;
      return uuiiCode;
    } else {
      informUser =
          "You do not have any clients registered with your Personal Trainer ID";
    }
  }

//-----------------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    //fetchPost();
    return new Scaffold(

        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFF4A657A),
            title: new Text("My Clients", style: TextStyle(fontFamily: "Montserrat"))),
        body: 
        Container(
           color: Color(0xFFEFF1F3),
            child: FutureBuilder(
                future: fetchPost(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null && informUser == null) {
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
                          child: new Text("Loading",
                              style: new TextStyle(
                                  fontSize: 20.0, fontFamily: "Montserrat")))
                    ]));
                  } else if (informUser != null) {
                    return Container(
                        child: Center(
                      child: Text(informUser),
                    ));
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                             //shape: Border.all(
                //color: Colors.blueGrey[400], width: 1.0, style: BorderStyle.solid),
                             elevation: 3.0,
                             child:
                          ListTile( 
                            
                            contentPadding: EdgeInsets.all(20.0),
                              title: Text(snapshot.data[index], border: Border.all(
                color: Colors.grey[900], width: 4.5, style: BorderStyle.solid),
                                  style: TextStyle(
                                      fontFamily: "Montserrat",
                                      //fontSize: screenWidth  * 0.055,
                                      color: Color(0xFF22333B),
                                      fontWeight: FontWeight.w700)),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ClientWorkouts(
                                              userUid: snapshot.data[index],
                                              value: widget.trainerID,
                                            )));
                              }));
                        });
                  }
                })));
  }
}
