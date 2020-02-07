import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmp_app/model/experiment.dart';
import 'package:rmp_app/repo/common.dart';

class ExperimentRepo {
  static final Firestore _firestore = Firestore.instance;

  static Stream<DocumentSnapshot> getExperimentStream() {
    return _firestore.document(FirestorePaths.experimentDocPath).snapshots();
  }

  static void createExperiment() {
    final DocumentReference docRef =
        _firestore.document(FirestorePaths.experimentDocPath);
    docRef.setData(Experiment.defaultMap);
  }
}
