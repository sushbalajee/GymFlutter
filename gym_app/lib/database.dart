
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class Database {

  static Future<String> createPTendpoint(String userUID) async {
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("Workouts").child(userUID);

    reference.set("");
    return reference.key;
  }

  static Future<String> createRelationship(String clientUID, String personalTrainerUID) async {
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("Workouts").child("Relationships").child(clientUID);

    reference.set(personalTrainerUID);
    return reference.key;
  }

  static Future<String> createClientEndpoint(String userUID, String personalTrainerUID, String clientName) async {

    UnsusedPlaceholder unusedPH;
    unusedPH = UnsusedPlaceholder("");
    
    String join = clientName + " - " + userUID;

    unusedPH.placeHolder = "Hold Me";

    DatabaseReference reference = 
        FirebaseDatabase.instance.reference().child("Workouts").child(personalTrainerUID).child(join);


    reference.set(unusedPH.toJson());
    //reference.set("");
    return reference.key;
  }

  static Future<String> createClientNames(String userUID, String clientName) async {

    TestingClientNames testclient;
    testclient = TestingClientNames("", "");

    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("Workouts").child("ClientNames").child(userUID);

    testclient.clientName = clientName;
    testclient.status = "Active";  

    reference.push().set(testclient.toJson());

    //reference.set(clientName);
    return reference.key;
  }
}

class TestingClientNames {
  String clientName;
  String status;

  TestingClientNames(this.clientName, this.status);

  TestingClientNames.fromSnapshot(DataSnapshot snapshot)
      : clientName = snapshot.value["clientName"],
        status = snapshot.value["status"];

  toJson() {
    return {
      "clientName": clientName,
      "status": status,
    };
  }
}

class UnsusedPlaceholder {
  String placeHolder;

  UnsusedPlaceholder(this.placeHolder);

  UnsusedPlaceholder.fromSnapshot(DataSnapshot snapshot)
      : placeHolder = snapshot.value["placeHolder"];

  toJson() {
    return {
      "placeHolder": placeHolder
    };
  }
}


  

  
