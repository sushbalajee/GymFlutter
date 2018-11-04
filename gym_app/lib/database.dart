
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
    
    String join = clientName + " - " + userUID;

    DatabaseReference reference = 
        FirebaseDatabase.instance.reference().child("Workouts").child(personalTrainerUID).child(join);

    reference.set("");
    return reference.key;
  }

  static Future<String> createClientNames(String userUID, String clientName) async {

    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("Workouts").child("ClientNames").child(userUID);

    reference.set(clientName);
    return reference.key;
  }
}


  

  
