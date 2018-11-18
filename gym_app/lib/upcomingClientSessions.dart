import 'package:flutter/material.dart';

class ClientSessions extends StatefulWidget {

  final String date;
  final String day;

  ClientSessions({this.date, this.day});

  @override
  _ClientSessionsState createState() => new _ClientSessionsState();
}

class _ClientSessionsState extends State<ClientSessions> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFF4A657A),
            title: new Text(widget.day + " - " + widget.date,
                style: TextStyle(fontFamily: "Montserrat"))),
        backgroundColor: Colors.grey[100],
        body: Container());
  }
}
