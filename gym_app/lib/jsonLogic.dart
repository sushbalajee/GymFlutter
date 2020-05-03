
class Workouts {
  String workoutname;
  String musclegroup;
  String description;
  List<WorkoutExercises> exNames;

  Workouts(this.workoutname, this.musclegroup, this.exNames, this.description);
}

class Exercises {
  String exerciseName;
  String exerciseExecution;
  String exerciseImage;
  String exerciseCategory;

  Exercises(this.exerciseName, this.exerciseExecution, this.exerciseImage, this.exerciseCategory);
}

class WorkoutCategory {
  final List<Wkouts> workouts;
  String uiCode;

  WorkoutCategory({this.workouts, this.uiCode});

  factory WorkoutCategory.fromJson(Map<String, dynamic> parsedJson, String category) {

    var list = parsedJson[category] as List;

    String ui = parsedJson.keys.toString();

    List<Wkouts> imagesList = list.map((i) => Wkouts.fromJson(i)).toList();

    return WorkoutCategory(workouts: imagesList, uiCode: ui);
  }

}

class Wkouts {
  final String musclegroup;
  final String workoutname;
  final String description;
  final List<WorkoutExercises> listOfExercises;

  Wkouts(
      {this.workoutname,
      this.musclegroup,
      this.listOfExercises,
      this.description});

  factory Wkouts.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['exercises'] as List;
    List<WorkoutExercises> finalLevel =
        list.map((i) => WorkoutExercises.fromJson(i)).toList();

    return Wkouts(
        musclegroup: parsedJson['musclegroup'],
        workoutname: parsedJson['workoutname'],
        description: parsedJson['description'],
        listOfExercises: finalLevel);
  }
}

class WorkoutExercises {
  final String name;
  final String reps;
  final String sets;
  final String execution;
  final String weight;
  final String rest;
  final String target;

  WorkoutExercises(
      {this.name,
      this.execution,
      this.reps,
      this.rest,
      this.sets,
      this.weight, 
      this.target});

  factory WorkoutExercises.fromJson(Map<String, dynamic> parsedJson) {
    return WorkoutExercises(
        name: parsedJson['name'],
        execution: parsedJson['execution'],
        reps: parsedJson['reps'],
        sets: parsedJson['sets'],
        weight: parsedJson['weight'],
        rest: parsedJson['rest'],
        target: parsedJson['target']);
  }
}

