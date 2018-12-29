import 'package:flutter/material.dart';

class PageOne extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<PageOne> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
          alignment: Alignment.center,
          child: Image.network(
            'https://firebasestorage.googleapis.com/v0/b/gymapp-e8453.appspot.com/o/Target%20Muscles%2FSidepose.jpg?alt=media&token=1fe4a633-a0e7-4b3c-afc0-183c3972bbcc',
          )),
    );
  }
}
