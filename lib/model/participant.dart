import 'package:cloud_firestore/cloud_firestore.dart';

class Participant {
  static const String DEVICE_ID = "device_id";
  static const String STAGE_COMPLETE = "stage_complete";
  static const String PERCENT_CORRECT = "percent_correct";
  static const String CONDITION = "condition";

  final String deviceId;
  final bool stageComplete;
  final double percentCorrect;
  final Condition condition;
  DocumentReference reference;

  Participant._internal(
      this.deviceId, this.stageComplete, this.percentCorrect, this.condition);

  Participant.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Participant.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[DEVICE_ID] != null),
        assert(map[STAGE_COMPLETE] != null),
        assert(map[PERCENT_CORRECT] != null),
        assert(map[CONDITION] != null),
        deviceId = map[DEVICE_ID],
        stageComplete = map[STAGE_COMPLETE],
        percentCorrect = map[PERCENT_CORRECT],
        condition = Condition.values.firstWhere(
                (state) => (state.toString() == map[CONDITION]));

  factory Participant.initialize(String deviceId, Condition condition) {
    return Participant._internal(deviceId, false, -1.0, condition);
  }

  Map<String, dynamic> get map {
    return {
      DEVICE_ID: deviceId,
      STAGE_COMPLETE: stageComplete,
      PERCENT_CORRECT: percentCorrect,
      CONDITION: condition.toString()
    };
  }
}

enum Condition { BASELINE, MNEMONIC }
