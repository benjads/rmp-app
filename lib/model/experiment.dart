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

enum ExperimentState { WAIT, SURVEY, TRAIN, DISTRACT, TEST, RESET }

extension StateExtension on ExperimentState {
  ExperimentState get next {
    switch (this) {
      case ExperimentState.WAIT:
       return ExperimentState.SURVEY;
      case ExperimentState.SURVEY:
        return ExperimentState.TRAIN;
      case ExperimentState.TRAIN:
        return ExperimentState.DISTRACT;
      case ExperimentState.DISTRACT:
        return ExperimentState.TEST;
      case ExperimentState.TEST:
        return ExperimentState.WAIT;
      case ExperimentState.RESET:
        return ExperimentState.WAIT;
      default:
        return null;
    }
  }

  ExperimentState get previous {
    switch (this) {
      case ExperimentState.WAIT:
        return ExperimentState.WAIT;
      case ExperimentState.SURVEY:
        return ExperimentState.WAIT;
      case ExperimentState.TRAIN:
        return ExperimentState.SURVEY;
      case ExperimentState.DISTRACT:
        return ExperimentState.TRAIN;
      case ExperimentState.TEST:
        return ExperimentState.DISTRACT;
      case ExperimentState.RESET:
        return ExperimentState.WAIT;
      default:
        return null;
    }
  }
}
