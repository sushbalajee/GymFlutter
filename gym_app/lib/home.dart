
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
 final myController = TextEditingController();

  @override
  void initState() {
    super.initState();

    myController.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    // This also removes the _printLatestValue listener
    myController.dispose();
    super.dispose();
  }

  String test;

  _printLatestValue() {
    setState(() {
          test = myController.text;
        });
    print("Second text field: ${myController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Retrieve Text Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField( 
              controller: myController,
            ),
            TextFormField( 
              controller: myController,
            ),
          ],
        ),
      ),
    );
  }
}