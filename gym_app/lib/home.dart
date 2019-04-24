import 'package:flutter/material.dart';

class PageOne extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<PageOne> {

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      //backgroundColor: Color(0xFF232528),
      body: Container(
          alignment: Alignment.center,
          //child: Image( image: new AssetImage("assets/Evolve Logo.png")),
          ),
    );
  }
}
