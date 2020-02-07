import 'package:cloud_firestore/cloud_firestore.dart';

class ExperimentData {
  static const String PARTICIPANT_COUNT = "participant_count";
  static const String PARTICIPANTS_COMPLETE = "participants_complete";

  num participantCount = 0, participantsComplete = 0;
  final DocumentReference reference;

  ExperimentData(this.reference);

  ExperimentData.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  ExperimentData.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[PARTICIPANT_COUNT] != null),
        assert(map[PARTICIPANTS_COMPLETE] != null),
        participantCount = map[PARTICIPANT_COUNT],
        participantsComplete = map[PARTICIPANTS_COMPLETE];

  Map<String, dynamic> get map {
    return {
      PARTICIPANT_COUNT: participantCount,
      PARTICIPANTS_COMPLETE: participantsComplete
    };
  }
}
