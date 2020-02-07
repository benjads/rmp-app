import 'package:cloud_firestore/cloud_firestore.dart';

class Participant {
  static const String STAGE_COMPLETE = "stage_complete";
  static const String PERCENT_CORRECT = "percent_correct";

  final bool stageComplete;
  final double percentCorrect;
  final DocumentReference reference;

  Participant.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Participant.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[STAGE_COMPLETE] != null),
        assert(map[PERCENT_CORRECT] != null),
        stageComplete = map[STAGE_COMPLETE],
        percentCorrect = map[PERCENT_CORRECT];

  static const Map<String, dynamic> defaultMap = {
    STAGE_COMPLETE: false,
    PERCENT_CORRECT: -1.0
  };
}
