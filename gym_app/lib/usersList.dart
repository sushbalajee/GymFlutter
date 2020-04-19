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
    return new Scaffold(
      //backgroundColor: Color(0xFF232528),
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFF232528),
            title: new Text("My Clients",
                style: TextStyle(fontFamily: "Ubuntu"))),
        body: Container(
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
                            
                          color: Colors.grey[100],
                          margin: EdgeInsets.all(1.0),
                            shape: new RoundedRectangleBorder(
                    //borderRadius: BorderRadius.all( Radius.circular(25.0))),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                              elevation: 0.6,
                              child: ListTile(
                                  contentPadding: EdgeInsets.all(20.0),
                                  title: Text(snapshot.data[index].toString().substring(0, snapshot.data[index].indexOf('-')),
                                      style: TextStyle(
                                          fontFamily: "Ubuntu",
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
