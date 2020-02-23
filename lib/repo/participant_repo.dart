import 'package:crossfire/crossfire.dart';
import 'package:rmp_app/model/participant.dart';
import 'package:rmp_app/repo/common.dart';
import 'package:rmp_app/util.dart';

class ParticipantRepo {

  final Firebase _firebase;
  FirebaseCollection _participantCollection;

  ParticipantRepo(this._firebase);

  Future<void> initialize() async {
    _participantCollection = await _firebase.getCollection(FirestorePaths.PARTICIPANTS_PATH);
  }

  Future<Participant> addParticipant() async {
    final String deviceId = await RMPUtil.getDeviceId();

    final Iterable<FirebaseDocument> collection = await _participantCollection.documents.first;

    num baselineCount = 0, mnemonicCount = 0;
    for (var docSnapshot in collection) {
      final Participant curParticipant = Participant.fromSnapshot(docSnapshot);

      if (curParticipant.deviceId == deviceId)
        return curParticipant;

        switch (curParticipant.condition) {
          case Condition.BASELINE:
            baselineCount++;
            break;
          case Condition.MNEMONIC:
            mnemonicCount++;
            break;
        }
    }

    final Condition condition =
        mnemonicCount > baselineCount ? Condition.BASELINE : Condition.MNEMONIC;
    final Participant participant = Participant.initialize(deviceId, condition);

    final FirebaseDocumentReference docRef = await _participantCollection.add(participant.map);

    participant.reference = docRef;
    return participant;
  }

  Stream<Iterable<FirebaseDocument>> getParticipants() {
    return _participantCollection.documents;
  }

  void clearParticipants(List<Participant> cached) {
    assert(cached != null);

    for (final Participant participant in cached) {
      final FirebaseDocumentReference docRef  = participant.reference;
      assert(docRef != null);
      docRef.delete();
    }
  }

  Future<void> updateParticipant(Participant participant) async {
    await participant.reference.update(participant.map);
  }
}
