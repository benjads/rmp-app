import 'package:rmp_app/repo/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmp_app/model/experiment.dart';

class ExperimentRepo {
  static final Firestore _firestore = Firestore.instance;

  static Stream<DocumentSnapshot> getExperimentStream() {
    return _firestore.document(FirestorePaths.experimentDocPath).snapshots();
  }

  static Future<DocumentSnapshot> getExperiment() {
    return _firestore.document(FirestorePaths.experimentDocPath).get();
  }

  static Future<DocumentSnapshot> createExperiment() async {
    final DocumentReference docRef =
        _firestore.document(FirestorePaths.experimentDocPath);
    await docRef.setData(Experiment.defaultMap);
    return docRef.get(source: Source.cache);
  }

  static Future<void> updateExperiment(Experiment experiment) async {
    await _firestore
        .document(FirestorePaths.experimentDocPath)
        .updateData(experiment.map);
  }
}
