import 'package:cloud_firestore/cloud_firestore.dart';

class Experiment {
  static const String STATE = "state";

  ExperimentState state;
  final DocumentReference reference;

  Experiment(this.reference);

  Experiment.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Experiment.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[STATE] != null),
        state = ExperimentState.values.firstWhere(
            (state) => (state.toString() == "ExperimentState.${map[STATE]}"));

  Map<String, dynamic> get map {
    return {STATE: state};
  }

  static const Map<String, dynamic> defaultMap = {STATE: "WAIT"};
}

enum ExperimentState { WAIT, TRAIN, DISTRACT, TEST }
