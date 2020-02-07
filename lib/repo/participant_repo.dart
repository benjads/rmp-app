import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmp_app/model/participant.dart';
import 'package:rmp_app/repo/common.dart';

class ParticipantRepo {
  static final Firestore _firestore = Firestore.instance;

  static Future<Participant> addParticipant() async {
    DocumentReference docRef = await _firestore
        .collection(FirestorePaths.PARTICIPANTS_PATH)
        .add(Participant.defaultMap);

    return Participant.fromMap(Participant.defaultMap, reference: docRef);
  }
}
