import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'uploadClientWorkouts.dart';
import 'color_loader_3.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  String ordering = "A-Z";
  var arrowDir = "assets/az_sort.svg";

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
          backgroundColor: Color(0xFF14171A),
          title:
              Container(
                  width: screenWidth,
                  child: Stack(children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        width: screenWidth * 0.65,
                        child: Text("My Clients",
                            style: TextStyle(fontFamily: "Montserrat"))),
                    new Positioned(
                      right: 10,
                      child: new InkWell(
                          onTap: () {
                            setState(() {
                              if (ordering == "A-Z") {
                                arrowDir = "assets/za_sort.svg";
                                ordering = "Z-A";
                              } else if (ordering == "Z-A") {
                                ordering = "A-Z";
                                arrowDir = "assets/az_sort.svg";
                              }
                            });
                          },
                          child: Container(
                            child: SvgPicture.asset(
                              arrowDir,
                              color: Colors.white,
                              height: screenWidth * 0.057,
                            ),
                          )),
                    )
                  ])),
        ),
        body: Column(children: <Widget>[
          Flexible(
              child: FutureBuilder(
                  future: fetchPost(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null && informUser == null) {
                      return Container(
                          color: Color(0xFF003459),
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
                                        fontSize: screenWidth * 0.05,
                                        fontFamily: "Montserrat",
                                        color: Colors.white)))
                          ]));
                    } else if (informUser != null) {
                      return Container(
                          padding: EdgeInsets.all(50),
                          color: Color(0xFF003459),
                          child: Center(
                            child: Text(informUser,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.w500)),
                          ));
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            alphabeticalSort(index);
                            //snapshot.data[index].sort((a,b){});
                            int workoutNumber = index + 1;
                            return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 0.0, color: Color(0xFF005792)),
                                  ),
                                ),
                                child: ListTile(
                                    contentPadding: EdgeInsets.only(
                                        top: 0.0, bottom: 0.0, left: 0),
                                    leading: Container(
                                      alignment: Alignment.center,
                                      width: 50,
                                      color: Color(0xFF005792),
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
                                        clients[index].toString().substring(
                                            0, clients[index].indexOf('-')),
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
                                                    clientID: clients[index],
                                                    ptID: widget.ptID,
                                                  )));
                                    }));
                          });
                    }
                  }))
        ]));
  }

  void alphabeticalSort(int index) {
    if (ordering == "A-Z") {
      clients.sort((a, b) {
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    } else if (ordering == "Z-A") {
      clients.sort((a, b) {
        return b.toLowerCase().compareTo(a.toLowerCase());
      });
    }
  }
}
