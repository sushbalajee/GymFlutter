
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

  static Future<String> createClientEndpoint(String userUID, String personalTrainerUID) async {
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("Workouts").child(personalTrainerUID).child(userUID);

    reference.set("");
    return reference.key;
  }
}


  

  
