import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'package:intl/intl.dart';

class ClientSessions extends StatefulWidget {
  final String date;
  final String day;
  final String id;
  final List<String> clientList;

  ClientSessions({this.date, this.day, this.id, this.clientList});  

  @override
  _ClientSessionsState createState() => new _ClientSessionsState();
}

class _ClientSessionsState extends State<ClientSessions> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

   DatabaseReference itemRef;
   String _selectedText = "Select a Client";
   

  final timeFormat = DateFormat("h:mm a");
  TimeOfDay time;
  List <String> clt = ['a'];

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: new AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFF4A657A),
            title: new Text(widget.day + " - " + widget.date,
                style: TextStyle(fontFamily: "Montserrat"))),
        backgroundColor: Colors.grey[100],
        body: Container(
            width: screenWidth,
           
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                Container( 
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left:10.0, right:10.0, top:10.0),
                    width: screenWidth,
                    child: 

                  DropdownButton( 
                    hint: Text(_selectedText),
                    value: null,
                    
                    onChanged: (String val) {
                      setState(() {
                                    _selectedText = val;    
                                    print(_selectedText); 
                                         });
                        },
                        //myController.text = _selectedText;
                        //print(myController.text);
                    items: widget.clientList
                        .map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                  ),


                ),

                Container( child:
                    TimePickerFormField(
              format: timeFormat,
              decoration: InputDecoration(labelText: 'Time'),
              onChanged: (t) => setState(() => time = t),
            ),
                ),
                  Container(
                    width: screenWidth,
                    padding: EdgeInsets.only(top: 30.0),
                    child: new FlatButton(
                      child: new Text("Submit",
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      color: Colors.black,
                      onPressed: () {
                        //handleSubmit();
                        //setState(() => _NextPageStateClient());
                        //Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
              )
                
    );}
}

         /*Container(
                    width: 300.0,
                    height: 60.0,
                    child: DropdownButtonHideUnderline( 
                      child: ButtonTheme( 
                        alignedDropdown: true,
                        child: DropdownButton(
                          items:
                              <String>['A', 'B', 'C', 'D'].map((String value) {
                            return new DropdownMenuItem<String>( 
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            print(value);
                          },
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                    ),
                  ),*/


