import 'package:flutter/material.dart';
import 'workoutDetails.dart';
import 'jsonLogic.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'uploadClientWorkouts.dart';

//-----------------------------------------------------------------------------------//

class UIDList extends StatefulWidget {

  //final String userUid;
  //final String value;

  //UIDList({Key key, this.value, this.userUid}) : super(key: key);

  @override
  UIDListPage createState() => new UIDListPage();
}


class GetUserId {
  
  List<String> uiCode;
  List<String> thisthis;

  GetUserId({this.uiCode});

  factory GetUserId.fromJson10(Map<String, dynamic> parsedJson) {

    List<String> ui = parsedJson.keys.toList();
   

    return GetUserId(uiCode: ui);
  }
}

//-----------------------------------------------------------------------------------//

class UIDListPage extends State<UIDList> {

  String uid;
  List<String> uuiiCode;

   Future fetchPost() async {

    final response =
        await http.get('https://gymapp-e8453.firebaseio.com/Workouts.json');
    var jsonResponse = json.decode(response.body);

    GetUserId post = new GetUserId.fromJson10(jsonResponse);
    uuiiCode = post.uiCode;

    //print(uuiiCode);
    return uuiiCode;

    
  }
//-----------------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {

    int workoutNumber = 0;

    //fetchPost();

    return new Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Colors.grey[900],
            title: new Text("My Clients")),

            body: Container( child:
        FutureBuilder( 
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
                        workoutNumber += index;
                        return ListTile(
                            title: Text(snapshot.data[index], style: TextStyle(
                                      fontFamily: "Prompt",
                                      //fontSize: screenWidth  * 0.055,
                                      fontWeight: FontWeight.w700)),
                                      leading: CircleAvatar(child: Text("$workoutNumber")),
                            onTap: ()
                            {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ClientWorkouts(
                                         userUid: snapshot.data[index],
                                      )));
                            }  
                            );
                  });}}))
      
           );
  }
}
