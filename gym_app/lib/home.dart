
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';


class PageOne extends StatefulWidget {
  @override
    _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<PageOne> {
List<String> added = [];
  String currentText = "";
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  List<String> suggestions = [
    "Apple",
    "Armidillo",
    "Actual",
    "Actuary",
    "America",
    "Argentina",
    "Australia",
    "Antarctica",
    "Blueberry",
    "Cheese",
    "Danish",
    "Eclair",
    "Fudge",
    "Granola",
    "Hazelnut",
    "Ice Cream",
    "Jely",
    "Kiwi Fruit",
    "Lamb",
    "Macadamia",
    "Nachos",
    "Oatmeal",
    "Palm Oil",
    "Quail",
    "Rabbit",
    "Salad",
    "T-Bone Steak",
    "Urid Dal",
    "Vanilla",
    "Waffles",
    "Yam",
    "Zest"
  ];

  AutoCompleteTextField textField;

  @override
  Widget build(BuildContext context) {
    textField = new AutoCompleteTextField<String>(
        decoration: new InputDecoration(
          hintText: "Search Item",
        ),
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
            print(currentText);
            currentText = "";
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
          return item.toLowerCase().startsWith(query.toLowerCase());
        });

    Column body = new Column(children: [
      new ListTile(
          title: textField,
          trailing: new IconButton(
              icon: new Icon(Icons.add),
              onPressed: () {
                added.clear();
                setState(() {
                  if (currentText != "") {
                    print(currentText);
                    added.add(currentText);
                    textField.clear();
                    currentText = "";
                  }
                });
              }))
    ]);

    body.children.addAll(added.map((item) {
      
      return new ListTile(title: new Text(item),);
    }));

    return new Scaffold(
        appBar: new AppBar(
            title: new Text('Auto Complete TextField Demo'),),
        body: body);
  }
}