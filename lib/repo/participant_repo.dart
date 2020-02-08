import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmp_app/model/participant.dart';
import 'package:rmp_app/repo/common.dart';
import 'package:rmp_app/util/device_util.dart';

class ParticipantRepo {
  static final Firestore _firestore = Firestore.instance;

  static Future<Participant> addParticipant() async {
    final String deviceId = await DeviceUtil.getDeviceId();

    final CollectionReference collectionRef =
        _firestore.collection(FirestorePaths.PARTICIPANTS_PATH);
    final QuerySnapshot collectionSnapshot = await collectionRef.getDocuments();

    num baselineCount = 0, mnemonicCount = 0;
    for (var docSnapshot in collectionSnapshot.documents) {
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

    final DocumentReference docRef = await _firestore
        .collection(FirestorePaths.PARTICIPANTS_PATH)
        .add(participant.map);

    participant.reference = docRef;
    return participant;
  }
}
