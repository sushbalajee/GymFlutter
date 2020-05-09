import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'uploadClientWorkouts.dart';
import 'color_loader_3.dart';

//-----------------------------------------------------------------------------------//

class UIDList extends StatefulWidget {
  final String ptID;

  UIDList({Key key, this.ptID}) : super(key: key);

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
    return GetClientIDs(uiCode: passMe);
  }
}

//-----------------------------------------------------------------------------------//

class UIDListPage extends State<UIDList> {
  List clients;
  String informUser;

  Future fetchPost() async {
    final response = await http.get(
        'https://gymapp-e8453.firebaseio.com/Workouts/' +
            widget.ptID +
            '.json');

    var jsonResponse = json.decode(response.body);
    if (jsonResponse != "") {
      GetClientIDs post = new GetClientIDs.fromJson20(jsonResponse);
      clients = post.uiCode;
      clients.remove("ComingUp");
      return clients;
    } else {
      informUser =
          "You do not have any clients registered with your Personal Trainer ID";
    }
  }

//-----------------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return new Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFF232528),
            title: new Text("My Clients",
                style: TextStyle(fontFamily: "Montserrat"))),
        body: Container(
            child: FutureBuilder(
                future: fetchPost(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null && informUser == null) {
                    return Container(
                        color: Color(0xFF788aa3),
                        child: new Stack(children: <Widget>[
                      Container(
                          alignment: Alignment.center,
                          child: ColorLoader3(
                            dotRadius: 5.0,
                            radius: 20.0,
                          )),
                      Container(
                          padding: EdgeInsets.only(top: 150.0),
                          alignment: Alignment.center,
                          child: new Text("Loading . . .",
                              style: new TextStyle(
                                  fontSize: screenWidth * 0.05, fontFamily: "Montserrat", color: Colors.white)))
                    ]));
                  } else if (informUser != null) {
                    return Container(
                      padding: EdgeInsets.all(50),
                      color: Color(0xFF788aa3),
                        child: Center(
                      child: Text(informUser, style: TextStyle(color: Colors.white, fontFamily: "Montserrat", fontSize: screenWidth * 0.05, fontWeight: FontWeight.w500)),
                    ));
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          int workoutNumber = index + 1;
                          return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 0.3, color: Color(0xFF788aa3)),
                                ),
                              ),
                              child: ListTile(
                                  contentPadding: EdgeInsets.only(
                                      top: 0.0, bottom: 0.0, left: 0),
                                  leading: Container(
                                    alignment: Alignment.center,
                                    width: 50,
                                    color: Color(0xFF788aa3),
                                    child: new Text(
                                      "$workoutNumber",
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: screenWidth * 0.050,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  title: Text(
                                      snapshot.data[index].toString().substring(
                                          0, snapshot.data[index].indexOf('-')),
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: screenWidth * 0.050,
                                          color: Color(0xFF22333B),
                                          fontWeight: FontWeight.w600)),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UploadClientWorkouts(
                                                  clientID:
                                                      snapshot.data[index],
                                                  ptID: widget.ptID,
                                                )));
                                  }));
                        });
                  }
                })));
  }
}
