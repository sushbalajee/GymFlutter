import 'package:flutter/material.dart';
import 'uploadClientWorkoutDetails.dart';

class DataSearch extends SearchDelegate<String>{
  
  final cities = [
    "Mumbai",
    "Texas",
    "Pune",
    "Chennai",
    "USA",
    "Bangkok",
    "Leg Press",
    "Deadlift"
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [IconButton(icon: Icon(Icons.clear), onPressed: (){
      query = "";
    })];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow,
    progress: transitionAnimation), 
    onPressed: (){
      close(context, null);
    } );

  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    final suggestionList = cities.where((p) => p.toLowerCase().startsWith(query.toLowerCase())).toList();

    return ListView.builder(itemBuilder: 
    (context, index) => ListTile( 
    onTap: (){
      UploadedWorkoutInfo().passMeOn = suggestionList[index];
      print("Original: " + suggestionList[index]);
    Navigator.of(context).pop();
    },
     title: RichText(
       text: TextSpan(
         text: suggestionList[index].substring(0, query.length),
         style: TextStyle(
           color: Colors.black, fontWeight: FontWeight.w700),
           children:[
             TextSpan(text: suggestionList[index].substring(query.length),
             style: TextStyle(color: Colors.grey))
           ]),
     ),
    ), itemCount: suggestionList.length,
    );
  }

}