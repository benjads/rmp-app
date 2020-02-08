import 'package:cloud_firestore/cloud_firestore.dart';

class Experiment {
  static const String STATE = "state";

  ExperimentState state;
  DocumentReference reference;

  Experiment._internal()
  : state = ExperimentState.WAIT;

  Experiment.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Experiment.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[STATE] != null),
        state = ExperimentState.values
            .firstWhere((state) => (state.toString() == map[STATE]));

  Map<String, dynamic> get map {
    return {STATE: state.toString()};
  }

  static final Map<String, dynamic> defaultMap = {
    STATE: ExperimentState.WAIT.toString()
  };

  factory Experiment.initialize() {
    return Experiment._internal();
  }
}

enum ExperimentState { WAIT, TRAIN, DISTRACT, TEST, RESET }
