import 'package:cloud_firestore/cloud_firestore.dart';

class ExperimentData {
  static const String PARTICIPANTS_COMPLETE = "participants_complete";

  num participantsComplete = 0;
  final DocumentReference reference;

  ExperimentData(this.reference);

  ExperimentData.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  ExperimentData.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[PARTICIPANTS_COMPLETE] != null),
        participantsComplete = map[PARTICIPANTS_COMPLETE];

  Map<String, dynamic> get map {
    return {
      PARTICIPANTS_COMPLETE: participantsComplete
    };
  }
}
